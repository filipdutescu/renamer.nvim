local renamer = require 'renamer'

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

            it('should use cursor line for line position if there is enough space below', function()
                local cursor_line = 1
                local expected_line_no = 2
                local expected_line = 'cursor+' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ cursor_line, 2 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(cursor_line + expected_line_no + 1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
            end)

            it('should use flip line position if at the end of the screen', function()
                local expected_line_no = 2
                local expected_line = 'cursor-' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, 2 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column inside word)', function()
                local expected_col_no = 2
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, expected_col_no + 1 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(expected_col_no, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column at word start)', function()
                local cursor_col = 10
                local expected_col_no = 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, cursor_col })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(cursor_col, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column at word end)', function()
                local cursor_col = 10
                local word_start = 5
                local expected_col_no = cursor_col - word_start + 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, cursor_col })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(word_start, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)
        end)

        describe('without border', function()
            before_each(function()
                renamer.setup({ border = false })
            end)

            it('should use cursor line for line position if there is enough space below', function()
                local cursor_line = 1
                local expected_line_no = 2
                local expected_line = 'cursor+' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ cursor_line, 2 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(cursor_line + expected_line_no + 1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
            end)

            it('should use flip line position if at the end of the screen', function()
                local expected_line_no = 2
                local expected_line = 'cursor-' .. expected_line_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, 2 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_line, opts.opts.line)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column inside word)', function()
                local expected_col_no = 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, expected_col_no + 1 })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(expected_col_no + 1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column at word start)', function()
                local cursor_col = 10
                local expected_col_no = 0
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, cursor_col })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(cursor_col + 1, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)

            it('should set the column position at the begining of the cword (cursor column at word end)', function()
                local cursor_col = 10
                local word_start = 5
                local expected_col_no = cursor_col - word_start + 1
                local expected_col = 'cursor-' .. expected_col_no
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_get_cursor.returns({ 1, cursor_col })
                api_mock.nvim_command.returns()
                api_mock.nvim_buf_line_count.returns(1)
                api_mock.nvim_get_mode.returns({})
                stub(renamer, '_get_word_boundaries_in_line').returns(word_start, 2)
                stub(popup, 'create').returns(1, {})

                local _, opts = renamer.rename()

                eq(expected_col, opts.opts.col)
                mock.revert(api_mock)
            end)
        end)
    end)
end)
