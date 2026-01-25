-- lua/ts-node-select/selection.lua
-- Selection state
local M = {}

-- Buffer => node stack
-- Each buffer keeps its own selection history for clean expand/shrink
local selections = {}

-- Get node at cursor using new Tree-sitter API
local function get_node_at_cursor(buf)
  -- Get cursor position (convert to 0-indexed)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  -- Get parser for this buffer
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return nil
  end

  -- Parse the buffer
  -- IMPORTANT: Call with no arguments to parse entire buffer
  -- Calling with incorrect range format causes the error
  parser:parse()

  -- Get language tree for the cursor position
  -- language_for_range expects: { start_row, start_col, end_row, end_col }
  local lang_tree = parser:language_for_range({ row, col, row, col })
  if not lang_tree then
    return nil
  end

  -- Find the smallest node at cursor position
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    if root and vim.treesitter.is_in_node_range(root, row, col) then
      -- Get smallest descendant at cursor
      -- This includes ALL nodes (comments, punctuation, unnamed nodes)
      local node = root:descendant_for_range(row, col, row, col)
      if node then
        return node
      end
      
      -- Fallback to named nodes only
      return root:named_descendant_for_range(row, col, row, col)
    end
  end

  return nil
end

-- Visual selection helper
local function select_node(buf, node)
  if not node then return end

  local sr, sc, er, ec = node:range()
  local last_line = vim.api.nvim_buf_line_count(buf)

  -- Handle edge cases for end position
  local end_row = math.min(er + 1, last_line)
  local end_col = ec
  
  if er + 1 > last_line then
    -- If node extends past last line, clamp to end of last line
    local line = vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, true)[1]
    end_col = #line
  end

  -- Enter visual mode if not already in it
  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.cmd("normal! v")
  end

  -- Set start position (convert back to 1-indexed)
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  
  -- Move to end position
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { end_row, math.max(end_col - 1, 0) })
end

-- Initialize selection at cursor
function M.init()
  local buf = vim.api.nvim_get_current_buf()
  
  -- Reset selection stack for this buffer
  selections[buf] = {}

  -- Get node at cursor
  local node = get_node_at_cursor(buf)
  if not node then
    return
  end

  -- Add to selection stack and select
  table.insert(selections[buf], node)
  select_node(buf, node)
end

-- Expand selection to parent node
function M.expand()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  -- If no selection stack exists, initialize
  if not stack or #stack == 0 then
    return M.init()
  end

  local current = stack[#stack]
  local parent = current:parent()

  -- Keep going up the tree until we find a parent with a different range
  -- This handles cases where multiple nodes have identical ranges
  while parent do
    -- Check if parent has a different range
    if not vim.deep_equal({ current:range() }, { parent:range() }) then
      table.insert(stack, parent)
      select_node(buf, parent)
      return
    end
    
    -- Move to next parent
    current = parent
    parent = parent:parent()
  end
  
  -- If we reach here, we're at the root and can't expand further
end

-- Shrink selection to previous node
function M.shrink()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]
  
  -- Need at least 2 nodes to shrink
  if not stack or #stack <= 1 then
    return
  end

  -- Remove current node from stack
  table.remove(stack)
  
  -- Select previous node
  local node = stack[#stack]
  if node then
    select_node(buf, node)
  end
end

return M
