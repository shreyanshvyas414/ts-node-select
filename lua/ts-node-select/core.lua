-- lua/ts-node-select/core.lua
-- Safely start Treesitter only when a parser exists
-- Prevents crashes on special buffers (oil, help, nofile, etc.)

local M = {}

function M.setup()
  -- Create an autogroup to prevent duplicate autocmds
  local group = vim.api.nvim_create_augroup("TSNodeSelect", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      local ft = vim.bo.filetype
      
      -- Get the language for this filetype
      local lang = vim.treesitter.language.get_lang(ft)
      if not lang then
        return
      end

      -- Try to add the language parser
      -- This checks if the parser exists
      local has_parser = pcall(vim.treesitter.language.add, lang)
      if not has_parser then
        return
      end

      -- If parser exists, start treesitter for this buffer
      pcall(vim.treesitter.start)
    end,
  })
end

return M
