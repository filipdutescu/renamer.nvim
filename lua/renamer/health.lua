local renamer = require 'renamer'
local strings = require('renamer.constants').strings
local utils = require 'renamer.utils'

local required_plugins = {
    { name = 'plenary' },
}

--- @class Health
--- @field public report table Has the reporting functions (e.g. ok, error)
local health = {}
health.report = {
    start = vim.health.start,
    ok = vim.health.ok,
    warn = vim.health.warn,
    error = vim.health.error,
    info = vim.health.info,
}

health._is_plugin_installed = function(plugin_name)
    local res, _ = pcall(require, plugin_name)
    return res
end

--- Checks if all of the required dependecies are installed and if the
--- `renamer.setup` function was called to initialize the plugin.
---
--- Usage:
--- <code>
--- require('renamer.health').check()
--- </code>
health.check = function()
    health.report.start(strings.checking_required_plugins)

    local required_plugins_installed = true
    for _, plugin in ipairs(required_plugins) do
        if health._is_plugin_installed(plugin.name) then
            health.report.ok(string.format(strings.plugin_installed_template, plugin.name))
        else
            health.report.error(string.format(strings.plugin_not_found_template, plugin.name))
            required_plugins_installed = false
        end
    end

    if required_plugins_installed then
        health.report.info(strings.found_required_plugins)
    else
        health.report.info(strings.missing_required_plugins_err)
    end

    health.report.start(strings.checking_setup_called)
    if renamer._buffers == nil then
        health.report.warn(strings.setup_not_called_err)
    else
        health.report.ok(strings.setup_called)
    end

    if not utils.are_lsp_clients_running() then
        health.report.error(strings.no_lsp_client_found_err)
    else
        health.report.ok(strings.lsp_client_found)
    end
end

return health
