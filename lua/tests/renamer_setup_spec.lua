local renamer = require 'renamer'

local eq = assert.are.same

describe('renamer', function()
    describe('setup', function()
        local defaults = require 'renamer.defaults'

        it('should use defaults if no options are passed', function()
            renamer.setup()

            eq(renamer.title, defaults.title)
            eq(renamer.padding, defaults.padding)
            eq(renamer.border, defaults.border)
            eq(renamer.border_chars, defaults.border_chars)
            eq(renamer.prefix, defaults.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use defaults where no options are passed ("title" passed)', function()
            local opts = {
                title = 'abc',
            }

            renamer.setup(opts)

            eq(renamer.title, opts.title)
            eq(renamer.padding, defaults.padding)
            eq(renamer.border, defaults.border)
            eq(renamer.border_chars, defaults.border_chars)
            eq(renamer.prefix, defaults.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use defaults where no options are passed ("padding" passed)', function()
            local opts = {
                padding = { 1, 2, 3, 4 },
            }

            renamer.setup(opts)

            eq(renamer.title, defaults.title)
            eq(renamer.padding, opts.padding)
            eq(renamer.border, defaults.border)
            eq(renamer.border_chars, defaults.border_chars)
            eq(renamer.prefix, defaults.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use defaults where no options are passed ("border" passed)', function()
            local opts = {
                border = true,
            }

            renamer.setup(opts)

            eq(renamer.title, defaults.title)
            eq(renamer.padding, defaults.padding)
            eq(renamer.border, opts.border)
            eq(renamer.border_chars, defaults.border_chars)
            eq(renamer.prefix, defaults.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use defaults where no options are passed ("border_chars" passed)', function()
            local opts = {
                border_chars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
            }

            renamer.setup(opts)

            eq(renamer.title, defaults.title)
            eq(renamer.padding, defaults.padding)
            eq(renamer.border, defaults.border)
            eq(renamer.border_chars, opts.border_chars)
            eq(renamer.prefix, defaults.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use defaults where no options are passed ("prefix" passed)', function()
            local opts = {
                prefix = '> ',
            }

            renamer.setup(opts)

            eq(renamer.title, defaults.title)
            eq(renamer.padding, defaults.padding)
            eq(renamer.border, defaults.border)
            eq(renamer.border_chars, defaults.border_chars)
            eq(renamer.prefix, opts.prefix)
            eq(renamer._buffers, {})
        end)

        it('should use options if passed', function()
            local opts = {
                title = 'abc',
                padding = { 1, 2, 3, 4 },
                border = true,
                border_chars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
                prefix = '> ',
            }

            renamer.setup(opts)

            eq(renamer.title, opts.title)
            eq(renamer.padding, opts.padding)
            eq(renamer.border, opts.border)
            eq(renamer.border_chars, opts.border_chars)
            eq(renamer.prefix, opts.prefix)
            eq(renamer._buffers, {})
        end)
    end)
end)
