local eq = assert.are.same

describe('defaults', function()
    it('should have the expected values', function()
        local mappings = require 'renamer.mappings'
        local expected_defaults = {
            title = 'Rename',
            padding = {
                top = 0,
                left = 0,
                bottom = 0,
                right = 0,
            },
            border = true,
            border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
            show_refs = true,
            with_qf_list = true,
            mappings = mappings.bindings,
        }

        local defaults = require 'renamer.defaults'

        eq(expected_defaults, defaults)
    end)
end)
