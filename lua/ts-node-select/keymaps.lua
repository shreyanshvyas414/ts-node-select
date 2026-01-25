-- lua/ts-node-select/keymaps.lua

local M = {}
local selection = require("ts-node-select.selection")

--- Setup default keymaps per buffer
---
--- @param opts table|nil Configuration table
---   - init: string   Keymap for init selection (default: "<CR>")
---   - expand: string Keymap for expand selection (default: "<CR>")
---   - shrink: string Keymap for shrink selection (default: "<BS>")
function M.setup(opts)
  opts = opts or {}
  
  local init_key   = opts.init   or "<CR>"
  local expand_key = opts.expand or "<CR>"
  local shrink_key = opts.shrink or "<BS>"

  -- Create autogroup to prevent duplicate autocmds
  local group = vim.api.nvim_create_augroup("TSNodeSelectKeymaps", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local ft = vim.bo[bufnr].filetype

      -- Get language for this filetype
      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then
        return
      end

      -- Only map keys if Treesitter parser exists
      local has_parser = pcall(vim.treesitter.language.add, lang)
      if not has_parser then
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
        desc = "TS: Expand selection",
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
