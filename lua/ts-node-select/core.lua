-- lua/ts-node-select/core.lua
-- Safely start Treesitter only when a parser exists
-- Prevents crashes on special buffers (oil, help, nofile, etc.)

local M = {}

-- Filetypes/buftypes to exclude
local excluded_filetypes = {
	"oil",
	"neo-tree",
	"NvimTree",
	"alpha",
	"dashboard",
	"help",
	"man",
	"qf",
	"TelescopePrompt",
	"lazy",
	"mason",
	"toggleterm",
	"Trouble",
	"aerial",
	"minifiles",
}

local excluded_buftypes = {
	"nofile",
	"prompt",
	"quickfix",
	"terminal",
}

-- Check if buffer should be excluded
local function should_exclude(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	-- Check buftype
	local buftype = vim.bo[bufnr].buftype
	if vim.tbl_contains(excluded_buftypes, buftype) then
		return true
	end

	-- Check filetype
	local filetype = vim.bo[bufnr].filetype
	if vim.tbl_contains(excluded_filetypes, filetype) then
		return true
	end

	return false
end

-- Check If treesitter parser is available for buffer
local function has_parser(bufnr)
	local ft = vim.bo[bufnr].filetype
	if not ft or ft == "" then
		return false
	end

	-- Get language for filetype
	local lang = vim.treesitter.language.get_lang(ft)
	if not lang then
		return false
	end

	-- check if parser exists
	return pcall(vim.treesitter.get_parser, bufnr, lang)
end

function M.setup()
	-- Create an autogroup to prevent duplicate autocmds
	local group = vim.api.nvim_create_augroup("TSNodeSelect", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		group = group,
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()

			-- Skip excluded buffers
			if should_exclude(bufnr) then
				return
			end

			-- SKip if buffer is not valid or loaded
			if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
				return
			end

			local ft = vim.bo[bufnr].filetype
			if not ft or ft == "" then
				return
			end

			-- Get the language for this filetype
			local lang = vim.treesitter.language.get_lang(ft)
			if not lang then
				return
			end

			-- This checks if the parser exists
			local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
			if not ok or not parser then
				return
			end

			-- If parser exists, start treesitter for this buffer
			pcall(vim.treesitter.start, bufnr, lang)
		end,
	})
end

-- Expose should_exclude for use in other modules
M.should_exclude = should_exclude
M.has_parser = has_parser

-- Allow users to add custom exclusions
function M.add_excluded_filetypes(filetypes)
	vim.list_extend(excluded_filetypes, filetypes)
end

function M.add_excluded_buftypes(buftypes)
	vim.list_extend(excluded_buftypes, buftypes)
end

return M
