-- Reform main module (optimized for lazy loading)
local M = {}

local config = require("reform.config")
local core = require("reform.core")
local formatters = require("reform.formatters")
local utils = require("reform.utils")

-- Module version
M.version = "0.1.1"

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

-- Check formatter availability
function M.check_formatter(filetype)
  return formatters.is_available(filetype)
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

return M
