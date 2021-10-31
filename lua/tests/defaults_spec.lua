local eq = assert.are.same

describe('defaults', function()
    it('should have the expected values', function()
        local mappings = require 'renamer.mappings'
        local expected_defaults = {
            title = 'Rename',
            padding = { 0, 0, 0, 0 },
            border = true,
            border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
            show_refs = true,
            prefix = '',
            mappings = mappings.bindings,
        }

        local defaults = require 'renamer.defaults'

        eq(expected_defaults, defaults)
    end)
end)
