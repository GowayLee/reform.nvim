-- Utility functions for Reform
-- Re-exports all utility modules for backward compatibility

local M = {}

-- Import all utility modules
local log = require('reform.utils.log')
local text = require('reform.utils.text')
local buffer = require('reform.utils.buffer')
local state = require('reform.utils.state')
local autocmd = require('reform.utils.autocmd')
local validation = require('reform.utils.validation')
local system = require('reform.utils.system')

-- Re-export all functions for backward compatibility
-- Messaging and logging
M.error_msg = log.error_msg
M.info_msg = log.info_msg
M.debug_log = log.debug_log
M.time_function = log.time_function

-- Text operations
M.parse_line = text.parse_line
M.at_line_end = text.at_line_end
M.trim = text.trim
M.is_whitespace = text.is_whitespace

-- Buffer operations
M.execute_keys = buffer.execute_keys
M.insert_multiline = buffer.insert_multiline

-- State management
M.get_buf_var = state.get_buf_var
M.set_buf_var = state.set_buf_var
M.get_global_var = state.get_global_var

-- Autocommands
M.create_augroup = autocmd.create_augroup

-- Validation
M.validate_filetype = validation.validate_filetype

-- System utilities
M.completion_visible = system.completion_visible
M.get_mode = system.get_mode
M.deep_copy = system.deep_copy

return M

