-- lua/ts-node-select/keymaps.lua
local M = {}

local selection = require("ts-node-select.selection")

--- Setup default keymaps per buffer
---
--- opts = {
---   init   = "<CR>",
---   expand = "<CR>",
---   shrink = "<BS>",
--- }
function M.setup(opts)
  opts = opts or {}
  local init_key   = opts.init   or "<CR>"
  local expand_key = opts.expand or "<CR>"
  local shrink_key = opts.shrink or "<BS>"

  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo.filetype
      local lang = vim.treesitter.language.get_lang(ft)

      -- Only map keys if Treesitter parser exists
      if not (lang and vim.treesitter.language.add(lang)) then
        return
      end

      vim.keymap.set("n", init_key, selection.init, { buffer = bufnr, desc = "TS: init selection" })
      vim.keymap.set("x", expand_key, selection.expand, { buffer = bufnr, desc = "TS: expand selection" })
      vim.keymap.set("x", shrink_key, selection.shrink, { buffer = bufnr, desc = "TS: shrink selection" })
    end,
  })
end

return M

