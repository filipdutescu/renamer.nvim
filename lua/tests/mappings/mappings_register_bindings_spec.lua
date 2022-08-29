local strings = require('renamer.constants').strings
local mappings = require 'renamer.mappings'

local stub = require 'luassert.stub'

describe('mappings', function()
    describe('register_bindings', function()
        it('should not set keymaps if `buf_id` is nil', function()
            local set_keymap = stub(vim.api, 'nvim_buf_set_keymap')

            mappings.register_bindings()

            assert.spy(set_keymap).called_less_than(1)
        end)

        it('should not set keymaps if `bindings` is nil', function()
            local buf_id = 1
            local set_keymap = stub(vim.api, 'nvim_buf_set_keymap')
            mappings.bindings = nil

            mappings.register_bindings(buf_id)

            assert.spy(set_keymap).called_less_than(1)
        end)

        it('should not set keymaps if `bindings` is empty', function()
            local buf_id = 1
            local set_keymap = stub(vim.api, 'nvim_buf_set_keymap')
            mappings.bindings = {}

            mappings.register_bindings(buf_id)

            assert.spy(set_keymap).called_less_than(1)
        end)

        it('should set `bindings` as keymaps for the received buffer', function()
            local buf_id = 1
            local set_keymap = stub(vim.api, 'nvim_buf_set_keymap')
            local bindings = mappings.default_bindings
            mappings.bindings = bindings

            mappings.register_bindings(buf_id)

            for key, _ in pairs(bindings) do
                local action = string.format(strings.exec_keymap_action_command_template, key:gsub('<', '<lt>'))
                assert
                    .spy(set_keymap)
                    .was_called_with(buf_id, strings.insert_mode_short_string, key, action, mappings.keymap_opts)
            end
        end)
    end)
end)
