local renamer = require 'renamer'
local utils = require 'renamer.utils'

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

        it('should fallback to `vim.fn.input()` if width is too short (with border)', function()
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(2)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            stub(renamer, '_clear_references_internal')
            local document_highlight = stub(renamer, '_document_highlight')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should fallback to `vim.fn.input()` if width is too short (without border)', function()
            renamer.setup { border = false }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(1)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            local document_highlight = stub(renamer, '_document_highlight')
            stub(renamer, '_clear_references').returns()
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should fallback to `vim.fn.input()` if height is too short (with border)', function()
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(3)
            api_mock.nvim_win_get_width.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            stub(renamer, '_clear_references_internal')
            local document_highlight = stub(renamer, '_document_highlight')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should fallback to `vim.fn.input()` if height is too short (without border)', function()
            renamer.setup { border = false }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(3)
            api_mock.nvim_win_get_width.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            stub(renamer, '_clear_references_internal')
            local document_highlight = stub(renamer, '_document_highlight')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should fallback to `vim.fn.input()` if padding is too large (with border)', function()
            renamer.setup {
                padding = {
                    top = 20,
                    left = 20,
                    bottom = 20,
                    right = 20,
                },
            }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            stub(renamer, '_clear_references_internal')
            local document_highlight = stub(renamer, '_document_highlight')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should fallback to `vim.fn.input()` if padding is too large (without border)', function()
            renamer.setup {
                border = false,
                padding = {
                    top = 20,
                    left = 20,
                    bottom = 20,
                    right = 20,
                },
            }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            stub(renamer, '_clear_references_internal')
            local document_highlight = stub(renamer, '_document_highlight')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should use `vim.fn.input()` if "with_popup" is `false`', function()
            renamer.setup { with_popup = false }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(1)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input').returns 'abc'
            local rename = stub(renamer, '_lsp_rename').returns()
            local document_highlight = stub(renamer, '_document_highlight')
            stub(renamer, '_clear_references').returns()
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_least(1)
            assert.spy(rename).called_at_most(1)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should not rename if no input is received ("with_popup" is `true`)', function()
            renamer.setup { with_popup = false }
            local expected_cword = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_cursor.returns()
            api_mock.nvim_win_get_height.returns(15)
            api_mock.nvim_win_get_width.returns(1)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            api_mock.nvim_win_get_cursor.returns { 1, 1 }
            api_mock.nvim_buf_line_count.returns(10)
            stub(vim.fn, 'expand').returns(expected_cword)
            local input = stub(vim.fn, 'input')
            local rename = stub(renamer, '_lsp_rename').returns()
            local document_highlight = stub(renamer, '_document_highlight')
            stub(renamer, '_clear_references').returns()
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local create = stub(popup, 'create')

            renamer.rename()

            assert.spy(input).was_called_with('Rename "' .. expected_cword .. '" to: ')
            assert.spy(rename).called_at_most(0)
            assert.spy(create).called_at_most(0)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should call `utils.get_word_boundaries_in_line`', function()
            local expected_cword, expected_line, expected_col = 'test', 1, 2
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_get_cursor.returns { 1, expected_col }
            api_mock.nvim_get_current_line.returns(expected_line)
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_get_mode.returns {}
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            stub(vim.fn, 'expand').returns 'test'
            local get_word_boundaries_in_line = stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(get_word_boundaries_in_line).was_called_with(expected_line, expected_cword, expected_col + 1)
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should highlight references if `show_refs` is `true`', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_command.returns()
            api_mock.nvim_buf_line_count.returns(1)
            api_mock.nvim_win_get_cursor.returns { 1, 2 }
            api_mock.nvim_get_mode.returns {}
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            spy.on(renamer, '_setup_window')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            spy.on(renamer, '_setup_window')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            local setup_window = spy.on(renamer, '_setup_window')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            local set_prompt_win_style = spy.on(renamer, '_set_prompt_win_style')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            local create_autocms = spy.on(renamer, '_create_autocmds')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(create_autocms).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)

        it('should return the buffer ID and the popup options', function()
            local expected_col_no, expected_line_no = 2, 2
            local word_start = 1
            local p = renamer.padding
            local expected_opts = {
                title = renamer.title,
                titlehighlight = 'RenamerTitle',
                padding = { p.top, p.right, p.bottom, p.left },
                border = renamer.border,
                borderchars = renamer.border_chars,
                highlight = 'RenamerNormal',
                borderhighlight = 'RenamerBorder',
                width = #renamer.title + 4,
                line = 'cursor+' .. expected_line_no,
                col = 'cursor-' .. expected_col_no,
                minwidth = 15,
                maxwidth = 45,
                minheight = 1,
                posinvert = false,
                cursor_line = true,
                enter = true,
                initial_word = 'test',
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
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
            api_mock.nvim_win_get_width.returns(100)
            api_mock.nvim_win_get_height.returns(10)
            api_mock.nvim_get_mode.returns { mode = 'n' }
            local mappings = require 'renamer.mappings'
            local register_bindings = spy.on(mappings, 'register_bindings')
            stub(utils, 'get_word_boundaries_in_line').returns(1, 2)
            local document_highlight = stub(renamer, '_document_highlight')
            stub(popup, 'create').returns(1, {})

            renamer.rename()

            assert.spy(register_bindings).was_called()
            mock.revert(api_mock)
            document_highlight.revert(document_highlight)
        end)
    end)
end)
