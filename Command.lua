local addonName, addon = ...
setfenv(1, select(2, ...)) 

local config = addon.config
local L = addon.language

SLASH_BMS1 = '/bms'
SLASH_BMS2 = '/BMS'
SlashCmdList['BMS'] = function(msg)
    local command = msg:lower()
    if command then
    	
    else
		InterfaceOptionsFrame_OpenToCategory("BMSay")
	end
end