local BaseFormatter = require("reform.formatters.base")

---@class ClangFormatter : BaseFormatter
---@field _availability_cache table|nil
local ClangFormatter = setmetatable({}, { __index = BaseFormatter })
ClangFormatter.__index = ClangFormatter

--- Create a new ClangFormatter instance
---@return ClangFormatter
function ClangFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  return instance
end

--- Check if the Clang formatter is available (with caching)
---@return boolean
---@return string|nil error_message
function ClangFormatter:is_available()
  -- Return cached result if available
  if self._availability_cache ~= nil then
    return self._availability_cache.result, self._availability_cache.error
  end

  -- Cache the result
  self._availability_cache = {}

  local result = vim.fn.executable("clang-format")
  if result == 0 then
    self._availability_cache.result = false
    self._availability_cache.error = "clang-format not found in PATH"
    return self._availability_cache.result, self._availability_cache.error
  end

  self._availability_cache.result = true
  self._availability_cache.error = nil
  return self._availability_cache.result, self._availability_cache.error
end

--- Format C/C++ code using clang-format
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function ClangFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  -- Use clang-format for single line formatting
  local lang_map = {
    c = "c",
    cpp = "cpp",
    ["c++"] = "cpp",
  }

  local lang = lang_map[filetype] or "cpp"
  local cmd = string.format("clang-format --assume-filename=temp.%s", lang)

  local result = vim.fn.system(cmd, text)
  if vim.v.shell_error == 0 then
    return vim.trim(result)
  end

  return text
end

return ClangFormatter
