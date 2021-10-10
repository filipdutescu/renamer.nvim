local renamer = require 'renamer'

local mock = require 'luassert.mock'
local stub = require 'luassert.stub'

describe('health', function()
    describe('check', function()
        it('should generate error if a required plugin is missing', function()
            stub(vim.fn, 'health#report_error').returns()
            stub(vim.fn, 'health#report_info').returns()
            local health = require 'renamer.health'
            stub(health, '_is_plugin_installed').returns(false)
            local report_mock = mock(health.report, true)
            report_mock.error.returns()
            report_mock.info.returns()
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.error).was_called_with '"plenary" not found.'
            assert.spy(report_mock.info).was_called_with 'Missing required plugins.'
            renamer._buffers = nil
            mock.revert(report_mock)
        end)

        it('should generate ok if all the required plugins are installed', function()
            local health = require 'renamer.health'
            stub(health, '_is_plugin_installed').returns(true)
            local report_mock = mock(health.report, true)
            report_mock.ok.returns()
            report_mock.info.returns()
            renamer._buffers = {}

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.ok).was_called_with '"plenary" installed.'
            assert.spy(report_mock.info).was_called_with 'Found all required plugins.'
            renamer._buffers = nil
            mock.revert(report_mock)
        end)

        it('should warn if setup was not called', function()
            local health = require 'renamer.health'
            stub(health, '_is_plugin_installed').returns(true)
            local report_mock = mock(health.report, true)
            report_mock.warn.returns()

            health.check()

            assert.spy(health._is_plugin_installed).was_called_with 'plenary'
            assert.spy(report_mock.warn).was_called_with '"renamer.setup" not called. Please make sure setup is done before using the plugin.'
            mock.revert(report_mock)
        end)
    end)
end)
