local renamer = require 'renamer'

local required_plugins = {
    { name = 'plenary' },
}

local health = {}
health.report = {
    start = vim.fn['health#report_start'],
    ok = vim.fn['health#report_ok'],
    warn = vim.fn['health#report_warn'],
    error = vim.fn['health#report_error'],
    info = vim.fn['health#report_info'],
}

health._is_plugin_installed = function(plugin_name)
    local res, _ = pcall(require, plugin_name)
    return res
end

health.check = function()
    health.report.start 'Checking required plugins...'

    local required_plugins_installed = true
    for _, plugin in ipairs(required_plugins) do
        if health._is_plugin_installed(plugin.name) then
            health.report.ok('"' .. plugin.name .. '" installed.')
        else
            health.report.error('"' .. plugin.name .. '" not found.')
            required_plugins_installed = false
        end
    end

    if required_plugins_installed then
        health.report.info 'Found all required plugins.'
    else
        health.report.info 'Missing required plugins.'
    end

    health.report.start 'Checking whether setup was made...'
    if renamer._buffers == nil then
        health.report.warn '"renamer.setup" not called. Please make sure setup is done before using the plugin.'
    end
end

return health
