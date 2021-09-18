local log = require'plenary.log'.new {
    plugin = 'renamer',
    level = 'warn',
}
local popup = require'plenary.popup'
local utils = require'renamer.utils'

local renamer = {}

function renamer.setup(opts)
    opts = opts or {}

    local defaults = require'renamer.defaults'

    renamer.title = utils.get_value_or_default(opts, 'title', defaults.title)
    renamer.padding = utils.get_value_or_default(opts, 'padding', defaults.padding)
    renamer.border = utils.get_value_or_default(opts, 'border', defaults.border)
    renamer.border_chars = utils.get_value_or_default(opts, 'border_chars', defaults.border_chars)
    renamer.prefix = utils.get_value_or_default(opts, 'prefix', defaults.prefix)

    renamer._buffers = {}
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
        borderchars = renamer.border_chars,
        width = #renamer.title + 4,
        line = line + 1,
        col = word_start + math.floor((word_end - word_start) / 2),
        cursor_line = true,
        enter = true,
        callback = function() print('Hello World!') end,
    }
    local prompt_win_id, prompt_opts = popup.create(cword, popup_opts)
    renamer._buffers[prompt_win_id] = prompt_opts

    renamer._setup_window(prompt_win_id)
    renamer._set_prompt_win_style(prompt_win_id)
end

function renamer.on_close(window_id)
    local delete_window = function(win_id)
        if win_id and vim.api.nvim_win_is_valid(win_id) then
            local buf_id = vim.api.nvim_win_get_buf(win_id)
            if vim.api.nvim_buf_is_valid(buf_id) and not vim.api.nvim_buf_get_option(buf_id, 'buflisted') then
                vim.cmd(string.format('silent! bdelete! %s', buf_id))
            end

            if vim.api.nvim_win_is_valid(win_id) then
                vim.api.nvim_win_close(win_id, true)
                if not pcall(vim.api.nvim_win_close, win_id, true) then
                   log.trace('Failed to close window: rename_prompt_win/' .. win_id)
                end
            end
        end

        if win_id and renamer._buffers and renamer._buffers[win_id] then
            renamer._buffers[win_id] = nil
            renamer._delete_autocmds()
        end
    end

    local opts = renamer._buffers[window_id]
    local border_win_id = opts and opts.border and opts.border.win_id
    delete_window(window_id)
    delete_window(border_win_id)
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

function renamer._setup_window(prompt_win_id)
    local prompt_buf_id = vim.api.nvim_win_get_buf(prompt_win_id)

    vim.api.nvim_win_set_option(prompt_win_id, 'wrap', false)
    vim.api.nvim_win_set_option(prompt_win_id, 'winblend', 0)
    if renamer.prefix ~= '' then
        vim.api.nvim_buf_set_option(prompt_win_id, 'buftype', 'prompt')
        vim.fn.prompt_setprompt(prompt_buf_id, renamer.prefix)
    end

    vim.cmd [[startinsert]]
    renamer._create_autocmds(prompt_win_id)
end

function renamer._set_prompt_win_style(prompt_win_id)
    if prompt_win_id then
        vim.api.nvim_win_set_option(prompt_win_id, 'winhl', 'Normal:RenamerNormal')
        vim.api.nvim_win_set_option(prompt_win_id, 'winblend', 0)

        if renamer._buffers and renamer._buffers[prompt_win_id] then
            local opts = renamer._buffers[prompt_win_id]
            local border_win_id = opts.border and opts.border.win_id

            renamer._set_prompt_border_win_style(border_win_id)
        end
    end
end

function renamer._set_prompt_border_win_style(prompt_border_win_id)
   if prompt_border_win_id then
        vim.api.nvim_win_set_option(prompt_border_win_id, 'winhl', 'Normal:RenamerNormal')
        vim.api.nvim_win_set_option(prompt_border_win_id, 'winblend', 0)
   end
end

function renamer._create_autocmds(prompt_win_id)
    local on_leave = string.format(
        [[  autocmd BufLeave,WinLeave,InsertLeave <buffer> ++nested ++once :silent lua require'renamer'.on_close(%s)]],
        prompt_win_id
    )
    vim.cmd [[augroup RenamerInsert]]
    vim.cmd [[  au!]]
    vim.cmd(on_leave)
    vim.cmd [[augroup end]]
end

function renamer._delete_autocmds()
    vim.cmd [[augroup RenamerInsert]]
    vim.cmd [[  au!]]
    vim.cmd [[augroup end]]
end

return renamer

