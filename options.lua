local ADDON_NAME, ns = ...
local L = ns.L

local defaults = ns.data.defaults

local function CreateCheckBox(category, variable, name, tooltip)
    local setting = Settings.RegisterAddOnSetting(category, ns.prefix .. variable, ns.prefix .. variable, BSW_options, type(defaults[variable]), name, defaults[variable])
    Settings.CreateCheckbox(category, setting, tooltip)
end

function ns:CreateSettingsPanel()
    local category, layout = Settings.RegisterVerticalLayoutCategory(ns.name)
    Settings.RegisterAddOnCategory(category)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.OptionsTitle1))

    for index = 1, #L.OptionsWhen do
        local option = L.OptionsWhen[index]
        CreateCheckBox(category, option.key, option.name, option.tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.OptionsTitle2))

    for index = 1, #L.OptionsHow do
        local option = L.OptionsHow[index]
        CreateCheckBox(category, option.key, option.name, option.tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.OptionsTitle3))

    for index = 1, #L.OptionsExtra do
        local option = L.OptionsExtra[index]
        CreateCheckBox(category, option.key, option.name, option.tooltip)
    end

    ns.Settings = category
end
