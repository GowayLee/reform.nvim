-- Autocommand utilities for Reform
local M = {}

--- Create safe autocommand group
---@param name string The name of the autocommand group
---@param clear? boolean Whether to clear existing autocommands (default: true)
---@return number The autocommand group ID
function M.create_augroup(name, clear)
  return vim.api.nvim_create_augroup(name, { clear = clear ~= false })
end

return M