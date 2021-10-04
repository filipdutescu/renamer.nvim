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
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = {}

            renamer.on_submit(expected_win_id)

            assert.spy(delete_autocmds).was_called()
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)

        it('should call `on_close`', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = {}

            renamer.on_submit(expected_win_id)

            assert.spy(renamer.on_close).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)

        it('should call `_lsp_rename` with buffer content', function()
            local expected_win_id, expected_buf_id = 123, 321
            local expected_content = 'test'
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns({ expected_content })
            api_mock.nvim_command.returns()
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = {}

            renamer.on_submit(expected_win_id)

            assert.spy(renamer._lsp_rename).was_called_with(expected_content)
            assert.spy(renamer.on_close).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)

        it('should stay in insert mode if opened in it', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'i' } }

            renamer.on_submit(expected_win_id)

            assert.spy(api_mock.nvim_command).called_less_than(1)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)

        it('should exit insert mode if not opened in it (initial mode is `normal`)', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'n' } }

            renamer.on_submit(expected_win_id)

            assert.spy(api_mock.nvim_command).was_called_with [[stopinsert]]
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)

        it('should exit insert mode if not opened in it (initial mode is `visual`)', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_get_lines.returns {}
            api_mock.nvim_command.returns()
            stub(renamer, 'on_close').returns()
            stub(renamer, '_lsp_rename').returns()
            renamer._buffers[expected_win_id] = { opts = { initial_mode = 'v' } }

            renamer.on_submit(expected_win_id)

            assert.spy(api_mock.nvim_command).was_called_with [[stopinsert]]
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_get_lines).was_called_with(expected_buf_id, -2, -1, false)
            mock.revert(api_mock)
        end)
    end)

    describe('on_close', function()
        it('should not delete buffers if `window_id` is nil', function()
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns()
            api_mock.nvim_win_get_buf.returns()

            renamer.on_close(nil)

            assert.spy(api_mock.nvim_win_is_valid).called_less_than(1)
            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should not delete buffers if window is invalid', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(false)
            api_mock.nvim_win_get_buf.returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should not delete nil buffer', function()
            local expected_win_id = 123
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns()
            api_mock.nvim_buf_is_valid.returns()
            api_mock.nvim_command.returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).called_less_than(1)
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should not delete invalid buffer', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(false)
            api_mock.nvim_command.returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
        end)

        it('should not delete buffer with the `buflisted` option', function()
            local expected_win_id, expected_buf_id = 123, 321
            local api_mock = mock(vim.api, true)
            api_mock.nvim_win_is_valid.returns(true)
            api_mock.nvim_win_get_buf.returns(expected_buf_id)
            api_mock.nvim_buf_is_valid.returns(true)
            api_mock.nvim_buf_get_option.returns(true)
            api_mock.nvim_command.returns()

            renamer.on_close(expected_win_id)

            assert.spy(api_mock.nvim_win_is_valid).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_win_get_buf).was_called_with(expected_win_id)
            assert.spy(api_mock.nvim_buf_is_valid).was_called_with(expected_buf_id)
            assert.spy(api_mock.nvim_buf_get_option).was_called_with(expected_buf_id, 'buflisted')
            assert.spy(api_mock.nvim_command).called_less_than(1)
            mock.revert(api_mock)
        end)
    end)
end)
