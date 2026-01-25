-- lua/ts-node-select/core.lua

-- Prevent buffer crashes (oil, help, nofile, etc).
-- Uses new Tree-sitter API only.
-- Treesitter starts only when safe.

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    callback = function()
      local ft = vim.bo.filetype
      local lang = vim.treesitter.language.get_lang(ft)

      if not lang then
        return
      end

      -- Only start treesitter if a parser actually exists
      if pcall(vim.treesitter.language.add, lang) then
        pcall(vim.treesitter.start)
      end
    end,
  })
end

return M

