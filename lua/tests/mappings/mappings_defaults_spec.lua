local mappings = require 'renamer.mappings'

local eq = assert.are.same

describe('mappings', function()
    it('should have actions initialized for all `bindings`', function()
        local bindings = mappings.default_bindings

        for key, value in pairs(bindings) do
            assert(value, string.format('No action mapped to "%s".', key))
        end
    end)

    it('should have `keymap_opts` initialized', function()
        local expected_opts = { noremap = true, silent = true }
        local keymap_opts = mappings.keymap_opts

        eq(expected_opts, keymap_opts)
    end)
end)
