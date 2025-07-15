-- System and general utilities for Reform
local M = {}

--- Check if completion menu is visible
---@return boolean True if completion menu is visible
function M.completion_visible()
  return vim.fn.pumvisible() == 1
end

--- Get current mode safely
---@return string The current mode (e.g., 'n', 'i', 'v', etc.)
function M.get_mode()
  return vim.api.nvim_get_mode().mode
end

--- Table deep copy utility
---@generic T
---@param original T The value to deep copy
---@return T The deep copied value
function M.deep_copy(original)
  local copy
  if type(original) == "table" then
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

return M
