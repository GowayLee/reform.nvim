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
  local result = vim.fn.system("stylua -s -", text)
  if vim.v.shell_error ~= 0 then
    -- Check if it's a syntax error by examining the output
    if result:find("error:") or result:find("ParseError") or result:find("unexpected") then
      -- For syntax errors, we return the original text silently
      -- This prevents interrupting the user's workflow when they're typing
      return text
    else
      -- For other errors (e.g., configuration issues), show a warning
      vim.notify("Reform: Stylua formatting failed", vim.log.levels.WARN)
      return text
    end
  end

  return vim.trim(result)
end

return StyluaFormatter
