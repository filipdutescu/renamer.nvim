local utils = {}

utils.exec_in_normal = function(callback, opts, ...)
    vim.cmd [[stopinsert]]
    callback(...)

    if opts and opts.keep_insert then
        vim.api.nvim_feedkeys('i', 'n', true)
    end
end

utils.set_cursor_to_end = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, {}, 'A', 'n', true)
end

utils.set_cursor_to_start = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, {}, 'I', 'n', true)
end

utils.set_cursor_to_word_end = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, { keep_insert = true }, 'e', 'n', true)
end

utils.set_cursor_to_word_start = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, { keep_insert = true }, 'b', 'n', true)
end

utils.clear_line = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, { keep_insert = true }, '0C', 'n', true)
end

utils.undo = function()
    utils.exec_in_normal(vim.api.nvim_feedkeys, { keep_insert = true }, 'u', 't', true)
end

utils.redo = function()
    utils.exec_in_normal(function()
        local key = vim.api.nvim_replace_termcodes('<c-r>', true, false, true)
        vim.api.nvim_feedkeys(key, 't', true)
    end, {
        keep_insert = true,
    })
end

return utils
