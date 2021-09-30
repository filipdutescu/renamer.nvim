local eq = assert.are.same

describe('defaults', function()
    it('should have the expected values', function()
        local expected_title = 'Rename'
        local expected_padding = { 0, 0, 0, 0 }
        local expected_border = true
        local expected_border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
        local expected_prefix = ''

        local defaults = require 'renamer.defaults'

        eq(expected_title, defaults.title)
        eq(expected_padding, defaults.padding)
        eq(expected_border, defaults.border)
        eq(expected_border_chars, defaults.border_chars)
        eq(expected_prefix, defaults.prefix)
    end)
end)
