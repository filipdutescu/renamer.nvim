local strings = require('renamer.constants').strings

local utils = {}

utils.exec_in_normal = function(callback, ...)
    vim.api.nvim_command(strings.stopinsert_command)
    callback(...)
end

utils.set_cursor_to_end = function()
    utils.exec_in_normal(vim.api.nvim_input, 'A')
end

utils.set_cursor_to_start = function()
    utils.exec_in_normal(vim.api.nvim_input, 'I')
end

utils.set_cursor_to_word_end = function()
    utils.exec_in_normal(vim.api.nvim_input, 'ei')
end

utils.set_cursor_to_word_start = function()
    utils.exec_in_normal(vim.api.nvim_input, 'bi')
end

utils.clear_line = function()
    utils.exec_in_normal(vim.api.nvim_input, '0C')
end

utils.undo = function()
    utils.exec_in_normal(vim.api.nvim_input, 'ui')
end

utils.redo = function()
    utils.exec_in_normal(vim.api.nvim_input, '<c-r>i')
end

return utils
