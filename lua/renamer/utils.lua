local utils = {}

function utils.get_value_or_default(table, name, default)
    if table and table[name] then
        local actual_type, expected_type = type(table[name]), type(default)
        assert(
            type(table[name]) == type(default),
            string.format('Invalid type for \'%s\'. Expected \'%s\', but found \'%s\'.', name, actual_type, expected_type)
        )
        return table[name]
    else
        return default
    end
end

return utils
