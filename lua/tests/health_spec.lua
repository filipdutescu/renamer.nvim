local renamer = require 'renamer'
local strings = require('renamer.constants').strings
local utils = require 'renamer.utils'
local health = require 'renamer.health'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'

describe('health', function()
    describe('check', function()
        it('should generate error if a required plugin is missing', function()
            stub(vim.fn, 'health#report_error').returns()
            stub(vim.fn, 'health#report_info').returns()
            stub(health, '_is_plugin_installed').returns(false)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.error).was_called_with(string.format(strings.plugin_not_found_template, 'plenary'))
            assert.spy(report_mock.info).was_called_with(strings.missing_required_plugins_err)
            renamer._buffers = nil
            mock.revert(report_mock)
        end)

        it('should generate ok if all the required plugins are installed', function()
            stub(health, '_is_plugin_installed').returns(true)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with(string.format(strings.plugin_installed_template, 'plenary'))
            assert.spy(report_mock.info).was_called_with(strings.found_required_plugins)
            renamer._buffers = nil
            mock.revert(report_mock)
        end)

        it('should warn if setup was not called', function()
            stub(health, '_is_plugin_installed').returns(true)
            local report_mock = mock(health.report, true)

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.warn).was_called_with(strings.setup_not_called_err)
            mock.revert(report_mock)
        end)

        it('should log if setup was called', function()
            stub(health, '_is_plugin_installed').returns(true)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with(strings.setup_called)
            mock.revert(report_mock)
            renamer._buffers = nil
        end)

        it('should warn if no LSP client is attached to the current buffer (nil value)', function()
            stub(health, '_is_plugin_installed').returns(true)
            stub(utils, 'are_lsp_clients_running').returns(false)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with(strings.setup_called)
            assert.spy(report_mock.error).was_called_with(strings.no_lsp_client_found_err)
            mock.revert(report_mock)
            renamer._buffers = nil
        end)

        it('should error if no LSP client is attached (less than 1 client)', function()
            stub(health, '_is_plugin_installed').returns(true)
            stub(utils, 'are_lsp_clients_running').returns(false)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with(strings.setup_called)
            assert.spy(report_mock.error).was_called_with(strings.no_lsp_client_found_err)
            mock.revert(report_mock)
            renamer._buffers = nil
        end)

        it('should log if LSP client is attached', function()
            stub(health, '_is_plugin_installed').returns(true)
            stub(utils, 'are_lsp_clients_running').returns(true)
            local report_mock = mock(health.report, true)
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with(strings.setup_called)
            assert.spy(report_mock.ok).was_called_with(strings.lsp_client_found)
            assert.spy(report_mock.warn).called_less_than(1)
            assert.spy(report_mock.error).called_less_than(1)
            mock.revert(report_mock)
            renamer._buffers = nil
        end)
    end)
end)
