-- Configuration management for Reform
local M = {}

-- Default configuration values
local defaults = {
  ctrl_enter = false,     -- Use CTRL+ENTER instead of ENTER
  on_insert_leave = true, -- Enable formatting when leaving insert mode
  auto_enable = false,    -- Auto-enable for supported filetypes
  supported_filetypes = {
    'python',
    'lua',
    'java',
    'javascript',
    'json',
    'actionscript',
    'ruby',
    'c',
    'cpp'
  },
  -- Formatters for each language
  formatters = {
    python = 'autopep8',
    c = 'clang-format',
    cpp = 'clang-format'
  }
}

-- Current configuration state
M.config = {}

-- Initialize configuration from vim global variables
function M.setup(user_config)
  -- Merge defaults with user config
  M.config = vim.tbl_deep_extend('force', defaults, user_config or {})

  -- Override with vim global variables if they exist
  M.config.ctrl_enter = vim.g.rtf_ctrl_enter == 1
  M.config.on_insert_leave = vim.g.rtf_on_insert_leave ~= 0
  M.config.auto_enable = vim.g.rtformat_auto == 1

  -- Convert supported_filetypes array to lookup table for performance
  local ft_lookup = {}
  for _, ft in ipairs(M.config.supported_filetypes) do
    ft_lookup[ft] = true
  end
  M.config.supported_filetypes = ft_lookup
end

-- Get configuration value
function M.get(key)
  return M.config[key]
end

-- Set configuration value
function M.set(key, value)
  M.config[key] = value
end

-- Check if filetype is supported
function M.is_supported_filetype(filetype)
  return M.config.supported_filetypes[filetype] == true
end

-- Add support for new filetype
function M.add_filetype(filetype, formatter)
  M.config.supported_filetypes[filetype] = true
  if formatter then
    M.config.formatters[filetype] = formatter
  end
end

-- Get formatter for filetype
function M.get_formatter(filetype)
  return M.config.formatters[filetype]
end

return M

