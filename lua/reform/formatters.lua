-- Formatter implementations for different languages
local M = {}

-- Import formatter classes (lazy loading)
local BaseFormatter = require("reform.formatters.base")

-- Lazy-loaded formatter instances
local formatter_instances = {}

-- Formatter registry - stores class references instead of instances
local formatter_classes = {
  python = "reform.formatters.python",
  c = "reform.formatters.clang",
  cpp = "reform.formatters.clang",
  ["c++"] = "reform.formatters.clang",
  -- Legacy support - use Python formatter for other languages
  lua = "reform.formatters.python",
  java = "reform.formatters.python",
  javascript = "reform.formatters.python",
  json = "reform.formatters.python",
  actionscript = "reform.formatters.python",
  ruby = "reform.formatters.python",
}

-- Get formatter for filetype (lazy loaded)
function M.get_formatter(filetype)
  local class_path = formatter_classes[filetype]
  if not class_path then
    return nil
  end

  -- Return cached instance or create new one
  if not formatter_instances[filetype] then
    local formatter_class = require(class_path)
    formatter_instances[filetype] = formatter_class:new()
  end

  return formatter_instances[filetype]
end

-- Register new formatter
function M.register_formatter(filetype, formatter)
  formatter_instances[filetype] = formatter
end

-- Format text using appropriate formatter
function M.format(text, filetype)
  local formatter = M.get_formatter(filetype)
  if not formatter then
    vim.notify("Reform: Formatter not available", vim.log.levels.WARN)
    return text
  end

  return formatter:format(text, filetype)
end

-- Check if formatter is available for filetype
function M.is_available(filetype)
  local formatter = M.get_formatter(filetype)
  if not formatter then
    return false, "No formatter registered for " .. filetype
  end

  return formatter:is_available()
end

-- Export formatter classes for extension
M.BaseFormatter = BaseFormatter

return M
