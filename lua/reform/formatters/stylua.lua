local BaseFormatter = require("reform.formatters.base")

---@class StyluaFormatter : BaseFormatter
---@field _availability_cache table|nil
---@field _cmd_cache table Cache for generated commands
local StyluaFormatter = setmetatable({}, { __index = BaseFormatter })
StyluaFormatter.__index = StyluaFormatter

--- Create a new StyluaFormatter instance
---@return StyluaFormatter
function StyluaFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  instance._cmd_cache = {}
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

--- Find Stylua configuration file
---@return string|nil config_path
function StyluaFormatter:_find_config()
  local config_path = vim.fn.findfile(".stylua.toml", ".;")
  if config_path == "" then
    config_path = vim.fn.findfile("stylua.toml", ".;")
  end
  return config_path ~= "" and config_path or nil
end

--- Generate the stylua command based on configuration
---@return string cmd
function StyluaFormatter:_generate_cmd()
  local config_path = self:_find_config()
  if config_path then
    return string.format("stylua --config-path %s -", config_path)
  else
    return "stylua -"
  end
end

--- Format Lua code using stylua
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function StyluaFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  -- Check cache for generated command
  local cwd = vim.fn.getcwd()
  local cmd = self._cmd_cache[cwd]
  if not cmd then
    cmd = self:_generate_cmd()
    self._cmd_cache[cwd] = cmd
  end

  local result = vim.fn.system(cmd, text)
  if vim.v.shell_error ~= 0 then
    vim.notify("Reform: Stylua formatting failed", vim.log.levels.WARN)
    return text
  end

  return vim.trim(result)
end

return StyluaFormatter
