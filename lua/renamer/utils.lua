local utils = {}

function utils.get_value_or_default(table, name, default)
    if table and not (table[name] == nil) then
        local actual_type, expected_type = type(table[name]), type(default)
        assert(
            type(table[name]) == type(default),
            string.format('Invalid type for "%s". Expected "%s", but found "%s".', name, actual_type, expected_type)
        )
        return table[name]
    else
        return default
    end
end

function utils.get_word_boundaries_in_line(line, word, line_pos)
    local len = string.len(line)
    if line_pos > len then
        return nil, nil
    end
    local i = 1
    local word_start, word_end = string.find(line, word, i)
    local closest_word_start, closest_word_end = word_start, word_end

    while i <= len do
        i = i + 1
        word_start, word_end = string.find(line, word, i)

        if
            word_start
            and word_end
            and math.abs(line_pos - word_start) < math.abs(line_pos - closest_word_start)
            and math.abs(word_end - line_pos) < math.abs(closest_word_end - line_pos)
        then
            closest_word_start, closest_word_end = word_start, word_end
        end
    end

    if closest_word_start and closest_word_end and (closest_word_start > line_pos or closest_word_end < line_pos) then
        return nil, nil
    end

    return closest_word_start, closest_word_end
end

function utils.set_qf_list(changes)
    if changes then
        local qf_list, i = {}, 0
        for file, data in pairs(changes) do
            local buf_id = -1
            if vim.uri and vim.uri.uri_to_bufnr then
                buf_id = vim.uri.uri_to_bufnr(file)
            else
                local file_path = string.gsub(file, 'file://', '')
                buf_id = vim.fn.bufadd(file_path)
            end
            vim.fn.bufload(buf_id)
            file = string.gsub(file, 'file://', '')

            for _, change in ipairs(data) do
                local row, col = change.range.start.line, change.range.start.character
                i = i + 1
                local line = vim.api.nvim_buf_get_lines(buf_id, row, row + 1, false)
                qf_list[i] = {
                    text = line and line[1],
                    filename = file,
                    lnum = row + 1,
                    col = col + 1,
                }
            end
        end

        if qf_list and i > 0 then
            vim.fn.setqflist(qf_list)
        end
    end
end

return utils
