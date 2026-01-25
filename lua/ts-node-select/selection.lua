-- lua/ts-node-select/selection.lua
-- Selection state
local M = {}

-- Buffer => node stack
local selections = {}

-- Get node at cursor (NEW API)
local function get_node_at_cursor(buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1 -- Convert to 0-indexed

  -- Get parser
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then return nil end

  -- Parse with proper range format
  parser:parse({ vim.fn.line("w0") - 1, vim.fn.line("w$") })

  -- CRITICAL FIX: language_for_range expects a flat table of 4 values
  -- Format: { start_row, start_col, end_row, end_col }
  local lang_tree = parser:language_for_range({ row, col, row, col })
  if not lang_tree then return nil end

  -- Find the smallest node at cursor position
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    if root and vim.treesitter.is_in_node_range(root, row, col) then
      -- Get smallest descendant at cursor
      local node = root:descendant_for_range(row, col, row, col)
      if node then
        return node
      end
      -- Fallback to named nodes
      return root:named_descendant_for_range(row, col, row, col)
    end
  end

  return nil
end

-- Visual selection helper
local function select_node(buf, node)
  if not node then return end

  local sr, sc, er, ec = node:range()
  local last_line = vim.api.nvim_buf_line_count(buf)

  -- Handle edge cases for end position
  local end_row = math.min(er + 1, last_line)
  local end_col = ec
  if er + 1 > last_line then
    local line = vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, true)[1]
    end_col = #line
  end

  -- Enter visual mode if not already in it
  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.cmd("normal! v")
  end

  -- Set start position
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  
  -- Move to end position
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { end_row, math.max(end_col - 1, 0) })
end

-- Init selection
function M.init()
  local buf = vim.api.nvim_get_current_buf()
  selections[buf] = {}

  local node = get_node_at_cursor(buf)
  if not node then return end

  table.insert(selections[buf], node)
  select_node(buf, node)
end

-- Incremental expand
function M.expand()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  if not stack or #stack == 0 then
    return M.init()
  end

  local current = stack[#stack]
  local parent = current:parent()

  -- Keep going up until we find a parent with a different range
  while parent do
    if not vim.deep_equal({ current:range() }, { parent:range() }) then
      table.insert(stack, parent)
      select_node(buf, parent)
      return
    end
    current = parent
    parent = parent:parent()
  end
end

-- Shrink selection
function M.shrink()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  if not stack or #stack <= 1 then return end

  table.remove(stack)
  local node = stack[#stack]
  if node then
    select_node(buf, node)
  end
end

return M
