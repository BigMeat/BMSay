local addonName, addon = ...

SLASH_BMS1 = '/bms'
SLASH_BMS2 = '/BMS'
SlashCmdList['BMS'] = function(msg)
    local command = msg:lower():match("^(%S*)%s*(.-)$")
    if command:len() > 1 then

    else
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
end