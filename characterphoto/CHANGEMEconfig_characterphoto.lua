--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to set your character's photo on your current or most recently selected character in cad
]]

local config = {
    enabled = false,    
    pluginName = "characterphoto", -- name your plugin here
    pluginAuthor = "Brentopc", -- author
	configVersion = "1.0",
	
	headshotResourceName = "loaf_headshot_base64", -- resource name of the loaf ped headshot to base64 resource https://github.com/loaf-scripts/loaf_headshot_base64
    photoCommandName = "charphoto" -- the command that sets your character photo on your current or most recently selected character in cad
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end