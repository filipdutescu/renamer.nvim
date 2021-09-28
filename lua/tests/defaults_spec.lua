local eq = assert.are.same

describe('defaults', function()
    it('should have the expected values', function()
        local expected_title = 'Rename'
        local expected_padding = { 0, 0, 0, 0 }
        local expected_border = true
        local expected_border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
        local expected_prefix = ''

        local defaults = require 'renamer.defaults'

        eq(defaults.title, expected_title)
        eq(defaults.padding, expected_padding)
        eq(defaults.border, expected_border)
        eq(defaults.border_chars, expected_border_chars)
        eq(defaults.prefix, expected_prefix)
    end)
end)
