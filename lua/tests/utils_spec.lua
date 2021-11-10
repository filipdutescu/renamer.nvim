local utils = require 'renamer.utils'

local stub = require 'luassert.stub'

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

    describe('set_qf_list', function()
        it('should not set the quickfix list if changes are nil', function()
            local setqflist = stub(vim.fn, 'setqflist')

            utils.set_qf_list(nil)

            assert.spy(setqflist).called_less_than(1)
            setqflist.revert(setqflist)
        end)

        it('should not set the quickfix list if no files were modified', function()
            local setqflist = stub(vim.fn, 'setqflist')

            utils.set_qf_list {}

            assert.spy(setqflist).called_less_than(1)
            setqflist.revert(setqflist)
        end)

        it('should not set the quickfix list if files have no changes', function()
            local changes = {
                ['file:///test'] = {},
            }
            local get_buf_id = nil
            if vim.uri and vim.uri.uri_to_bufnr then
                get_buf_id = stub(vim.uri, 'uri_to_bufnr')
            else
                get_buf_id = stub(vim.fn, 'bufadd')
            end
            local buf_load = stub(vim.fn, 'bufload')
            local setqflist = stub(vim.fn, 'setqflist')

            utils.set_qf_list(changes)

            assert.spy(get_buf_id).was_called()
            assert.spy(buf_load).was_called()
            assert.spy(setqflist).called_less_than(1)
            setqflist.revert(setqflist)
        end)

        it('should set the quickfix list with the lines that were changed', function()
            local changes = {
                ['file:///test1'] = {
                    {
                        range = {
                            start = {
                                line = 0,
                                character = 1,
                            },
                        },
                    },
                    {
                        range = {
                            start = {
                                line = 0,
                                character = 2,
                            },
                        },
                    },
                },
                ['file:///test2'] = {
                    {
                        range = {
                            start = {
                                line = 2,
                                character = 1,
                            },
                        },
                    },
                    {
                        range = {
                            start = {
                                line = 2,
                                character = 2,
                            },
                        },
                    },
                },
            }
            local expected_qf_list = {}
            local pos = 0
            for file, data in pairs(changes) do
                for _, change in ipairs(data) do
                    pos = pos + 1
                    local row, col = change.range.start.line, change.range.start.character
                    if row == 0 then
                        row = 1
                    end
                    expected_qf_list[1] = {
                        text = 'test',
                        filename = string.gsub(file, 'file://', ''),
                        lnum = row,
                        col = col,
                    }
                end
            end
            local get_buf_id = nil
            if vim.uri and vim.uri.uri_to_bufnr then
                get_buf_id = stub(vim.uri, 'uri_to_bufnr')
            else
                get_buf_id = stub(vim.fn, 'bufadd')
            end
            local buf_load = stub(vim.fn, 'bufload')
            local i = 0
            local buf_get_lines = stub(vim.api, 'nvim_buf_get_lines').invokes(function()
                i = i + 1
                return { 'test' }
            end)
            local setqflist = stub(vim.fn, 'setqflist').invokes(function(...)
                assert(expected_qf_list, ...)
            end)

            utils.set_qf_list(changes)

            assert.spy(get_buf_id).was_called()
            assert.spy(buf_load).was_called()
            assert.spy(buf_get_lines).called_at_least(i)
            assert.spy(buf_get_lines).called_at_most(i)
            get_buf_id.revert(get_buf_id)
            buf_load.revert(buf_load)
            setqflist.revert(setqflist)
        end)
    end)
end)
