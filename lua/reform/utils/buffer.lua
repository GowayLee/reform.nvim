-- Buffer and window operation utilities for Reform
local M = {}

--- Safe key sequence execution
---@param keys string|table The key sequence to execute
---@return string The formatted key sequence
function M.execute_keys(keys)
  if type(keys) == 'table' then
    keys = table.concat(keys)
  end
  return keys
end

--- Handle multiline text insertion
---@param text string The text to insert (can contain newlines)
---@param preserve_indent? boolean Whether to preserve current line indentation (default: false)
function M.insert_multiline(text, preserve_indent)
  local lines = vim.split(text, '\n', { plain = true })
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local current_line = vim.api.nvim_get_current_line()
  local indent = preserve_indent and (current_line:match('^%s*') or '') or ''

  for i, line in ipairs(lines) do
    local formatted_line = (preserve_indent and i > 1) and (indent .. line) or line
    if i == 1 then
      vim.api.nvim_set_current_line(formatted_line)
    else
      vim.api.nvim_buf_set_lines(0, row + i - 2, row + i - 2, false, { formatted_line })
    end
  end

  -- Move cursor to end of last line
  if #lines > 1 then
    local last_line = (preserve_indent and indent or '') .. lines[#lines]
    vim.api.nvim_win_set_cursor(0, { row + #lines - 1, #last_line })
  end
end

return M

