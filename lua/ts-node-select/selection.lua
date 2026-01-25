-- lua/ts-node-select/selection.lua
-- Selection state
local M = {}

-- Buffer => node stack
local selections = {}

-- Each buffer keeps its own selection history
-- Allows clean expand/shrink

-- Get node at cursor (NEW API) =>
local function get_node_at_cursor(buf)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local parser = vim.treesitter.get_parser(buf)

  -- NEW API: no custom ranges needed
  parser:parse()

  local lang_tree = parser:language_for_range(
    { row, col },
    { row, col }
  )
  if not lang_tree then return end

  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    if root and vim.treesitter.is_in_node_range(root, row, col) then
      return root:descendant_for_range(row, col, row, col)
    end
  end
end

-- Uses descendant_for_range
-- Includes comments, punctuation, unnamed nodes
-- More reliable than old API behavior

-- Visual selection helper =>
local function select_node(buf, node)
  if not node then return end

  local sr, sc, er, ec = node:range()

  vim.cmd("normal! v")
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
end

-- Operator-pending safe
-- Works with d, y, c, etc.

-- Init selection =>
function M.init()
  local buf = vim.api.nvim_get_current_buf()
  selections[buf] = {}

  local node = get_node_at_cursor(buf)
  if not node then return end

  table.insert(selections[buf], node)
  select_node(buf, node)
end

-- Selects smallest syntax unit under cursor

-- Incremental expand =>
function M.expand()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]

  if not stack or #stack == 0 then
    return M.init()
  end

  local current = stack[#stack]
  local parent = current:parent()

  while parent do
    if not vim.deep_equal({ current:range() }, { parent:range() }) then
      table.insert(stack, parent)
      select_node(buf, parent)
      return
    end
    parent = parent:parent()
  end
end

-- Skips parents with identical ranges
-- Prevents "stuck expanding"
-- Deterministic behavior

-- Shrink selection =>
function M.shrink()
  local buf = vim.api.nvim_get_current_buf()
  local stack = selections[buf]

  if not stack or #stack <= 1 then return end

  table.remove(stack)
  select_node(buf, stack[#stack])
end

return M

