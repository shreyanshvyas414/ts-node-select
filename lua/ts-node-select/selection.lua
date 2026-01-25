-- lua/ts-node-select/selection.lua
-- Alternative implementation using simpler API
local M = {}

-- Buffer => node stack
local selections = {}

-- Get node at cursor - simplified approach
local function get_node_at_cursor(buf)
  -- Get cursor position
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1  -- Convert to 0-indexed
  local col = cursor[2]

  -- Use vim.treesitter.get_node() - simpler and more reliable
  local node = vim.treesitter.get_node({
    bufnr = buf,
    pos = { row, col },
    ignore_injections = false
  })

  return node
end

-- Visual selection helper
local function select_node(buf, node)
  if not node then return end

  local sr, sc, er, ec = node:range()
  local last_line = vim.api.nvim_buf_line_count(buf)

  -- Handle edge cases
  local end_row = math.min(er + 1, last_line)
  local end_col = ec
  
  if er + 1 > last_line then
    local line = vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, true)[1]
    end_col = line and #line or 0
  end

  -- Enter visual mode if not already
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then  -- \22 is <C-v>
    vim.cmd("normal! v")
  end

  -- Set selection
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { end_row, math.max(end_col - 1, 0) })
end

-- Initialize selection
function M.init()
  local buf = vim.api.nvim_get_current_buf()
  selections[buf] = {}

  local node = get_node_at_cursor(buf)
  if not node then
    vim.notify("No tree-sitter node at cursor", vim.log.levels.WARN)
    return
  end

  table.insert(selections[buf], node)
  select_node(buf, node)
end

-- Expand selection
function M.expand()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  if not stack or #stack == 0 then
    return M.init()
  end

  local current = stack[#stack]
  local parent = current:parent()

  -- Find parent with different range
  while parent do
    local current_range = { current:range() }
    local parent_range = { parent:range() }
    
    if not vim.deep_equal(current_range, parent_range) then
      table.insert(stack, parent)
      select_node(buf, parent)
      return
    end
    
    current = parent
    parent = parent:parent()
  end
  
  -- At root, can't expand further
  vim.notify("Cannot expand further", vim.log.levels.INFO)
end

-- Shrink selection
function M.shrink()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  if not stack or #stack <= 1 then
    vim.notify("Cannot shrink further", vim.log.levels.INFO)
    return
  end

  table.remove(stack)
  select_node(buf, stack[#stack])
end

return M
