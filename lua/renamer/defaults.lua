local mappings = require 'renamer.mappings'

--- @class Defaults
--- @field public title string
--- @field public padding integer[]
--- @field public border boolean
--- @field public border_chars string[]
--- @field public show_refs boolean
--- @field public mappings string
local defaults = {
    -- The popup title, shown if `border` is true
    title = 'Rename',
    -- The padding around the popup content
    padding = { 0, 0, 0, 0 },
    -- Whether or not to shown a border around the popup
    border = true,
    -- The characters which make up the border
    border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    -- Whether or not to highlight the current word references through LSP
    show_refs = true,
    -- The keymaps available while in the `renamer` buffer. The example below
    -- overrides the default values, but you can add others as well.
    mappings = mappings.bindings,
}

return defaults
