-- Validation utilities for Reform
local M = {}

--- Validate filetype support
---@param filetype string The filetype to validate
---@param supported_types table<string, boolean> Table of supported filetypes
---@return boolean success True if filetype is supported
---@return string|nil error Error message if filetype is not supported
function M.validate_filetype(filetype, supported_types)
  if filetype == 'vim' then
    return false, 'unsupported filetype: ' .. filetype
  end

  if supported_types[filetype] then
    return true
  end

  return false, 'unsupported filetype: ' .. filetype
end

return M