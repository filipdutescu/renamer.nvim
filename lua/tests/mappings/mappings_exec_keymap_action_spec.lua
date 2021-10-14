local mappings = require 'renamer.mappings'

local stub = require 'luassert.stub'

local eq = assert.are.same

describe('mappings', function()
    describe('exec_keymap_action', function()
        it('should not execute if `keymap` is nil', function()
            local binding = '<c-a>'
            local initial_action = mappings.bindings[binding]
            local was_called = false
            mappings.bindings[binding] = function()
                was_called = true
            end

            mappings.exec_keymap_action()

            eq(false, was_called)
            mappings.bindings[binding] = initial_action
        end)

        it('should execute the action associated with a valid binding', function()
            local binding = '<c-a>'
            local initial_action = mappings.bindings[binding]
            local was_called = false
            mappings.bindings[binding] = function()
                was_called = true
            end

            mappings.exec_keymap_action(binding)

            eq(true, was_called)
            mappings.bindings[binding] = initial_action
        end)
    end)
end)
