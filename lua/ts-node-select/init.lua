-- lua/ts-node-select/init.lua

local M = {}

local core = require("ts-node-select.core")
local keymaps = require("ts-node-select.keymaps")
local selection = require("ts-node-select.selection")

function M.setup(opts)
  opts = opts or {}

  -- Start Treesitter safely
  core.setup()

  -- Setup keymaps
  keymaps.setup(opts.keymaps)
end

-- Public API
M.init   = selection.init
M.expand = selection.expand
M.shrink = selection.shrink

return M

