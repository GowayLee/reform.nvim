-- Text and line manipulation utilities for Reform
local M = {}

--- Extract indentation and body from line
---@param line string The line to parse
---@return string head The indentation (leading whitespace)
---@return string body The actual content (without indentation)
function M.parse_line(line)
  local head = line:match("^%s*") or ""
  local body = line:match("^%s*(.*)$") or ""
  return head, body
end

--- Check if cursor is at end of non-empty line
---@return boolean True if cursor is at the end of a non-empty line
function M.at_line_end()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local pos = cursor[2]
  local tail = line:sub(pos + 1)

  return tail:match("^%s*$") and not line:match("^%s*$")
end

--- String trimming utility
---@param str string The string to trim
---@return string The trimmed string
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

--- Check if string is empty or whitespace only
---@param str string The string to check
---@return boolean True if string is empty or contains only whitespace
function M.is_whitespace(str)
  return str:match("^%s*$") ~= nil
end

return M
