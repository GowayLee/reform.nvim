local BaseFormatter = require("reform.formatters.base")

---@class StyluaFormatter : BaseFormatter
---@field _availability_cache table|nil
local StyluaFormatter = setmetatable({}, { __index = BaseFormatter })
StyluaFormatter.__index = StyluaFormatter

--- Create a new StyluaFormatter instance
---@return StyluaFormatter
function StyluaFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  return instance
end

--- Check if the Stylua formatter is available (with caching)
---@return boolean
---@return string|nil error_message
function StyluaFormatter:is_available()
  -- Return cached result if available
  if self._availability_cache ~= nil then
    return self._availability_cache.result, self._availability_cache.error
  end

  -- Cache the result
  self._availability_cache = {}

  local result = vim.fn.executable("stylua")
  if result == 0 then
    self._availability_cache.result = false
    self._availability_cache.error = "stylua not found in PATH"
    return self._availability_cache.result, self._availability_cache.error
  end

  self._availability_cache.result = true
  self._availability_cache.error = nil
  return self._availability_cache.result, self._availability_cache.error
end

--- Format Lua code using stylua
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function StyluaFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  -- Use stylua for formatting via stdin
  local cmd = "stylua -"
  
  local result = vim.fn.system(cmd, text)
  if vim.v.shell_error == 0 then
    return vim.trim(result)
  end

  return text
end

return StyluaFormatter