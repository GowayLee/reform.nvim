-- Formatter implementations for different languages
local M           = {}
local config      = require('reform.config')
local utils       = require('reform.utils')

-- PEP8 rules for Python formatting
local pep8_rules  = {
  'E101', 'E11', 'E121', 'E122', 'E123', 'E124', 'E125',
  'E126', 'E127', 'E128', 'E129', 'E131', 'E133',
  'E20', 'E211', 'E22', 'E224', 'E225', 'E226', 'E227',
  'E228', 'E231', 'E241', 'E242', 'E251', 'E252',
  'E27'
}

local pep8_python = vim.tbl_extend('force', {}, pep8_rules)
vim.list_extend(pep8_python, { 'E26', 'E265', 'E266', 'E', 'W' })

-- Base formatter interface
local BaseFormatter = {}
BaseFormatter.__index = BaseFormatter

function BaseFormatter:new()
  local instance = setmetatable({}, self)
  return instance
end

function BaseFormatter:is_available()
  return false
end

function BaseFormatter:format(text)
  return text
end

-- Python autopep8 formatter
local PythonFormatter = setmetatable({}, { __index = BaseFormatter })
PythonFormatter.__index = PythonFormatter

function PythonFormatter:new()
  local instance = setmetatable({}, self)
  if vim.fn.has('python3') == 1 then
    self.py_version = true
  end
  return instance
end

function PythonFormatter:is_available()
  if not self.py_version then
    return false, 'require +python3 feature'
  end

  local code = [[
__i = 100
try:
    import autopep8
    __i = 1
except ImportError:
    __i = 0
]]

  local success, result = pcall(vim.fn.py3eval, 'exec("""' .. code .. '""") or __i')
  if not success or result == 0 then
    return false, 'require python module autopep8'
  end

  return true
end

function PythonFormatter:format(text, filetype)
  if text == '' then
    return text
  end

  local rules = (filetype == 'python') and pep8_python or pep8_rules
  local rules_str = '["' .. table.concat(rules, '", "') .. '"]'

  local python_code = string.format([[
import autopep8
__t = %q
__o = {'select': %s}
__result = autopep8.fix_code(__t, options=__o).strip()
]], text, rules_str)

  local success, result = pcall(vim.fn.py3eval, 'exec("""' .. python_code .. '""") or __result')
  if success and result then
    return result
  end

  return text
end

-- Clang-format formatter for C/C++
local ClangFormatter = setmetatable({}, { __index = BaseFormatter })
ClangFormatter.__index = ClangFormatter

function ClangFormatter:new()
  local instance = setmetatable({}, self)
  return instance
end

function ClangFormatter:is_available()
  local result = vim.fn.executable('clang-format')
  if result == 0 then
    return false, 'clang-format not found in PATH'
  end
  return true
end

function ClangFormatter:format(text, filetype)
  if text == '' then
    return text
  end

  -- Use clang-format for single line formatting
  local lang_map = {
    c = 'c',
    cpp = 'cpp',
    ['c++'] = 'cpp'
  }

  local lang = lang_map[filetype] or 'cpp'
  local cmd = string.format('clang-format --assume-filename=temp.%s', lang)

  local result = vim.fn.system(cmd, text)
  if vim.v.shell_error == 0 then
    return vim.trim(result)
  end

  return text
end

-- Formatter registry
local formatters = {
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
