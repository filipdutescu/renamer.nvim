local renamer = require 'renamer'

local eq = assert.are.same

describe('renamer', function()
    describe('setup', function()
        local defaults = require 'renamer.defaults'

        it('should use defaults if no options are passed', function()
            local mappings = require 'renamer.mappings'
            renamer.setup()

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("title" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                title = 'abc',
            }

            renamer.setup(opts)

            eq(opts.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("padding" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                padding = {
                    top = 1,
                    left = 2,
                    bottom = 3,
                    right = 4,
                },
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(opts.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("border" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                border = true,
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(opts.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("border_chars" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                border_chars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(opts.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("show_refs" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                show_refs = true,
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(opts.show_refs, renamer.show_refs)
            eq(defaults.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use defaults where no options are passed ("mappings" passed)', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                mappings = {
                    ['<c-a>'] = 'test',
                },
            }

            renamer.setup(opts)

            eq(defaults.title, renamer.title)
            eq(defaults.padding, renamer.padding)
            eq(defaults.border, renamer.border)
            eq(defaults.border_chars, renamer.border_chars)
            eq(defaults.show_refs, renamer.show_refs)
            eq(opts.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)

        it('should use options if passed', function()
            local mappings = require 'renamer.mappings'
            local opts = {
                title = 'abc',
                padding = {
                    top = 1,
                    left = 2,
                    bottom = 3,
                    right = 4,
                },
                border = false,
                border_chars = { '═', '║', '═', '║', '╔', '╗', '╝', '╚' },
                show_refs = false,
                mappings = {
                    ['<c-a>'] = 'test',
                },
            }

            renamer.setup(opts)

            eq(opts.title, renamer.title)
            eq(opts.padding, renamer.padding)
            eq(opts.border, renamer.border)
            eq(opts.border_chars, renamer.border_chars)
            eq(opts.show_refs, renamer.show_refs)
            eq(opts.mappings, mappings.bindings)
            eq({}, renamer._buffers)
        end)
    end)
end)
