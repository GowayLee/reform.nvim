-- Formatter implementations for different languages
local M = {}

-- Lazy-loaded formatter instances
local formatter_instances = {}

-- Filetype to formatter class mapping (no longer user-configurable)
local formatter_classes = {
  python = "reform.formatters.python",
  c = "reform.formatters.clang",
  cpp = "reform.formatters.clang",
  ["c++"] = "reform.formatters.clang",
  lua = "reform.formatters.stylua",
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

return M
