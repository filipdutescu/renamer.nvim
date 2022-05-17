local strings = require('renamer.constants').strings
local renamer = require 'renamer'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'
local spy = require 'luassert.spy'

local eq = assert.are.same

describe('renamer', function()
    before_each(function()
        renamer.setup()
    end)

    describe('on_submit', function()
        it('should do nothing if `window_id` is nil', function()
            local win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns()
            api_mock.nvim_buf_get_lines.returns {}
            renamer._buffers[win_id] = {}

            renamer.on_submit(nil)

            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            assert.spy(api_mock.nvim_buf_get_lines).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should do nothing if `_buffers` is nil', function()
            local win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns()
            api_mock.nvim_buf_get_lines.returns {}
            renamer._buffers = nil

            renamer.on_submit(win_id)

            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            assert.spy(api_mock.nvim_buf_get_lines).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should do nothing if `_buffers[window_id]` is nil', function()
            local win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns()
            api_mock.nvim_buf_get_lines.returns {}
            renamer._buffers = {}

            renamer.on_submit(win_id)

            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            assert.spy(api_mock.nvim_buf_get_lines).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should call `_delete_autocmds`', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            local delete_autocmds = spy.on(renamer, '_delete_autocmds')
            local on_close = stub(renamer, 'on_close').returns()
            local lsp_rename = stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = {}

            renamer.on_submit(expected_win_id)

            assert.spy(delete_autocmds).was_called()
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
            on_close.revert(on_close)
            lsp_rename.revert(lsp_rename)
        end)

        it('should call `on_close`', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            local on_close = stub(renamer, 'on_close').returns()
            local lsp_rename = stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = {}

            renamer.on_submit(expected_win_id)

            assert.spy(renamer.on_close).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
            on_close.revert(on_close)
            lsp_rename.revert(lsp_rename)
        end)

        it('should call `_lsp_rename` with buffer content', function()
            local expected_win_id, expected_buf_id = 123, 321
            local expected_content = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns { expected_content }
            api_mock.nvim_command.returns()
            local on_close = stub(renamer, 'on_close').returns()
            local lsp_rename = stub(renamer, '_lsp_rename').returns()
            local expected_pos = { word_start = 1, line = 1, col = 1 }
            renamer._buffers[expected_win_id] = { opts = { initial_pos = expected_pos } }

            renamer.on_submit(expected_win_id)

            assert.spy(lsp_rename).was_called_with(expected_content, expected_pos)
            assert.spy(on_close).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
            on_close.revert(on_close)
            lsp_rename.revert(lsp_rename)
        end)

        it('should not call `_lsp_rename` if buffer content is an empty string', function()
            local expected_win_id, expected_buf_id = 123, 321
            local expected_content = ''
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns { expected_content }
            api_mock.nvim_command.returns()
            local on_close = stub(renamer, 'on_close').returns()
            local lsp_rename = stub(renamer, '_lsp_rename').returns()
            local expected_pos = { word_start = 1, line = 1, col = 1 }
            renamer._buffers[expected_win_id] = { opts = { initial_word = 'test', initial_pos = expected_pos } }

            renamer.on_submit(expected_win_id)

            assert.spy(lsp_rename).called_less_than(1)
            assert.spy(on_close).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
            on_close.revert(on_close)
            lsp_rename.revert(lsp_rename)
        end)
    end)

    describe('on_close', function()
        it('should not delete buffers if `window_id` is nil', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns()
            api_mock.nvim_win_get_buf.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(nil)

            assert.spy(api_mock.nvim_win_is_valid).called_less_than(1)
            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should not delete buffers if window is invalid', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            api_mock.nvim_win_get_buf.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should not delete nil buffer', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns()
            api_mock.nvim_buf_is_valid.returns()
            api_mock.nvim_command.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).called_less_than(1)
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should not delete invalid buffer', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(false)
            api_mock.nvim_command.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should not delete buffer with the `buflisted` option', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(true)
            api_mock.nvim_command.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, strings.buf_opt_buflisted)
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should delete valid buffer', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(false)
            api_mock.nvim_command.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, strings.buf_opt_buflisted)
            assert.spy(api_mock.nvim_command).was_called_with(
                string.format(strings.buf_delete_command_template, expected_buf_id)
            )
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should delete valid window', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_close.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_close).was_called_with(expected_win_id, true)
            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, strings.buf_opt_buflisted)
            assert.spy(api_mock.nvim_command).was_called_with(
                string.format(strings.buf_delete_command_template, expected_buf_id)
            )
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should delete valid window border', function()
            local expected_win_id, expected_buf_id, expected_border_win_id = 123, 321, 555
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_close.returns()
            local clear_references = stub(renamer, '_clear_references').returns()
            renamer._buffers[expected_win_id] = { border_opts = { win_id = expected_border_win_id } }

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_close).was_called_with(expected_win_id, true)
            assert.spy(api_mock.nvim_win_close).was_called_with(expected_border_win_id, true)
            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_border_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_border_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, strings.buf_opt_buflisted)
            assert.spy(api_mock.nvim_command).was_called_with(
                string.format(strings.buf_delete_command_template, expected_buf_id)
            )
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should delete `_buffers` entry', function()
            local expected_win_id, expected_buf_id, expected_border_win_id = 123, 321, 555
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_close.returns()
            local clear_references = stub(renamer, '_clear_references').returns()
            renamer._buffers[expected_win_id] = { border_opts = { win_id = expected_border_win_id } }

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_close).was_called_with(expected_win_id, true)
            assert.spy(api_mock.nvim_win_close).was_called_with(expected_border_win_id, true)
            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_border_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_border_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, strings.buf_opt_buflisted)
            assert.spy(api_mock.nvim_command).was_called_with(
                string.format(strings.buf_delete_command_template, expected_buf_id)
            )
            eq(nil, renamer._buffers[expected_win_id])
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should clear highlights of the word to be renamed', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_close.returns()
            local clear_references = stub(renamer, '_clear_references').returns()

            renamer.on_close(expected_win_id)

            assert.spy(clear_references).was_called()
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should stay in insert mode if opened in it', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            local clear_references = stub(renamer, '_clear_references').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'i' } }

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should exit insert mode if not opened in it (initial mode is `normal`)', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            local clear_references = stub(renamer, '_clear_references').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'n' } }

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_command).was_called_with(strings.stopinsert_command)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should exit insert mode if not opened in it (initial mode is `visual`)', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            api_mock.nvim_command.returns()
            local clear_references = stub(renamer, '_clear_references').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'v' } }

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_command).was_called_with(strings.stopinsert_command)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it(
            'should set cursor in the initial position (when `rename()` is cancelled) (initial mode: `normal`)',
            function()
                local expected_win_id = 123
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_is_valid.returns(false)
                api_mock.nvim_command.returns()
                api_mock.nvim_win_set_cursor.returns()
                local clear_references = stub(renamer, '_clear_references').returns()
                local expected_pos = { col = 1, line = 1 }
                renamer._buffers[expected_win_id] = { opts = { initial_mode = 'n', initial_pos = expected_pos } }

                renamer.on_close(expected_win_id)

                assert.spy(api_mock.nvim_win_set_cursor).was_called_with(0, {
                    expected_pos.line,
                    expected_pos.col + 1,
                })
                mock.revert(api_mock)
                clear_references.revert(clear_references)
            end
        )

        it(
            'should set cursor in the initial position (when `rename()` is cancelled) (initial mode: `insert`)',
            function()
                local expected_win_id = 123
                local api_mock = mock(vim.api, true)
                api_mock.nvim_win_is_valid.returns(false)
                api_mock.nvim_command.returns()
                api_mock.nvim_win_set_cursor.returns()
                local clear_references = stub(renamer, '_clear_references').returns()
                local expected_pos = { col = 1, line = 1 }
                renamer._buffers[expected_win_id] = { opts = { initial_mode = 'i', initial_pos = expected_pos } }

                renamer.on_close(expected_win_id)

                assert.spy(api_mock.nvim_win_set_cursor).was_called_with(0, { expected_pos.line, expected_pos.col })
                mock.revert(api_mock)
                clear_references.revert(clear_references)
            end
        )

        it('should clear references if `show_refs` is `true`', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_set_cursor.returns()
            local clear_references = stub(renamer, '_clear_references_internal')
            local expected_pos = { col = 1, line = 1 }
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'i', initial_pos = expected_pos } }

            renamer.on_close(expected_win_id)

            assert.spy(clear_references).was_called()
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)

        it('should not clear references if `show_refs` is not `true`', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            api_mock.nvim_command.returns()
            api_mock.nvim_win_set_cursor.returns()
            renamer.setup { show_refs = false }
            local clear_references = stub(renamer, '_clear_references_internal')
            local expected_pos = { col = 1, line = 1 }
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'i', initial_pos = expected_pos } }

            renamer.on_close(expected_win_id)

            assert.spy(clear_references).called_less_than(1)
            mock.revert(api_mock)
            clear_references.revert(clear_references)
        end)
    end)
end)
