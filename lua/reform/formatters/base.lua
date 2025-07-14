---@class BaseFormatter
---@field __index BaseFormatter
local BaseFormatter = {}
BaseFormatter.__index = BaseFormatter

--- Create a new BaseFormatter instance
---@return BaseFormatter
function BaseFormatter:new()
  local instance = setmetatable({}, self)
  return instance
end

--- Check if the formatter is available
---@return boolean
---@return string|nil error_message
function BaseFormatter:is_available()
  return false
end

--- Format the given text
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function BaseFormatter:format(text, filetype)
  return text
end

return BaseFormatter
