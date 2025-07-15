-- Logging and messaging utilities for Reform
local M = {}

--- Display error message to user
---@param text string The error message to display
function M.error_msg(text)
  vim.cmd('redraw')
  vim.api.nvim_echo({ { 'Reform ERROR: ' .. text, 'ErrorMsg' } }, true, {})
end

--- Display info message to user
---@param text string The info message to display
---@param highlight? string|nil The highlight group to use (default: 'Todo')
function M.info_msg(text, highlight)
  vim.cmd('redraw')
  vim.api.nvim_echo({ { 'Reform: ' .. text, highlight or 'Todo' } }, true, {})
end

--- Debug logging (can be enabled/disabled via config)
---@param message string The debug message to log
function M.debug_log(message)
  if vim.g.reform_debug then
    vim.notify('Reform Debug: ' .. message, vim.log.levels.DEBUG)
  end
end

--- Performance timing for debugging
---@generic T
---@param name string The name of the function being timed
---@param fun fun(...): T The function to execute
---@param ... any Arguments to pass to the function
---@return T ... The function results
function M.time_function(name, fun, ...)
  if not vim.g.reform_debug then
    return fun(...)
  end

  local start_time = vim.uv.hrtime()
  local result = { fun(...) }
  local end_time = vim.uv.hrtime()
  local duration = (end_time - start_time) / 1e6 -- Convert to milliseconds

  M.debug_log(string.format('%s took %.2fms', name, duration))
  return unpack(result)
end

return M
