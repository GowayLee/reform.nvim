-- Mason.nvim integration utilities
local M = {}

-- Mason package name mapping for formatters
local mason_packages = {
  stylua = "stylua",
  clang_format = "clang-format",
}

-- Check if Mason is available and enabled
function M.is_mason_enabled()
  local ok, config = pcall(require, "reform.config")
  return ok and config.get("mason")
end

-- Get Mason's bin directory
function M.get_mason_bin_dir()
  local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
  return mason_path
end

-- Check if a package is installed via Mason
function M.is_mason_package_installed(package_name)
  if not M.is_mason_enabled() then
    return false
  end

  local mason_bin = M.get_mason_bin_dir()
  local executable = mason_packages[package_name]
  if not executable then
    return false
  end

  local full_path = mason_bin .. "/" .. executable
  return vim.fn.executable(full_path) == 1
end

-- Get executable path for a formatter
function M.resolve_formatter_path(formatter_name, user_path)
  -- If explicitly disabled
  if user_path == "DISABLE" then
    return nil
  end

  -- If user provided explicit path
  if user_path and user_path ~= "" then
    -- Expand ~ and other path variables
    local expanded_path = vim.fn.expand(user_path)
    if vim.fn.executable(expanded_path) == 1 then
      return expanded_path
    end
  end

  -- Check Mason installation
  if M.is_mason_enabled() and M.is_mason_package_installed(formatter_name) then
    local mason_bin = M.get_mason_bin_dir()
    local executable = mason_packages[formatter_name]
    if executable then
      local mason_path = mason_bin .. "/" .. executable
      if vim.fn.executable(mason_path) == 1 then
        return mason_path
      end
    end
  end

  -- Fall back to system PATH
  local system_executable = mason_packages[formatter_name]
  if system_executable and vim.fn.executable(system_executable) == 1 then
    return system_executable
  end

  -- Not found
  return nil
end

-- Debug helper for path resolution
function M.debug_path_resolution(formatter_name, user_path)
  local config = require("reform.config")
  local debug = config.get("debug")

  if not debug then
    return
  end

  local resolved = M.resolve_formatter_path(formatter_name, user_path)
  local mason_status = M.is_mason_enabled() and "enabled" or "disabled"

  print(string.format("[Reform Debug] %s path resolution:", formatter_name))
  print(string.format("  User path: %s", user_path or "nil"))
  print(string.format("  Mason: %s", mason_status))
  print(string.format("  Resolved: %s", resolved or "not found"))
end

return M
