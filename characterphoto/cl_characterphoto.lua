--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to set your character's photo on your current or most recently selected character in cad
]]

CreateThread(function() 
    Config.LoadPlugin("characterphoto", function(pluginConfig)

        if pluginConfig.enabled then
		
		RegisterCommand(pluginConfig.photoCommandName, function(args, rawCommand)		
			local result = exports[pluginConfig.headshotResourceName]:getBase64(PlayerPedId())
			if result.success then					
				TriggerServerEvent("SonoranCAD::characterphoto:SaveCharacterPhoto", result.base64)
				debugLog("Saved character headshot: "..tostring(resp))
			else
				debugLog("Character headshot error: "..tostring(result.error))					
			end
		end)

		TriggerEvent('chat:addSuggestion', '/'..pluginConfig.photoCommandName, "Set your currently selected, or most recently selected, character's image in CAD to your current ped.")

	end
		
    end) 
end)
