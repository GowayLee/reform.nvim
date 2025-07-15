-- State management utilities for Reform
local M = {}

---@type table<number, table<string, any>> Buffer state storage
local buffer_state = {}

--- Safe buffer variable access using module-level state
---@param name string The variable name
---@param default? any The default value if variable doesn't exist
---@return any The variable value or default
function M.get_buf_var(name, default)
  local bufnr = vim.api.nvim_get_current_buf()
  if not buffer_state[bufnr] then
    buffer_state[bufnr] = {}
  end
  return buffer_state[bufnr][name] or default
end

--- Safe buffer variable setter
---@param name string The variable name
---@param value any The value to set
function M.set_buf_var(name, value)
  local bufnr = vim.api.nvim_get_current_buf()
  if not buffer_state[bufnr] then
    buffer_state[bufnr] = {}
  end
  buffer_state[bufnr][name] = value
end

--- Safe global variable access
---@param name string The global variable name
---@param default? any The default value if variable doesn't exist
---@return any The variable value or default
function M.get_global_var(name, default)
  return vim.g[name] or default
end

-- Clean up buffer state when buffers are deleted
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    buffer_state[args.buf] = nil
  end,
  group = vim.api.nvim_create_augroup('ReformBufferCleanup', { clear = true })
})

return M

