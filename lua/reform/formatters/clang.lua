local BaseFormatter = require("reform.formatters.base")

---@class ClangFormatter : BaseFormatter
---@field _availability_cache table|nil
---@field _cmd_cache table Cache for generated commands
local ClangFormatter = setmetatable({}, { __index = BaseFormatter })
ClangFormatter.__index = ClangFormatter

--- Create a new ClangFormatter instance
---@return ClangFormatter
function ClangFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  instance._cmd_cache = {}
  return instance
end

--- Get formatter name
---@return string
function ClangFormatter:get_name()
  return "clang_format"
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

  local executable = self:get_executable()
  if not executable then
    self._availability_cache.result = false
    self._availability_cache.error = "clang-format not found or disabled"
    return self._availability_cache.result, self._availability_cache.error
  end

  self._availability_cache.result = true
  self._availability_cache.error = nil
  return self._availability_cache.result, self._availability_cache.error
end

--- Generate the clang-format command based on filetype
---@param filetype string|nil The filetype of the text
---@return string cmd
function ClangFormatter:_generate_cmd(filetype)
  local executable = self:get_executable()
  if not executable then
    return "echo"
  end

  local lang_map = {
    c = "c",
    cpp = "cpp",
    ["c++"] = "cpp",
  }

  local lang = lang_map[filetype] or "cpp"
  local config_path = self:_find_config()

  local cmd = string.format('"%s" --assume-filename=temp.%s', executable, lang)
  if config_path then
    cmd = cmd .. string.format(" --style=file:%s", config_path)
  end

  return cmd
end

--- Find clang-format configuration file
---@return string|nil config_path
function ClangFormatter:_find_config()
  -- Look for .clang-format in project root and parent directories
  local config_path = vim.fn.findfile(".clang-format", ".;")
  if config_path == "" then
    -- Also check for _clang-format (alternative naming)
    config_path = vim.fn.findfile("_clang-format", ".;")
  end
  return config_path ~= "" and config_path or nil
end

--- Format C/C++ code using clang-format
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function ClangFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  -- Check cache for generated command
  local cache_key = filetype or "default"
  local cmd = self._cmd_cache[cache_key]
  if not cmd then
    cmd = self:_generate_cmd(filetype)
    self._cmd_cache[cache_key] = cmd
  end
  local result = vim.fn.system(cmd, text)
  if vim.v.shell_error == 0 then
    return vim.trim(result)
  end

  return text
end

return ClangFormatter
