---@class BaseFormatter
---@field __index BaseFormatter
---@field executable string|nil The resolved executable path
local BaseFormatter = {}
BaseFormatter.__index = BaseFormatter

--- Create a new BaseFormatter instance
---@return BaseFormatter
function BaseFormatter:new()
  local instance = setmetatable({}, self)
  return instance
end

--- Get the formatter name (to be overridden by subclasses)
---@return string
function BaseFormatter:get_name()
  return "base"
end

--- Get the resolved executable path
---@return string|nil
function BaseFormatter:get_executable()
  if not self.executable then
    local mason = require("reform.utils.mason")
    local config = require("reform.config")
    local formatter_name = self:get_name()
    local user_path = config.get("formatters")[formatter_name]

    self.executable = mason.resolve_formatter_path(formatter_name, user_path)
  end
  return self.executable
end

--- Check if the formatter is available
---@return boolean
---@return string|nil error_message
function BaseFormatter:is_available()
  local executable = self:get_executable()
  if not executable then
    return false, string.format("%s formatter not found or disabled", self:get_name())
  end
  return true
end

--- Format the given text
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function BaseFormatter:format(text, filetype)
  return text
end

return BaseFormatter
