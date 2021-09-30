local renamer = require 'renamer'

local eq = assert.are.same

describe('renamer', function()
    describe('setup', function()
        local defaults = require 'renamer.defaults'

        it('should use defaults if no options are passed', function()
            renamer.setup()

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("title" passed)', function()
            local opts = {
                title = 'abc',
            }

            renamer.setup(opts)

            eq(opts.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("padding" passed)', function()
            local opts = {
                padding = { 1, 2, 3, 4 },
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(opts.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("border" passed)', function()
            local opts = {
                border = true,
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(opts.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("border_chars" passed)', function()
            local opts = {
                border_chars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(opts.border_chars, renamer.border_chars)
            eq(defaults.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("prefix" passed)', function()
            local opts = {
                prefix = '> ',
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(opts.prefix, renamer.prefix)
            eq({}, renamer._buffers)
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

            eq(opts.title, renamer.title)
            eq(opts.padding, renamer.padding)
            eq(opts.border, renamer.border)
            eq(opts.border_chars, renamer.border_chars)
            eq(opts.prefix, renamer.prefix)
            eq({}, renamer._buffers)
        end)
    end)
end)
