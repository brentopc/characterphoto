--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to set your character's photo on your current or most recently selected character in cad
]]

CreateThread(function() Config.LoadPlugin("characterphoto", function(pluginConfig)

    if pluginConfig.enabled then
	
		local function SendMessage(type, source, message)
			if type == "success" then
				TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2Success ^0] ", message}})
			elseif type == "error" then
				TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", message}})
			elseif type == "debug" and Config.debugMode then
				TriggerClientEvent("chat:addMessage", source, {args = {"[ Debug ] ", message}})
			end
		end
		
		local function all_trim(s)
		   return s:match( "^%s*(.-)%s*$" )
		end
	
		local state = GetResourceState(pluginConfig.headshotResourceName)
		local shouldStop = false
		if state ~= "started" then
			if state == "missing" then
				errorLog(("[characterphoto] The configured Loaf headshot to base64 resource (%s) does not exist. Please check the name."):format(pluginConfig.firesirenResourceName))
				shouldStop = true
			elseif state == "stopped" then
				warnLog(("[characterphoto] The Loaf headshot to base64 resource (%s) is not started. Please ensure it's started before clients conntect. This is only a warning. State: %s"):format(pluginConfig.firesirenResourceName, state))
			else
				errorLog(("[characterphoto] The configured Loaf headshot to base64 resource (%s) is in a bad state (%s). Please check it."):format(pluginConfig.firesirenResourceName, state))
				shouldStop = true
			end
		end

		if shouldStop then
			pluginConfig.enabled = false
			pluginConfig.disableReason = "Loaf headshot to base64 resource incorrect"
			errorLog("Force disabling plugin to prevent client errors.")
			return
		end		
		
		RegisterServerEvent("SonoranCAD::characterphoto:SaveCharacterPhoto")
		AddEventHandler("SonoranCAD::characterphoto:SaveCharacterPhoto", function(photo)		
			local _source = tonumber(source)

			local steam = tostring(GetPlayerIdentifiers(_source)[1])
			steam = string.sub(steam, 7, string.len(steam))
			
			local payload = {{["apiId"] = steam, ["serverId"] = Config.serverId}}
			performApiRequest(payload, "GET_CHARACTERS", function(resp)
				debugLog("Get characters: "..tostring(json.decode(resp)))
				if json.decode(resp) then
					allCharacterData = json.decode(resp)
					characterData = allCharacterData[1]
					local recordId = characterData.id
					
					local replaceValues = { ["img"] = photo }
					local payload = {
						{
							["user"] = steam,
							["useDictionary"] = true,
							["recordId"] = recordId,
							["replaceValues"] = replaceValues,
							["serverId"] = Config.serverId,
						}
					}
					performApiRequest(payload, "EDIT_CHARACTER", function(resp)
						local fullName = "your character"
						for i,v in ipairs(characterData.sections) do
							for ii,vv in ipairs(v.fields) do
								if vv.uid == "first" then
									firstName = all_trim(vv.value)
								elseif vv.uid == "last" then
									lastName = all_trim(vv.value)
								elseif vv.uid == "mi" then
									middleName = all_trim(vv.value)
									if middleName == nil or middleName == "" then
										fullName = firstName .. " " .. lastName
									else
										fullName = firstName .. " " .. middleName .. ". " .. lastName
									end
								end
							end						
						end
						
						SendMessage("success", _source, "Set " .. fullName .. "'(s) image.")
						debugLog("Edited character: "..tostring(resp))
					end)
				else
					SendMessage("error", _source, "No characters found in CAD.")
					return
				end
			end)
		end)
    end

end) end)