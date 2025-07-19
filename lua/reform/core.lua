-- Core formatting logic for Reform
local M = {}

local config = require("reform.config")
local formatters = require("reform.formatters")

-- Lazy-loaded utils module
local utils = nil
local function get_utils()
  if not utils then
    utils = require("reform.utils")
  end
  return utils
end

-- Module state
local state = {
  enable_ctrl_enter = false,
  initialized = false,
}

-- Format a single line
function M.format_line(text, filetype)
  if not text or text == "" then
    return text
  end

  local lutils = get_utils()
  local head, body = lutils.parse_line(text)
  if body == "" then
    return text
  end

  lutils.debug_log("Formatting line for filetype: " .. filetype)

  return lutils.time_function("format_line", function()
    local formatted_body = formatters.format(body, filetype)
    return head .. formatted_body
  end)
end

-- Main formatting function triggered by ENTER
function M.real_time_format_code()
  local filetype = vim.bo.filetype
  local lutils = get_utils()

  -- Check if we're at the end of a non-empty line
  if lutils.at_line_end() then
    local line = vim.api.nvim_get_current_line()
    local formatted = M.format_line(line, filetype)

    if line == formatted then
      return "<CR>"
    end

    -- Store formatted text in module state for the key mapping to use
    lutils.set_buf_var("rtformat_text", formatted)

    local keys = ""

    -- This sequence uses module-level state management
    -- 1. Set a flag to prevent InsertLeave recursion via module state
    -- 2. Create an undo point
    -- 3. Exit insert mode, Substitute line
    -- 4. Exit again to make sure cursor at head of the line, insert
    -- 5. Insert the formatted text from module state
    -- 6. Reset the flag
    -- 7. Insert the newline
    keys = keys .. '<Cmd>lua require("reform.utils").set_buf_var("rtformat_insert_leave", 1)<CR>'
    keys = keys .. "<C-g>u<Esc>S"
    keys = keys .. "<Esc>i"
    keys = keys .. '<C-R>=v:lua.require("reform.utils").get_buf_var("rtformat_text", "")<CR>'
    keys = keys .. '<Cmd>lua require("reform.utils").set_buf_var("rtformat_insert_leave", 0)<CR>'
    keys = keys .. "<CR>"
    return keys
  end

  -- Normal ENTER behavior
  return "<CR>"
end

-- Handle InsertLeave event for additional formatting
function M.on_insert_leave()
  local lutils = get_utils()
  if lutils.get_buf_var("rtformat_insert_leave", 0) == 1 then
    return
  end

  local mode = lutils.get_mode()
  if mode:match("^i") then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local filetype = vim.bo.filetype
  local head, body = lutils.parse_line(line)
  local formatted_body = formatters.format(body, filetype)

  if body == formatted_body then
    return
  end

  lutils.debug_log("Formatting on InsertLeave")

  -- Handle multiline formatting result
  local formatted_line = head .. formatted_body
  lutils.set_buf_var("rtformat_insert_leave", 1)

  if formatted_body:find("\n") then
    lutils.insert_multiline(formatted_body, true)
  else
    vim.api.nvim_set_current_line(formatted_line)
  end

  lutils.set_buf_var("rtformat_insert_leave", 0)
end

-- Check if plugin can be enabled for current buffer
function M.check_enable()
  local lutils = get_utils()
  local filetype = vim.bo.filetype

  if not filetype or filetype == "" then
    lutils.error_msg("No filetype detected")
    return false
  end

  -- Check if formatter is available
  local available, err = formatters.is_available(filetype)
  if not available then
    lutils.error_msg(err or ("Formatter not available for " .. filetype))
    return false
  end

  return true
end

-- Enable RT Format for current buffer
function M.enable()
  local lutils = get_utils()
  -- Check is already enabled
  if lutils.get_buf_var("rtf_enable", 0) == 1 then
    lutils.info_msg("is already running in current buffer")
    return false
  end

  if not M.check_enable() then
    return false
  end

  -- local key = config.get('ctrl_enter') and '<C-CR>' or '<CR>'
  -- state.enable_ctrl_enter = config.get('ctrl_enter')

  -- utils.debug_log('Enabling Reform with key: ' .. key)

  -- Set up key mapping, for calling to reform
  vim.keymap.set("i", "<CR>", M.real_time_format_code, {
    buffer = 0,
    expr = true,
    silent = true,
    desc = "RT Format: Real-time code formatting",
  })

  -- Set up autocommand for InsertLeave
  if config.get("on_insert_leave") then
    local group = lutils.create_augroup("RTFormatGroup", true)
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      buffer = 0,
      callback = M.on_insert_leave,
      desc = "RT Format: Format on insert leave",
    })
  end

  lutils.set_buf_var("rtf_enable", 1)
  lutils.info_msg("is enabled in current buffer, exit with :RTFormatDisable")

  return true
end

-- Disable RT Format for current buffer
function M.disable()
  local lutils = get_utils()
  if lutils.get_buf_var("rtf_enable", 0) == 1 then
    -- local key = state.enable_ctrl_enter and '<C-CR>' or '<CR>'
    -- utils.safe_keymap_del('i', '<CR>', { buffer = true })

    -- delete keymapping
    vim.keymap.del("i", "<CR>", { buffer = 0 })
    -- reset <CR> to ensure disable
    vim.keymap.set("i", "<CR>", "<CR>", { buffer = 0, expr = false })

    lutils.debug_log("Disabled RTFormat key mapping: <CR>")

    -- Clear autocommands
    vim.api.nvim_clear_autocmds({ group = "RTFormatGroup" })

    lutils.set_buf_var("rtf_enable", 0)
    lutils.info_msg("is disabled in current buffer")
    return true
  end
  lutils.error_msg("is not running in current buffer")
  return true
end

-- Initialize core module
function M.setup()
  if state.initialized then
    return
  end

  local lutils = get_utils()

  -- Create user commands
  vim.api.nvim_create_user_command("RTFormatEnable", M.enable, {
    desc = "Enable RT Format for current buffer",
  })

  vim.api.nvim_create_user_command("RTFormatDisable", M.disable, {
    desc = "Disable RT Format for current buffer",
  })

  -- Auto-enable for configured filetypes
  if config.get("auto_enable").enabled then
    local auto_group = lutils.create_augroup("RTFormatAuto", true)

    -- Use multiple events for better coverage
    local events = { "FileType" }
    for _, event in ipairs(events) do
      vim.api.nvim_create_autocmd(event, {
        group = auto_group,
        callback = function(args)
          local filetype = vim.bo[args.buf].filetype
          if not config.should_auto_enable(filetype) then
            goto continue
          end
          -- Check if formatter is available before auto-enabling
          local available, err = formatters.is_available(filetype)
          if not available then
            lutils.debug_log("Skipping auto-enable for " .. filetype .. ": " .. (err or "formatter not available"))
            goto continue
          end
          vim.schedule(function()
            -- Check if not already enabled for this buffer
            if lutils.get_buf_var("rtf_enable", 0) ~= 1 then
              local success = M.enable()
              if not success then
                lutils.debug_log("Failed to auto-enable for " .. filetype)
              end
            end
          end)
          ::continue::
        end,
        desc = "RT Format: Auto-enable for configured filetypes",
      })
    end
  end

  state.initialized = true
  lutils.debug_log("Core module initialized")
end

-- Get current state for debugging
function M.get_state()
  local lutils = get_utils()
  return {
    enable_ctrl_enter = state.enable_ctrl_enter,
    initialized = state.initialized,
    buffer_enabled = lutils.get_buf_var("rtf_enable", 0),
  }
end

return M
