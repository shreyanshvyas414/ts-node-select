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

function M.setup()
  -- Create an autogroup to prevent duplicate autocmds
  local group = vim.api.nvim_create_augroup("TSNodeSelect", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      
      -- Skip excluded buffers
      if should_exclude(bufnr) then
        return
      end
      
      local ft = vim.bo[bufnr].filetype
      
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

-- Expose should_exclude for use in other modules
M.should_exclude = should_exclude

-- Allow users to add custom exclusions
function M.add_excluded_filetypes(filetypes)
  vim.list_extend(excluded_filetypes, filetypes)
end

function M.add_excluded_buftypes(buftypes)
  vim.list_extend(excluded_buftypes, buftypes)
end

return M
