local defaults = {
    -- The popup title, shown if `border` is true
    title = 'Rename',
    -- The padding around the popup content
    padding = { 0, 0, 0, 0 },
    -- Whether or not to shown a border around the popup
    border = true,
    -- The characters which make up the border
    border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    -- The string to be used as a prompt prefix. It also sets the buffer to be a prompt
    prefix = '',
}

return defaults
