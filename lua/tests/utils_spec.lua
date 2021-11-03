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

    describe('get_word_boundaries_in_line', function()
        it('should return the word start and end positions (with position outside word)', function()
            local word = 'abc'
            local line = 'test ' .. word .. ' test'
            local expected_word_start, expected_word_end = nil, nil

            local word_start, word_end = utils.get_word_boundaries_in_line(line, word, 0)

            eq(expected_word_start, word_start)
            eq(expected_word_end, word_end)

            word_start, word_end = utils.get_word_boundaries_in_line(line, word, 9)

            eq(expected_word_start, word_start)
            eq(expected_word_end, word_end)
        end)

        it('should return the word start and end positions (with position inside word)', function()
            local word = 'abc'
            local line = 'test ' .. word .. ' test'
            local expected_word_start, expected_word_end = 6, 8

            local word_start, word_end = utils.get_word_boundaries_in_line(line, word, 7)

            eq(expected_word_start, word_start)
            eq(expected_word_end, word_end)
        end)

        it('should return the word start and end positions of the closest word', function()
            local word = 'abcdef'
            local line = 'test ' .. word .. ' test ' .. word .. ' test'
            local expected_word_start1, expected_word_end1 = 6, 11
            local expected_word_start2, expected_word_end2 = 18, 23

            local word_start, word_end = utils.get_word_boundaries_in_line(line, word, 9)

            eq(expected_word_start1, word_start)
            eq(expected_word_end1, word_end)

            word_start, word_end = utils.get_word_boundaries_in_line(line, word, 21)

            eq(expected_word_start2, word_start)
            eq(expected_word_end2, word_end)
        end)
    end)
end)
