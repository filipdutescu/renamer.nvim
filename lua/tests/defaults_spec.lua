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
            minwidth = 15,
            maxwidth = 45,
            border = true,
            border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
            show_refs = true,
            with_qf_list = true,
            with_popup = true,
            mappings = mappings.default_bindings,
            handler = nil,
        }

        local defaults = require 'renamer.defaults'

        eq(expected_defaults, defaults)
    end)
end)
