local renamer = require 'renamer'

local popup = require 'plenary.popup'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'
local spy = require 'luassert.spy'

local eq = assert.are.same

describe('renamer', function()
    describe('rename', function()
        before_each(function()
            renamer.setup()
        end)

        it('should call `_get_word_boundaries_in_line`', function()
            local expected_cword, expected_line, expected_col = 'test', 1, 2
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_get_cursor.returns { 1, expected_col }
            api_mock.nvim_get_current_line.returns(expected_line)
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_get_mode.returns {}
            stub(vim.fn, 'expand').returns 'test'
            local get_word_boundaries_in_line = stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(get_word_boundaries_in_line).was_called_with(expected_line, expected_cword, expected_col)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should highlight references if `show_refs` is `true`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_get_mode.returns {}
            spy.on(renamer, '_setup_window')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight_internal')
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(document_highlight).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should not highlight references if `show_refs` is not `true`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_get_mode.returns {}
            spy.on(renamer, '_setup_window')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            renamer.setup { show_refs = false }
            local document_highlight = stub(renamer, '_document_highlight_internal')
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(document_highlight).called_less_than(1)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should call `_setup_window`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_get_mode.returns {}
            local setup_window = spy.on(renamer, '_setup_window')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(setup_window).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should call `_set_prompt_win_style`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_get_mode.returns {}
            local set_prompt_win_style = spy.on(renamer, '_set_prompt_win_style')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(set_prompt_win_style).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should call `_create_autocmds`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_get_mode.returns {}
            local create_autocms = spy.on(renamer, '_create_autocmds')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(create_autocms).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should return the buffer ID and the popup options', function()
            local expected_col_no, expected_line_no = 2, 2
            local word_start = 1
            local expected_opts = {
                title = renamer.title,
                padding = renamer.padding,
                border = renamer.border,
                borderchars = renamer.border_chars,
                highlight = 'RenamerNormal',
                borderhighlight = 'RenamerBorder',
                width = #renamer.title + 4,
                line = 'cursor+' .. expected_line_no,
                col = 'cursor-' .. expected_col_no,
                posinvert = false,
                cursor_line = true,
                enter = true,
                initial_mode = 'test',
                initial_pos = {
                    word_start = word_start,
                    col = expected_col_no,
                    line = expected_line_no,
                },
            }
            local expected_border_opts = {}
            local expected_buf_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns { expected_line_no, expected_col_no }
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(expected_line_no + 5)
            api_mock.nvim_get_mode.returns { mode = expected_opts.initial_mode }
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(expected_buf_id, { border = expected_border_opts })

            local buf_id, opts = renamer.rename()

            eq(expected_buf_id, buf_id)
            eq(expected_opts, opts.opts)
            eq(expected_border_opts, opts.border_opts)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should call `mappings.register_bindings`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_get_mode.returns {}
            local mappings = require 'renamer.mappings'
            local register_bindings = spy.on(mappings, 'register_bindings')
            stub(renamer, '_get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight').returns()
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(register_bindings).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)
    end)
end)
