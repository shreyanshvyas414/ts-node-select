-- lua/ts-node-select/keymaps.lua

local M = {}

local selection = require("ts-node-select.selection")
local core = require("ts-node-select.core")

--- Setup default keymaps per buffer
---
--- @param opts table|nil Configuration table
---   - init: string   Keymap for init selection (default: "<CR>")
---   - expand: string Keymap for expand selection (default: "<CR>")
---   - shrink: string Keymap for shrink selection (default: "<BS>")
function M.setup(opts)
	opts = opts or {}

	local init_key = opts.init or "<CR>"
	local expand_key = opts.expand or "<CR>"
	local shrink_key = opts.shrink or "<BS>"

	-- Create autogroup to prevent duplicate autocmds
	local group = vim.api.nvim_create_augroup("TSNodeSelectKeymaps", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
		group = group,
		callback = function(args)
			local bufnr = args.buf or vim.api.nvim_get_current_buf()

			-- Skip excluded buffers (oil, neo-tree, etc.)
			if core.should_exclude(bufnr) then
				return
			end

			-- Skips if buffer is not valid or loaded
			if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
				return
			end

			local ft = vim.bo[bufnr].filetype
			if not ft or ft == 0 then
				return
			end

			if not core.has_parser(bufnr) then
				return
			end

			-- Check if keymaps already exists or set for this buffer
			-- This prevents duplicate keymaps on BufEnter
			local existing = vim.fn.maparg(init_key, "n", false, true)
			if existing.buffer == bufnr then
				return
			end

			-- Normal mode: init selection
			vim.keymap.set("n", init_key, selection.init, {
				buffer = bufnr,
				desc = "TS: Init selection",
				silent = true,
			})

			-- Visual mode: expand selection
			vim.keymap.set("x", expand_key, selection.expand, {
				buffer = bufnr,
				desc = "TS: Shrink selection",
				silent = true,
			})

			-- Visual mode: shrink selection
			vim.keymap.set("x", shrink_key, selection.shrink, {
				buffer = bufnr,
				desc = "TS: Shrink selection",
				silent = true,
			})
		end,
	})
end

return M
