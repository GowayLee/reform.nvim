local BaseFormatter = require("reform.formatters.base")

---@class StyluaFormatter : BaseFormatter
---@field _availability_cache table|nil
---@field _config_cache table Cache for configuration paths
local StyluaFormatter = setmetatable({}, { __index = BaseFormatter })
StyluaFormatter.__index = StyluaFormatter

--- Create a new StyluaFormatter instance
---@return StyluaFormatter
function StyluaFormatter:new()
  local instance = setmetatable({}, self)
  instance._availability_cache = nil
  instance._config_cache = {}
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

--- Find Stylua configuration file with caching
---@return string|nil config_path
function StyluaFormatter:_find_config()
  local cwd = vim.fn.getcwd()
  
  -- Check cache first
  if self._config_cache[cwd] ~= nil then
    return self._config_cache[cwd]
  end
  
  -- Look for .stylua.toml in project root and parent directories
  local config_path = vim.fn.findfile(".stylua.toml", ".;")
  if config_path == "" then
    -- Also check for stylua.toml (without dot)
    config_path = vim.fn.findfile("stylua.toml", ".;")
  end
  
  -- Cache the result (nil means no config found, string means found)
  self._config_cache[cwd] = config_path ~= "" and config_path or nil
  return self._config_cache[cwd]
end

--- Format Lua code using stylua
---@param text string The text to format
---@param filetype string|nil The filetype of the text
---@return string The formatted text
function StyluaFormatter:format(text, filetype)
  if text == "" then
    return text
  end

  -- Get cached config path
  local config_path = self:_find_config()

  -- Build command with proper argument structure
  local cmd = {"stylua", "-"}
  if config_path then
    table.insert(cmd, 2, "--config-path")
    table.insert(cmd, 3, config_path)
  end
  
  local result = vim.fn.system(cmd, text)
  
  if vim.v.shell_error ~= 0 then
    vim.notify("Reform: Stylua formatting failed", vim.log.levels.WARN)
    return text
  end
  
  return vim.trim(result)
end

return StyluaFormatter