local utils = require 'renamer.mappings.utils'

local stub = require 'luassert.stub'

local eq = assert.are.same

describe('mappings', function()
    describe('utils', function()
        describe('exec_in_normal', function()
            it('should exit "insert" mode and execute callback (and enter "insert" mode afterwards)', function()
                local was_called = false
                local cmd = stub(vim, 'cmd')
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.exec_in_normal(function()
                    was_called = true
                end, {
                    keep_insert = true,
                })

                eq(true, was_called)
                assert.spy(cmd).was_called_with [[stopinsert]]
                assert.spy(nvim_feedkeys).was_called_with('i', 'n', true)
            end)

            it('should exit "insert" mode and execute callback', function()
                local was_called = false
                local cmd = stub(vim, 'cmd')

                utils.exec_in_normal(function()
                    was_called = true
                end, {
                    keep_insert = false,
                })

                eq(true, was_called)
                assert.spy(cmd).was_called_with [[stopinsert]]
                assert.spy(cmd).called_at_most(1)
            end)

            it('should execute callback with arguments', function()
                local was_called = false

                utils.exec_in_normal(function(val)
                    was_called = val
                end, {}, true)

                eq(true, was_called)
            end)
        end)

        describe('set_cursor_to_end', function()
            it('should call `vim.api.nvim_feedkeys` with "A"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.set_cursor_to_end()

                assert.spy(nvim_feedkeys).was_called_with('A', 'n', true)
            end)
        end)

        describe('set_cursor_to_start', function()
            it('should call `vim.api.nvim_feedkeys` with "I"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.set_cursor_to_start()

                assert.spy(nvim_feedkeys).was_called_with('I', 'n', true)
            end)
        end)

        describe('set_cursor_to_word_end', function()
            it('should call `vim.api.nvim_feedkeys` with "e"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.set_cursor_to_word_end()

                assert.spy(nvim_feedkeys).was_called_with('e', 'n', true)
            end)
        end)

        describe('set_cursor_to_word_start', function()
            it('should call `vim.api.nvim_feedkeys` with "b"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.set_cursor_to_word_start()

                assert.spy(nvim_feedkeys).was_called_with('b', 'n', true)
            end)
        end)

        describe('clear_line', function()
            it('should call `vim.api.nvim_feedkeys` with "0C"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.clear_line()

                assert.spy(nvim_feedkeys).was_called_with('0C', 'n', true)
            end)
        end)

        describe('undo', function()
            it('should call `vim.api.nvim_feedkeys` with "u"', function()
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.undo()

                assert.spy(nvim_feedkeys).was_called_with('u', 't', true)
            end)
        end)

        describe('redo', function()
            it('should call `vim.api.nvim_feedkeys` with "<c-r>"', function()
                local key = vim.api.nvim_replace_termcodes('<c-r>', true, false, true)
                local nvim_feedkeys = stub(vim.api, 'nvim_feedkeys')

                utils.redo()

                assert.spy(nvim_feedkeys).was_called_with(key, 't', true)
            end)
        end)
    end)
end)
