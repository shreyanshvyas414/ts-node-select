-- lua/ts-node-select/init.lua

local M = {}

local core = require("ts-node-select.core")
local keymaps = require("ts-node-select.keymaps")
local selection = require("ts-node-select.selection")


function M.setup(opts)
  opts = opts or {}
  -- Set up the core (Treesitter starup)
  core.setup()

  -- Set up keymaps or (pass options)
  keymaps.setup(opts.keymaps)
end

M.init = selection.init
M.expand = selecton.expand
M.shrink = selection.shrink

return M

