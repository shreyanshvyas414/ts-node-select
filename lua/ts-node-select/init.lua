-- lua/ts-node-select/init.lua
local M = {}

local core = require("ts-node-select.core")
local keymaps = require("ts-node-select.keymaps")
local selection = require("ts-node-select.selection")

--- Setup ts-node-select
---
--- @param opts table|nil Configuration options
---   @field keymaps table|nil Keymap configuration
---     @field init string Key for init selection (default: "<CR>")
---     @field expand string Key for expand selection (default: "<CR>")
---     @field shrink string Key for shrink selection (default: "<BS>")
---   @field exclude table|nil Exclusion configuration
---     @field filetypes string[] Additional filetypes to exclude
---     @field buftypes string[] Additional buftypes to exclude
function M.setup(opts)
	opts = opts or {}

	-- Handle exclusions if provided
	if opts.exclude then
		if opts.exclude.filetypes then
			core.add_excluded_filetypes(opts.exclude.filetypes)
		end
		if opts.exclude.buftypes then
			core.add_excluded_buftypes(opts.exclude.buftypes)
		end
	end

	-- Start Treesitter safely
	core.setup()

	-- Setup keymaps
	keymaps.setup(opts.keymaps)
end

-- Public API
M.init = selection.init
M.expand = selection.expand
M.shrink = selection.shrink

return M
