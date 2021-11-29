local strings = require('renamer.constants').strings
local utils = require 'renamer.mappings.utils'

local stub = require 'luassert.stub'

local eq = assert.are.same

describe('mappings', function()
    describe('utils', function()
        describe('exec_in_normal', function()
            it('should exit "insert" mode and execute callback', function()
                local was_called = false
                local nvim_command = stub(vim.api, 'nvim_command')

                utils.exec_in_normal(function()
                    was_called = true
                end)

                eq(true, was_called)
                assert.spy(nvim_command).was_called_with(strings.stopinsert_command)
                assert.spy(nvim_command).called_at_most(1)
            end)

            it('should execute callback with arguments', function()
                local was_called = false

                utils.exec_in_normal(function(val)
                    was_called = val
                end, true)

                eq(true, was_called)
            end)
        end)

        describe('set_cursor_to_end', function()
            it('should call `vim.api.nvim_input` with "A"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.set_cursor_to_end()

                assert.spy(nvim_input).was_called_with 'A'
            end)
        end)

        describe('set_cursor_to_start', function()
            it('should call `vim.api.nvim_input` with "I"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.set_cursor_to_start()

                assert.spy(nvim_input).was_called_with 'I'
            end)
        end)

        describe('set_cursor_to_word_end', function()
            it('should call `vim.api.nvim_input` with "e"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.set_cursor_to_word_end()

                assert.spy(nvim_input).was_called_with 'ei'
            end)
        end)

        describe('set_cursor_to_word_start', function()
            it('should call `vim.api.nvim_input` with "bi"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.set_cursor_to_word_start()

                assert.spy(nvim_input).was_called_with 'bi'
            end)
        end)

        describe('clear_line', function()
            it('should call `vim.api.nvim_input` with "0C"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.clear_line()

                assert.spy(nvim_input).was_called_with '0C'
            end)
        end)

        describe('undo', function()
            it('should call `vim.api.nvim_input` with "ui"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.undo()

                assert.spy(nvim_input).was_called_with 'ui'
            end)
        end)

        describe('redo', function()
            it('should call `vim.api.nvim_input` with "<c-r>i"', function()
                local nvim_input = stub(vim.api, 'nvim_input')

                utils.redo()

                assert.spy(nvim_input).was_called_with '<c-r>i'
            end)
        end)
    end)
end)
