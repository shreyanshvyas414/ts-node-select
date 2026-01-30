-- lua/ts-node-select/selection.lua

local M = {}

-- Buffer => node stack
local selections = {}

-- Get node at cursor - simplified approach
local function get_node_at_cursor(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	-- Get cursor position
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1 -- Convert to 0-indexed
	local col = cursor[2]

	-- Fast path: Try vim.treesitter.get_node() first (0(depth))
	-- Changing bacause it's cheap and works most of the time
	-- But sometime breaks.
	local ok, node = pcall(vim.treesitter.get_node, {
		bufnr = bufnr,
		pos = { row, col },
		ignore_injections = false,
	})

	if ok or node then
		return node
	end
	-- Using fallback path => Parsed based apporch (0(tree walk))
	-- Only when get_node() breaks (very rare) but will optimized.
	local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr)

	if not parser_ok or not parser then
		return nil
	end

	-- Get the syntax tree
	local trees = parser:parse()
	if not trees or #trees == 0 then
		return nil
	end

	-- Get root and find node at cursor
	local root = trees[1]:root()
	if not root then
		return nil
	end

	-- Use named_descendent_for_range for accurate node detection
	local node_fallback = root:named_descendant_for_range(row, col, row, col)

	-- If no named node, try unamed
	if not node_fallback then
		node_fallback = root:descendant_for_range(row, col, row, col)
	end

	return node_fallback
end

-- Check if tree-sitter is active for this buffer
local function is_treesitter_active(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	return ok and parser ~= nil
end

-- Visual selection helper
local function select_node(bufnr, node)
	if not node then
		return
	end

	local sr, sc, er, ec = node:range()
	local last_line = vim.api.nvim_buf_line_count(bufnr)

	-- Handle edge cases
	local end_row = math.min(er + 1, last_line)
	local end_col = ec

	if er + 1 > last_line then
		local line = vim.api.nvim_buf_get_lines(bufnr, last_line - 1, last_line, true)[1]
		end_col = line and #line or 0
	end

	-- Enter visual mode if not already
	local mode = vim.api.nvim_get_mode().mode
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then -- \22 is <C-v>
		vim.cmd("normal! v")
	end

	-- Set selection
	vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
	vim.cmd("normal! o")
	vim.api.nvim_win_set_cursor(0, { end_row, math.max(end_col - 1, 0) })
end

-- Initialize selection
function M.init()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Check if tree-sitter is even active
	if not is_treesitter_active(bufnr) then
		return
	end

	-- Reset selection stack for this buffer
	selections[bufnr] = {}

	local node = get_node_at_cursor(bufnr)
	if not node then
		-- No node at cursor - this is normal for empty lines, whitespace, etc.
		-- Just do nothing silently
		return
	end

	table.insert(selections[bufnr], node)
	select_node(bufnr, node)
end

-- Expand selection
function M.expand()
	local bufnr = vim.api.nvim_get_current_buf()

	-- Check if tree-sitter is active
	if not is_treesitter_active(bufnr) then
		return
	end

	local stack = selections[bufnr]

	-- If no selection stack exists, try to initialize
	if not stack or #stack == 0 then
		return M.init()
	end

	local current = stack[#stack]

	-- Validate that the current node is still valid
	if not current or not pcall(current.range, current) then
		-- Node became invalid, reinitialize
		return M.init()
	end

	local parent = current:parent()

	-- Find parent with different range
	while parent do
		local ok_current, current_range = pcall(function()
			return { current:range() }
		end)
		local ok_parent, parent_range = pcall(function()
			return { parent:range() }
		end)

		if not ok_current or not ok_parent then
			-- Something went wrong, stop
			return
		end

		if not vim.deep_equal(current_range, parent_range) then
			table.insert(stack, parent)
			select_node(buf, parent)
			return
		end

		current = parent
		parent = parent:parent()
	end

	-- At root, can't expand further - silently do nothing
end

-- Shrink selection
function M.shrink()
	local bufnr = vim.api.nvim_get_current_buf()
	local stack = selections[bufnr]

	-- Need at least 2 nodes to shrink
	if not stack or #stack <= 1 then
		return
	end

	-- Remove current node from stack
	table.remove(stack)

	-- Select previous node
	local node = stack[#stack]
	if node and pcall(node.range, node) then
		select_node(bufnr, node)
	else
		-- Previous node is invalid, clear stack
		selections[bufnr] = {}
	end
end

return M
