local log = require('plenary.log').new {
    plugin = 'renamer',
    level = 'warn',
}
local lsp_utils = require 'vim.lsp.util'
local popup = require 'plenary.popup'
local utils = require 'renamer.utils'
local mappings = require 'renamer.mappings'

--- @class Renamer
--- @field public title string
--- @field public padding integer[]
--- @field public border boolean
--- @field public border_chars string[]
--- @field public show_refs boolean
--- @field private _buffers table
local renamer = {}

--- Setup function to be run by the user. Configures the aspect of the renamer
--- user interface. Used to change things such as the title or border of the
--- popup.
---
--- Usage:
--- <code>
--- require('renamer').setup {
---     -- The popup title, shown if `border` is true
---     title = 'Rename',
---     -- The padding around the popup content
---     padding = { 0, 0, 0, 0 },
---     -- Whether or not to shown a border around the popup
---     border = true,
---     -- The characters which make up the border
---     border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
---     -- Whether or not to highlight the current word references through LSP
---     show_refs = true,
---     -- The keymaps available while in the `renamer` buffer. The example below
---     -- overrides the default values, but you can add others as well.
---     mappings = {
---         ['<c-i>'] = require('renamer.mappings.utils').set_cursor_to_start,
---         ['<c-a>'] = require('renamer.mappings.utils').set_cursor_to_end,
---         ['<c-e>'] = require('renamer.mappings.utils').set_cursor_to_word_end,
---         ['<c-b>'] = require('renamer.mappings.utils').set_cursor_to_word_start,
---         ['<c-c>'] = require('renamer.mappings.utils').clear_line,
---         ['<c-u>'] = require('renamer.mappings.utils').undo,
---         ['<c-r>'] = require('renamer.mappings.utils').redo,
---     },
--- }
--- </code>
--- @param opts Defaults Configuration options, see `renamer.defaults`.
function renamer.setup(opts)
    opts = opts or {}

    local defaults = require 'renamer.defaults'

    renamer.title = utils.get_value_or_default(opts, 'title', defaults.title)
    renamer.padding = utils.get_value_or_default(opts, 'padding', defaults.padding)
    renamer.border = utils.get_value_or_default(opts, 'border', defaults.border)
    renamer.border_chars = utils.get_value_or_default(opts, 'border_chars', defaults.border_chars)
    renamer.show_refs = utils.get_value_or_default(opts, 'show_refs', defaults.show_refs)
    mappings.bindings = utils.get_value_or_default(opts, 'mappings', mappings.bindings)

    renamer._buffers = {}
    log.info 'Finished setup.'
end

--- Function that renames the word under the cursor, using Neovim's built in
--- LSP feature (`vim.lsp.buf.rename()`). Creates a popup next to the cursor,
--- starting at the beginning of the word.
---
--- The popup is drawn below the current line, if there is enough space,
--- otherwise on the one above it.
---
--- Usage:
--- <code>
--- require('renamer').rename()
--- </code>
--- @return integer prompt_window_id
--- @return table prompt_window_opts @Keys: opts, border_opts
function renamer.rename()
    local cword = vim.fn.expand '<cword>'
    local line, col = renamer._get_cursor()
    local word_start, _ = utils.get_word_boundaries_in_line(vim.api.nvim_get_current_line(), cword, col + 1)
    local prompt_col_no, prompt_line_no = col - word_start + 1, 2
    local lines_from_win_end = vim.api.nvim_buf_line_count(0) - line
    local border_highlight = 'RenamerBorder'
    local width, win_width = 0, vim.api.nvim_win_get_width(0)
    if renamer.title then
        width = #renamer.title + 4
    end

    if not (renamer.border == true) then
        prompt_line_no = 1
        border_highlight = nil
    end
    if lines_from_win_end < prompt_line_no + 1 then
        prompt_line_no = -prompt_line_no
    end
    if #cword > width then
        width = #cword
    end
    if word_start + width >= win_width then
        prompt_col_no = prompt_col_no + width - win_width + word_start
        if renamer.border == true then
            prompt_col_no = prompt_col_no + 4
        end
    end

    renamer._document_highlight()

    local popup_opts = {
        title = renamer.title,
        titlehighlight = 'RenamerTitle',
        padding = renamer.padding,
        border = renamer.border,
        borderchars = renamer.border_chars,
        highlight = 'RenamerNormal',
        borderhighlight = border_highlight,
        width = width,
        line = (prompt_line_no >= 0 and 'cursor+' or 'cursor') .. prompt_line_no,
        col = 'cursor-' .. prompt_col_no,
        posinvert = false,
        cursor_line = true,
        enter = true,
        initial_word = cword,
        initial_mode = vim.api.nvim_get_mode().mode,
        initial_pos = {
            word_start = word_start,
            col = col,
            line = line,
        },
    }
    local prompt_win_id, prompt_opts = popup.create(cword, popup_opts)

    renamer._buffers[prompt_win_id] = {
        opts = popup_opts,
        border_opts = prompt_opts.border,
    }
    log.fmt_info('Created "plenary" popup, with options: %s', vim.inspect(renamer._buffers[prompt_win_id]))

    renamer._setup_window(prompt_win_id)
    log.trace 'Finished setting up the popup.'
    renamer._set_prompt_win_style(prompt_win_id)
    log.trace 'Finished styling the popup.'

    return prompt_win_id, renamer._buffers[prompt_win_id]
end

function renamer.on_submit(window_id)
    if window_id and renamer._buffers and renamer._buffers[window_id] then
        local opts = renamer._buffers[window_id].opts
        local pos = opts and opts.initial_pos
        local buf_id = vim.api.nvim_win_get_buf(window_id)
        local new_word = vim.api.nvim_buf_get_lines(buf_id, -2, -1, false)[1]

        renamer._delete_autocmds()
        if not (new_word == '') then
            log.fmt_info('Submitted word: "%s".', new_word)
            renamer.on_close(window_id, false)
            renamer._lsp_rename(new_word, pos)
        else
            renamer.on_close(window_id, true)
            log.fmt_error('Cannot rename "%s" to and empty string.', opts.initial_word)
        end
    end
end

function renamer.on_close(window_id, should_set_cursor_pos)
    if should_set_cursor_pos == nil then
        should_set_cursor_pos = true
    end
    local settings = renamer._buffers and renamer._buffers[window_id]
    local border_win_id = settings and settings.border_opts and settings.border_opts.win_id
    local initial_mode = settings and settings.opts and settings.opts.initial_mode
    local pos = settings and settings.opts and settings.opts.initial_pos

    renamer._delete_window(window_id)
    log.fmt_info('Deleted window: "%s".', window_id)
    renamer._delete_window(border_win_id)
    log.fmt_info('Deleted window: "%s" (border).', border_win_id)

    renamer._clear_references()
    if initial_mode and not string.match(initial_mode, 'i') then
        vim.api.nvim_command [[stopinsert]]
    end

    if should_set_cursor_pos and pos then
        local col = pos.col
        if initial_mode and not string.match(initial_mode, 'i') then
            col = col + 1
        end
        vim.api.nvim_win_set_cursor(0, { pos.line, col })
    end
end

function renamer._get_cursor()
    -- [[
    -- `cursor` is an array of two elements with the following semnification:
    --      - *`cursor[1]`* - the current cursor line
    --      - *`cursor[2]`* - the current cursor column
    -- ]]
    local cursor = vim.api.nvim_win_get_cursor(0)

    return cursor[1], cursor[2]
end

function renamer._setup_window(prompt_win_id)
    local prompt_buf_id = vim.api.nvim_win_get_buf(prompt_win_id)

    vim.api.nvim_win_set_option(prompt_win_id, 'wrap', false)
    vim.api.nvim_win_set_option(prompt_win_id, 'winblend', 0)

    vim.api.nvim_command [[startinsert]]
    renamer._create_autocmds(prompt_win_id)

    vim.api.nvim_buf_set_keymap(
        prompt_buf_id,
        'i',
        '<cr>',
        "<cmd>lua require('renamer').on_submit(" .. prompt_win_id .. ')<cr>',
        { noremap = true }
    )
    vim.api.nvim_buf_set_keymap(
        prompt_buf_id,
        'i',
        '<esc>',
        "<cmd>lua require('renamer').on_close(" .. prompt_win_id .. ')<cr>',
        { noremap = true }
    )
    mappings.register_bindings(prompt_buf_id)
end

function renamer._set_prompt_win_style(prompt_win_id)
    if prompt_win_id then
        vim.api.nvim_win_set_option(prompt_win_id, 'wrap', false)
        vim.api.nvim_win_set_option(prompt_win_id, 'winblend', 0)

        if renamer._buffers and renamer._buffers[prompt_win_id] then
            local opts = renamer._buffers[prompt_win_id]
            local border_win_id = opts.border_opts and opts.border_opts.win_id

            renamer._set_prompt_border_win_style(border_win_id)
        end
    end
end

function renamer._set_prompt_border_win_style(prompt_border_win_id)
    if prompt_border_win_id then
        vim.api.nvim_win_set_option(prompt_border_win_id, 'wrap', false)
        vim.api.nvim_win_set_option(prompt_border_win_id, 'winblend', 0)
    end
end

function renamer._create_autocmds(prompt_win_id)
    local on_leave = string.format(
        [[  autocmd BufLeave,WinLeave <buffer> ++nested ++once :silent lua require'renamer'.on_close(%s)]],
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

function renamer._lsp_rename(word, pos)
    local params = renamer._make_position_params()

    renamer._buf_request(0, 'textDocument/prepareRename', params, function(prep_err, prep_resp)
        if prep_err == nil and prep_resp == nil then
            log.warn 'Nothing to rename.'
            return
        end
        params.newName = word

        renamer._buf_request(0, 'textDocument/rename', params, function(err, resp)
            if err then
                log.error(err)
                return
            end

            if not resp then
                log.warn 'LSP response is nil.'
                return
            end

            lsp_utils.apply_workspace_edit(resp)

            if pos then
                local col = pos.word_start + #word - 1
                local mode = vim.api.nvim_get_mode().mode
                if mode and not string.match(mode, 'i') then
                    col = col - 1
                end
                vim.api.nvim_win_set_cursor(0, { pos.line, col })
            end
        end)
    end)
end

function renamer._document_highlight()
    if renamer.show_refs then
        renamer._document_highlight_internal()
    end
end

-- Since there is no way to mock `vim.lsp.buf.document_highlight`, this function is used as a replacement.
function renamer._document_highlight_internal()
    vim.lsp.buf.document_highlight()
end

function renamer._delete_window(win_id)
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        if buf_id and vim.api.nvim_buf_is_valid(buf_id) and not vim.api.nvim_buf_get_option(buf_id, 'buflisted') then
            vim.api.nvim_command(string.format('silent! bdelete! %s', buf_id))
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

function renamer._clear_references()
    if renamer.show_refs then
        renamer._clear_references_internal()
    end
end

-- Since there is no way to mock `vim.lsp.buf.clear_references`, this function is used as a replacement.
function renamer._clear_references_internal()
    vim.lsp.buf.clear_references()
end

-- Since there is no way to mock `vim.lsp.buf_request`, this function is used as a replacement
function renamer._make_position_params()
    return lsp_utils.make_position_params()
end

-- Since there is no way to mock `vim.lsp.buf_request`, this function is used as a replacement
function renamer._buf_request(buf_id, method, params, handler)
    vim.lsp.buf_request(buf_id, method, params, handler)
end

return renamer
