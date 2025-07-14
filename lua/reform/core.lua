-- Core formatting logic for Reform
local M = {}

local config = require('reform.config')
local formatters = require('reform.formatters')
local utils = require('reform.utils')

-- Module state
local state = {
  enable_ctrl_enter = false,
  initialized = false
}

-- Format a single line
function M.format_line(text, filetype)
  if not text or text == '' then
    return text
  end

  local head, body = utils.parse_line(text)
  if body == '' then
    return text
  end

  utils.debug_log('Formatting line for filetype: ' .. filetype)

  return utils.time_function('format_line', function()
    local formatted_body = formatters.format(body, filetype)
    return head .. formatted_body
  end)
end

-- Main formatting function triggered by ENTER
function M.real_time_format_code()
  local filetype = vim.bo.filetype

  -- Check if we're at the end of a non-empty line
  if utils.at_line_end() then
    local line = vim.api.nvim_get_current_line()
    local formatted = M.format_line(line, filetype)

    if line == formatted then
      return '<CR>'
    end

    -- Store formatted text in a buffer variable for the key mapping to use
    utils.set_buf_var('rtformat_text', formatted)

    local keys = ''

    -- This sequence of keys is a translation of the original rtformat.vim logic
    -- 1. Set a flag to prevent InsertLeave recursion.
    -- 2. Create an undo point.
    -- 3. Exit insert mode, Substitute line.
    -- 4. Exit again to make sure cursor at head of the line, insert
    -- 5. Insert the formatted text from the buffer variable.
    -- 6. Reset the flag.
    -- 7. Insert the newline.
    -- We use <Cmd> which is a cleaner Neovim way to run Ex commands from insert mode.
    keys = keys .. '<Cmd>let b:rtformat_insert_leave=1<CR>'
    keys = keys .. '<C-g>u<Esc>S'
    keys = keys .. '<Esc>i'
    keys = keys .. '<C-R>=b:rtformat_text<CR>'
    keys = keys .. '<Cmd>let b:rtformat_insert_leave=0<CR>'
    keys = keys .. '<CR>'
    return keys
  end

  -- Normal ENTER behavior
  return '<CR>'
end

-- Handle InsertLeave event for additional formatting
function M.on_insert_leave()
  if utils.get_buf_var('rtformat_insert_leave', false) then
    return
  end

  local mode = utils.get_mode()
  if mode:match('^i') then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local filetype = vim.bo.filetype
  local head, body = utils.parse_line(line)
  local formatted_body = formatters.format(body, filetype)

  if body == formatted_body then
    return
  end

  utils.debug_log('Formatting on InsertLeave')

  -- Handle multiline formatting result
  local formatted_line = head .. formatted_body
  utils.set_buf_var('rtformat_insert_leave', true)

  if formatted_body:find('\n') then
    utils.insert_multiline(formatted_body, true)
  else
    vim.api.nvim_set_current_line(formatted_line)
  end

  utils.set_buf_var('rtformat_insert_leave', false)
end

-- Check if plugin can be enabled for current buffer
function M.check_enable()
  local filetype = vim.bo.filetype

  if not filetype or filetype == '' then
    utils.error_msg('No filetype detected')
    return false
  end

  -- Check if formatter is available
  local available, err = formatters.is_available(filetype)
  if not available then
    utils.error_msg(err or ('Formatter not available for ' .. filetype))
    return false
  end

  return true
end

-- Enable RT Format for current buffer
function M.enable()
  -- Check is already enabled
  if utils.get_buf_var('rtf_enable', false) then
      return false
  end

  if not M.check_enable() then
    return false
  end

  local key = config.get('ctrl_enter') and '<C-CR>' or '<CR>'
  state.enable_ctrl_enter = config.get('ctrl_enter')

  utils.debug_log('Enabling Reform with key: ' .. key)

  -- Set up key mapping, for calling to reform
  vim.keymap.set('i', key, M.real_time_format_code, {
    buffer = true,
    expr = true,
    silent = true,
    desc = 'RT Format: Real-time code formatting'
  })

  -- Set up autocommand for InsertLeave
  if config.get('on_insert_leave') then
    local group = utils.create_augroup('RTFormatGroup', true)
    vim.api.nvim_create_autocmd('InsertLeave', {
      group = group,
      buffer = 0,
      callback = M.on_insert_leave,
      desc = 'RT Format: Format on insert leave'
    })
  end

  utils.set_buf_var('rtf_enable', true)
  utils.info_msg('is enabled in current buffer, exit with :RTFormatDisable')

  return true
end

-- Disable RT Format for current buffer
function M.disable()
  if utils.get_buf_var('rtf_enable', false) then
    local key = state.enable_ctrl_enter and '<C-CR>' or '<CR>'
    utils.safe_keymap_del('i', key, { buffer = true })
    utils.debug_log('Disabled RTFormat key mapping: ' .. key)

    -- Clear autocommands
    vim.api.nvim_clear_autocmds({ group = 'RTFormatGroup' })
  end

  utils.set_buf_var('rtf_enable', false)
  utils.info_msg('is disabled in current buffer')

  return true
end

-- Initialize core module
function M.setup()
  if state.initialized then
    return
  end

  -- Create user commands
  vim.api.nvim_create_user_command('RTFormatEnable', M.enable, {
    desc = 'Enable RT Format for current buffer'
  })

  vim.api.nvim_create_user_command('RTFormatDisable', M.disable, {
    desc = 'Disable RT Format for current buffer'
  })

  -- Auto-enable for supported files if configured
  if config.get('auto_enable') then
    local auto_group = utils.create_augroup('RTFormatAuto', true)
    vim.api.nvim_create_autocmd('FileType', {
      group = auto_group,
      pattern = config.get('supported_filetypes'),
      callback = function()
        vim.schedule(M.enable)
      end,
      desc = 'RT Format: Auto-enable for supported filetypes'
    })
  end

  state.initialized = true
  utils.debug_log('Core module initialized')
end

-- Get current state for debugging
function M.get_state()
  return {
    enable_ctrl_enter = state.enable_ctrl_enter,
    initialized = state.initialized,
    buffer_enabled = utils.get_buf_var('rtf_enable', false)
  }
end

return M
