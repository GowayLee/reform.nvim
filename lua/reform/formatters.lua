-- Formatter implementations for different languages
local M               = {}
local config          = require('reform.config')
local utils           = require('reform.utils')

-- Import formatter classes
local BaseFormatter   = require('reform.formatters.base')
local PythonFormatter = require('reform.formatters.python')
local ClangFormatter  = require('reform.formatters.clang')

-- Formatter registry
local formatters      = {
  python = PythonFormatter:new(),
  c = ClangFormatter:new(),
  cpp = ClangFormatter:new(),
  ['c++'] = ClangFormatter:new(),
  -- Legacy support - use Python formatter for other languages
  lua = PythonFormatter:new(),
  java = PythonFormatter:new(),
  javascript = PythonFormatter:new(),
  json = PythonFormatter:new(),
  actionscript = PythonFormatter:new(),
  ruby = PythonFormatter:new()
}

-- Get formatter for filetype
function M.get_formatter(filetype)
  return formatters[filetype]
end

-- Register new formatter
function M.register_formatter(filetype, formatter)
  formatters[filetype] = formatter
end

-- Format text using appropriate formatter
function M.format(text, filetype)
  local formatter = M.get_formatter(filetype)
  if not formatter then
    vim.notify('Reform: Formatter not available', vim.log.levels.WARN)
    return text
  end

  return formatter:format(text, filetype)
end

-- Check if formatter is available for filetype
function M.is_available(filetype)
  local formatter = M.get_formatter(filetype)
  if not formatter then
    return false, 'No formatter registered for ' .. filetype
  end

  return formatter:is_available()
end

-- Export formatter classes for extension
M.BaseFormatter = BaseFormatter
M.PythonFormatter = PythonFormatter
M.ClangFormatter = ClangFormatter

return M
