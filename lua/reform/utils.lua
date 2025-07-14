-- Utility functions for Reform
local M = {}

-- Display error message to user
function M.error_msg(text)
  vim.cmd('redraw')
  vim.api.nvim_echo({ { 'Reform ERROR: ' .. text, 'ErrorMsg' } }, true, {})
end

-- Display info message to user
function M.info_msg(text, highlight)
  vim.cmd('redraw')
  vim.api.nvim_echo({ { 'Reform: ' .. text, highlight or 'Todo' } }, true, {})
end

-- Extract indentation and body from line
function M.parse_line(line)
  local head = line:match('^%s*') or ''
  local body = line:match('^%s*(.*)$') or ''
  return head, body
end

-- Check if cursor is at end of non-empty line
function M.at_line_end()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local pos = cursor[2]
  local tail = line:sub(pos + 1)

  return tail:match('^%s*$') and not line:match('^%s*$')
end

-- Safe key sequence execution
function M.execute_keys(keys)
  if type(keys) == 'table' then
    keys = table.concat(keys)
  end
  return keys
end

-- Handle multiline text insertion
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

-- Check if completion menu is visible
function M.completion_visible()
  return vim.fn.pumvisible() == 1
end

-- Get current mode safely
function M.get_mode()
  return vim.api.nvim_get_mode().mode
end

-- Module-level buffer state management
local buffer_state = {}

-- Safe buffer variable access using module-level state
function M.get_buf_var(name, default)
  local bufnr = vim.api.nvim_get_current_buf()
  if not buffer_state[bufnr] then
    buffer_state[bufnr] = {}
  end
  return buffer_state[bufnr][name] or default
end

function M.set_buf_var(name, value)
  local bufnr = vim.api.nvim_get_current_buf()
  if not buffer_state[bufnr] then
    buffer_state[bufnr] = {}
  end
  buffer_state[bufnr][name] = value
end

-- Clean up buffer state when buffers are deleted
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    buffer_state[args.buf] = nil
  end,
  group = vim.api.nvim_create_augroup('ReformBufferCleanup', { clear = true })
})

-- Safe global variable access
function M.get_global_var(name, default)
  return vim.g[name] or default
end

-- Validate filetype support
function M.validate_filetype(filetype, supported_types)
  if filetype == 'vim' then
    return false, 'unsupported filetype: ' .. filetype
  end

  if supported_types[filetype] then
    return true
  end

  return false, 'unsupported filetype: ' .. filetype
end

-- Create safe autocommand group
function M.create_augroup(name, clear)
  return vim.api.nvim_create_augroup(name, { clear = clear ~= false })
end

-- Debug logging (can be enabled/disabled via config)
function M.debug_log(message)
  if vim.g.rtformat_debug then
    vim.notify('Reform Debug: ' .. message, vim.log.levels.DEBUG)
  end
end

-- Performance timing for debugging
function M.time_function(name, func, ...)
  if not vim.g.rtformat_debug then
    return func(...)
  end

  local start_time = vim.loop.hrtime()
  local result = { func(...) }
  local end_time = vim.loop.hrtime()
  local duration = (end_time - start_time) / 1e6 -- Convert to milliseconds

  M.debug_log(string.format('%s took %.2fms', name, duration))
  return unpack(result)
end

-- Table deep copy utility
function M.deep_copy(original)
  local copy
  if type(original) == 'table' then
    copy = {}
    for key, value in next, original, nil do
      copy[M.deep_copy(key)] = M.deep_copy(value)
    end
    setmetatable(copy, M.deep_copy(getmetatable(original)))
  else
    copy = original
  end
  return copy
end

-- String trimming utility
function M.trim(str)
  return str:match('^%s*(.-)%s*$')
end

-- Check if string is empty or whitespace only
function M.is_whitespace(str)
  return str:match('^%s*$') ~= nil
end

return M

