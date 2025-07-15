-- Reform main module
local M = {}

local config = require("reform.config")
local core = require("reform.core")
local formatters = require("reform.formatters")
local utils = require("reform.utils")

-- Module version
M.version = "0.1.0"

-- Setup Reform with user configuration
function M.setup(user_config)
  -- Initialize configuration
  config.setup(user_config)

  -- Initialize core functionality
  core.setup()

  utils.debug_log("Reform initialized with version " .. M.version)
end

-- Enable Reform for current buffer
function M.enable()
  return core.enable()
end

-- Disable Reform for current buffer
function M.disable()
  return core.disable()
end

-- Add support for new filetype with custom formatter
function M.add_filetype(filetype, formatter_name_or_instance)
  config.add_filetype(filetype, formatter_name_or_instance)

  if type(formatter_name_or_instance) == "table" then
    -- Register custom formatter instance
    formatters.register_formatter(filetype, formatter_name_or_instance)
  end

  utils.info_msg("Added support for filetype: " .. filetype)
end

-- Register a new formatter
function M.register_formatter(filetype, formatter)
  formatters.register_formatter(filetype, formatter)
  utils.info_msg("Registered formatter for filetype: " .. filetype)
end

-- Get current configuration
function M.get_config()
  return config.config
end

-- Check formatter availability
function M.check_formatter(filetype)
  return formatters.is_available(filetype)
end

-- Manual format function for external use
function M.format_text(text, filetype)
  filetype = filetype or vim.bo.filetype
  return formatters.format(text, filetype)
end

-- Get status information
function M.status()
  local ft = vim.bo.filetype
  local enabled = utils.get_buf_var("rtf_enable", 0)
  local is_auto_enable = config.should_auto_enable(ft)
  local formatter_available, formatter_error = formatters.is_available(ft)

  return {
    version = M.version,
    filetype = ft,
    enabled = enabled,
    is_auto_enable = is_auto_enable,
    formatter_available = formatter_available,
    formatter_error = formatter_error,
    config = config.config,
    core_state = core.get_state(),
  }
end

-- Print status information
function M.print_status()
  local status = M.status()

  print("Reform Status:")
  print("  Version: " .. status.version)
  print("  Filetype: " .. status.filetype)
  print("  Enabled: " .. tostring(status.enabled))
  print("  Supported: " .. tostring(status.supported))
  print("  Formatter Available: " .. tostring(status.formatter_available))

  if status.formatter_error then
    print("  Formatter Error: " .. status.formatter_error)
  end
end

-- Export base formatter class for custom formatters
M.BaseFormatter = formatters.BaseFormatter

-- Export utilities for custom formatters
M.utils = utils

return M
