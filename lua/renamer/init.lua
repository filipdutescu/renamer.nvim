local popup = require'plenary.popup'
local utils = require'renamer.utils'

local renamer = {}

function renamer.setup(opts)
    opts = opts or {}

    local defaults = require'renamer.defaults'

    renamer.title = utils.get_value_or_default(opts, 'title', defaults.title)
    renamer.padding = utils.get_value_or_default(opts, 'padding', defaults.padding)
    renamer.border = utils.get_value_or_default(opts, 'border', defaults.border)
    renamer.prefix = utils.get_value_or_default(opts, 'prefix', defaults.prefix)
end

function renamer.rename(word)
    local cword = word or vim.fn.expand('<cword>')
    local line, col = renamer._get_cursor()
    local word_start, word_end = renamer._get_word_boundaries_in_line(
        vim.api.nvim_get_current_line(),
        cword,
        col
    )

    local popup_opts = {
        title = renamer.title,
        padding = renamer.padding,
        border = renamer.border,
        width = #renamer.title + 4,
        line = line + 1,
        col = word_start + math.floor((word_end - word_start) / 2),
        cursor_line = true,
        enter = true,
        callback = function() print('Hello World!') end,
    }
    local prompt_buf_no, prompt_opt = popup.create(cword, popup_opts)
    local prompt_buf = vim.api.nvim_win_get_buf(prompt_buf_no)
    vim.api.nvim_win_set_option(prompt_buf_no, 'buftype', 'prompt')
    vim.fn.prompt_setprompt(prompt_buf, renamer.prefix)
    vim.cmd [[startinsert]]
end

function renamer._get_cursor()
    --[[
    --  'cursor' is a list containing 2 elements, with the following meaning:
    --      * 'cursor[1]' - The current line number
    --      * 'cursor[2]' - The current column number
    --]]
    local cursor = vim.api.nvim_win_get_cursor(0)

    return cursor[1], cursor[2]
end

function renamer._get_word_boundaries_in_line(line, word, line_pos)
    local i = 1
    local word_start, word_end = string.find(line, word, line_pos - i)

    while word_end == nil or line_pos - i < 0 do
        i = i + 1
        word_start, word_end = string.find(line, word, line_pos - i)
    end

    return word_start, word_end
end

return renamer

