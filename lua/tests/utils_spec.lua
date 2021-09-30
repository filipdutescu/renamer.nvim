local utils = require 'renamer.utils'

local eq = assert.are.same

describe('utils', function()
    describe('get_value_or_default', function()
        it('should return value, for valid table', function()
            local expected_table_key = 'test'
            local expected_table_value = 'test'
            local expected_table = {}
            expected_table[expected_table_key] = expected_table_value

            local result = utils.get_value_or_default(expected_table, expected_table_key, '')

            eq(expected_table_value, result)
        end)

        it('should return default, for nil table', function()
            local expected_value = 'test'

            local result = utils.get_value_or_default(nil, nil, expected_value)

            eq(expected_value, result)
        end)

        it('should return default, for table without key', function()
            local expected_table_key = 'test'
            local expected_value = 'test'
            local expected_table = {}

            local result = utils.get_value_or_default(expected_table, expected_table_key, expected_value)

            eq(expected_value, result)
        end)
    end)
end)
