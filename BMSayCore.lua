local addonName, addon = ...
setfenv(1, select(2, ...)) 

local config = addon.config
local frame = addon.frame

function addon:UpdateConfig(dst, src)
	for k, v in pairs(src) do
		if type(v) == 'table' then
			if type(dst[k]) == 'table' then
				self:UpdateConfig(dst[k], v)
			else
				dst[k] = self:UpdateConfig({}, v)
			end
		elseif type(dst[k]) ~= 'table' then
			dst[k] = v
		end
	end
	return dst
end

frame:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, ...)
	end
end)

function addon:ResetAllSettings()
	--上马宏开关
	if config.horseYellOpen then
		frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	else
		frame:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	end

	if config.interruptOpen then
		frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") 
	else
		frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") 
	end

end

frame:RegisterEvent('ADDON_LOADED')
function frame:ADDON_LOADED(name)
	if name ~= addonName then return end
	self:UnregisterEvent('ADDON_LOADED')
	BMSayDB = BMSayDB or {}
	addon:UpdateConfig(config, BMSayDB)
end

frame:RegisterEvent('PLAYER_LOGOUT')
function frame:PLAYER_LOGOUT()
	addon:UpdateConfig(BMSayDB, config)
end

frame:RegisterEvent('PLAYER_ENTERING_WORLD')
function frame:PLAYER_ENTERING_WORLD(...)
	addon:ResetAllSettings()
end

function frame:UNIT_SPELLCAST_SUCCEEDED(arg1,arg2,arg3)
	if addon:findMountID(arg3) then
		local channel = addon:getChannel(config.ChannelConfigAry.horseYell)
		if channel then
			SendChatMessage(config.yellTextAry.horseYell,channel)
		end
	end
end

function frame:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo() 
	if(subEvent == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player")) then 
		local spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSchool = select(12, CombatLogGetCurrentEventInfo())
		local channel = addon:getChannel(config.ChannelConfigAry.interruptYell)
		if channel then
			SendChatMessage(config.yellTextAry.interruptYell.."成功打断了>"..destName.."<正在施放的【"..extraSpellName.."】", channel) 
		end
	end
end