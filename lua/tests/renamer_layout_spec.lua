local renamer = require 'renamer'
local utils = require 'renamer.utils'

local popup = require 'plenary.popup'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'
local spy = require 'luassert.spy'

local eq = assert.are.same

describe('renamer', function()
    describe('rename', function()
        describe('with border', function()
            before_each(function()
                renamer.setup()
            end)

            it('should call `_set_prompt_border_win_style`', function()
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, 2 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                local set_prompt_border_win_style = spy.on(renamer, '_set_prompt_border_win_style')
                stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, { border = { win_id = 1 } })

                renamer.rename()

                assert.spy(set_prompt_border_win_style).was_called_with(1)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should use cursor line for line position if there is enough space below', function()
                local cursor_line = 1
                local expected_line_no = 2
                local expected_line = 'cursor+' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { cursor_line, 2 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(cursor_line + expected_line_no + 1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should use flip line position if at the end of the screen', function()
                local expected_line_no = 2
                local expected_line = 'cursor-' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, 2 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column inside word)', function()
                local expected_col_no = 2
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, expected_col_no + 1 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(expected_col_no, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column at word start)', function()
                local cursor_col = 10
                local expected_col_no = 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(cursor_col, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column at word end)', function()
                local cursor_col = 10
                local word_start = 5
                local expected_col_no = cursor_col - word_start + 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(word_start, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position to have enough space to draw popup (cword at window end)', function()
                local cursor_col = 10
                local word_start = 8
                local win_width = 11
                -- no `word_start` as the formula would have `... - word_start ... + word_start`
                local expected_col_no = cursor_col + 1 + #renamer.title + 4 - win_width + 4
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(win_width)
                stub(utils, 'get_word_boundaries_in_line').returns(word_start, word_start + 5)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)
        end)

        describe('without border', function()
            before_each(function()
                renamer.setup { border = false }
            end)

            it('should use cursor line for line position if there is enough space below', function()
                local cursor_line = 1
                local expected_line_no = 1
                local expected_line = 'cursor+' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { cursor_line, 2 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(cursor_line + expected_line_no + 1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should use flip line position if at the end of the screen', function()
                local expected_line_no = 1
                local expected_line = 'cursor-' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, 2 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column inside word)', function()
                local expected_col_no = 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, expected_col_no + 1 }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(expected_col_no + 1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column at word start)', function()
                local cursor_col = 10
                local expected_col_no = 0
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(cursor_col + 1, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position at the begining of the cword (cursor column at word end)', function()
                local cursor_col = 10
                local word_start = 5
                local expected_col_no = cursor_col - word_start + 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(100)
                stub(utils, 'get_word_boundaries_in_line').returns(word_start, 2)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)

            it('should set the column position to have enough space to draw popup (cword at window end)', function()
                local cursor_col = 10
                local word_start = 8
                local win_width = 11
                -- no `word_start` as the formula would have `... - word_start ... + word_start`
                local expected_col_no = cursor_col + 1 + #renamer.title + 4 - win_width
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns { 1, cursor_col }
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns {}
                api_mock.nvim_win_get_width.returns(win_width)
                stub(utils, 'get_word_boundaries_in_line').returns(word_start, word_start + 5)
                local document_highlight = stub(renamer, '_document_highlight').returns()
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
                document_highlight.revert(document_highlight)
            end)
        end)
    end)
end)
