local strings = require('renamer.constants').strings
local renamer = require 'renamer'
local utils = require 'renamer.utils'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'
local spy = require 'luassert.spy'

local eq = assert.are.same

describe('_rename_handler', function()
    local log = nil

    before_each(function()
        renamer.setup { with_qf_list = false }
        log = mock(renamer._log)
    end)

    after_each(function()
        mock.revert(log)
    end)

    it('should not apply changes if error is received', function()
        local nvim_handler = spy.on(renamer, '_nvim_rename_handler')

        renamer._rename_handler('error', nil, { method = strings.lsp_req_rename })

        assert.spy(nvim_handler).called_less_than(1)
    end)

    it('should not apply changes if no response is received', function()
        local nvim_handler = spy.on(renamer, '_nvim_rename_handler')

        renamer._rename_handler(nil, nil, { method = strings.lsp_req_rename })

        assert.spy(nvim_handler).called_less_than(1)
    end)

    it('should apply changes if no error is received', function()
        local expected_response = 'test'
        local nvim_handler = stub(renamer, '_nvim_rename_handler')

        renamer._rename_handler(nil, expected_response, { method = strings.lsp_req_rename })

        assert.spy(nvim_handler).was_called_with(nil, expected_response, { method = strings.lsp_req_rename })
        nvim_handler.revert(nvim_handler)
    end)

    it('should call the custom handler if it is set', function()
        local custom_handler_called = false
        renamer.setup {
            with_qf_list = false,
            handler = function()
                custom_handler_called = true
            end,
        }
        local expected_response = 'test'
        local nvim_handler = stub(renamer, '_nvim_rename_handler')

        renamer._rename_handler(nil, expected_response, { method = strings.lsp_req_rename })

        eq(true, custom_handler_called)
        assert.spy(nvim_handler).was_called_with(nil, expected_response, { method = strings.lsp_req_rename })
        nvim_handler.revert(nvim_handler)
    end)

    it('should set qf list if the option is turned on', function()
        renamer.setup()
        local expected_response = { changes = 'test' }
        local nvim_handler = stub(renamer, '_nvim_rename_handler')
        local set_qflist = stub(utils, 'set_qf_list')

        renamer._rename_handler(nil, expected_response, { method = strings.lsp_req_rename })

        assert.spy(nvim_handler).was_called_with(nil, expected_response, { method = strings.lsp_req_rename })
        assert.spy(set_qflist).was_called_with(expected_response.changes)
        nvim_handler.revert(nvim_handler)
        set_qflist.revert(set_qflist)
    end)

    it('should set cursor after the end of the new word', function()
        local expected_response = 'test'
        local nvim_handler = stub(renamer, '_nvim_rename_handler')
        local api_mock = mock(vim.api, true)
        api_mock.nvim_get_mode.returns { mode = strings.insert_mode_short_string }
        local expected_pos = { word_start = 1, line = 1, col = 1 }
        local expected_col = expected_pos.word_start + #expected_response - 1
        renamer._current_op = { word = 'test', pos = expected_pos }

        renamer._rename_handler(nil, expected_response, { method = strings.lsp_req_rename })

        assert.spy(api_mock.nvim_win_set_cursor).was_called_with(0, { expected_pos.line, expected_col })
        assert.spy(nvim_handler).was_called_with(nil, expected_response, { method = strings.lsp_req_rename })
        mock.revert(api_mock)
        nvim_handler.revert(nvim_handler)
    end)

    it('should set cursor after the end of the new word (normal mode)', function()
        local expected_response = 'test'
        local nvim_handler = stub(renamer, '_nvim_rename_handler')
        local api_mock = mock(vim.api, true)
        api_mock.nvim_get_mode.returns { mode = 'n' }
        local expected_pos = { word_start = 1, line = 1, col = 1 }
        local expected_col = expected_pos.word_start + #expected_response - 2
        renamer._current_op = { word = 'test', pos = expected_pos }

        renamer._rename_handler(nil, expected_response, { method = strings.lsp_req_rename })

        assert.spy(api_mock.nvim_win_set_cursor).was_called_with(0, { expected_pos.line, expected_col })
        assert.spy(nvim_handler).was_called_with(nil, expected_response, { method = strings.lsp_req_rename })
        mock.revert(api_mock)
        nvim_handler.revert(nvim_handler)
    end)
end)
