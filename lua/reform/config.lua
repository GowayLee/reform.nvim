-- Configuration management for Reform
local M = {}

-- Default configuration values
local defaults = {
  on_insert_leave = true, -- Enable formatting when leaving insert mode
  auto_enable = {
    enabled = false, -- Master switch for auto-enable
    filetypes = { -- Filetypes to auto-enable
      "python",
      "lua",
      "java",
      "javascript",
      "json",
      "actionscript",
      "ruby",
      "c",
      "cpp",
    },
    exclude_filetypes = {}, -- Filetypes to exclude from auto-enable
  },
  -- Executable paths for formatters (empty = Mason if mason or PATH, DISABLE = disabled)
  formatters = {
    stylua = "", -- Lua formatter
    clang_format = "", -- C/C++ formatter
  },
  mason = true, -- Enable Mason.nvim integration
  debug = false, -- Enable debug info
}

-- Current configuration state
M.config = {}

-- Initialize configuration from vim global variables
function M.setup(user_config)
  -- Merge defaults with user config
  M.config = vim.tbl_deep_extend("force", defaults, user_config)

  vim.g.reform_debug = M.config.debug == true

  -- Convert supported_filetypes array to lookup table for performance
  local ft_lookup = {}
  for _, ft in ipairs(M.config.auto_enable.filetypes) do
    ft_lookup[ft] = true
  end
  M.config.auto_enable.filetypes = ft_lookup
end

-- Get configuration value
function M.get(key)
  return M.config[key] or defaults[key]
end

-- Set configuration value
function M.set(key, value)
  M.config[key] = value
end

-- Check if filetype should be auto-enabled
function M.should_auto_enable(filetype)
  if not filetype or filetype == "" then
    return false
  end

  -- Check if filetype is in exclude list
  if M.config.auto_enable.exclude_filetypes[filetype] or not M.config.auto_enable.enabled then
    return false
  end

  -- Check if filetype is in auto-enable list
  return M.config.auto_enable.filetypes[filetype] == true
end

-- Get formatter for filetype
function M.get_formatter(filetype)
  return M.config.formatters[filetype]
end

return M
