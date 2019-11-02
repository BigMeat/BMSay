local addonName,addon = ...

local aframe = addon.frame
local panel = addon.panel
local ascrollFrame = addon.scrollFrame

aframe:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, ...)
	end
end)

aframe:RegisterEvent('PLAYER_ENTERING_WORLD')
function aframe:PLAYER_ENTERING_WORLD(...)
	BMSayDB = BMSayDB or {
		horseYellOpen = true,
		interruptOpen = true,
		ChannelConfigAry = {horseYell = 'emote',interruptYell = 'yell'},
		yellTextAry = {horseYell = '翻身一跃,骑上帅气的小马儿...扬长而去...',interruptYell = ''},
		MountIDList = {}
	}
	panel:Initialize()
	panel:Show()
	ascrollFrame.okay = ascrollFrame.ConfigOkay
	ascrollFrame.default = ascrollFrame.ConfigDefault
	ascrollFrame.refresh = ascrollFrame.ConfigRefresh
	ascrollFrame:ConfigRefresh()
	ascrollFrame:Show()
	addon:ResetAllSettings()
end

-- 判断val是否在t里
function addon:IsInArray(t, val)
	for _, v in ipairs(t) do
		if v == val then
			return true
		end
	end
	return false
end

function addon:findMountID(mountID)
	--先判断之前用过的
	if addon:IsInArray(BMSayDB.MountIDList,mountID) then
		return true
	elseif addon:IsInArray(addon.MountIDList,mountID) then
		if not addon:IsInArray(BMSayDB.MountIDList,mountID) then
			table.insert(BMSayDB.MountIDList,mountID)
		end
		return true
	end
	return false
end

function addon:getChannel(type)
	local channel
	if type == 'emote' then
		channel = 'emote'
	elseif type == 'say' then
		channel = 'say'
	elseif type == 'yell' then
		channel = 'yell'
	elseif type == 'party' then
		if IsInGroup() then
			channel = 'party'
		end
	elseif type == 'raid' then
		if IsInRaid() then
			channel = 'raid'
		end
	end
	return channel
end

function addon:ResetAllSettings()
	--上马宏开关
	if BMSayDB.horseYellOpen then
		aframe:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	else
		aframe:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
	end

	if BMSayDB.interruptOpen then
		aframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") 
	else
		aframe:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") 
	end

end

function aframe:UNIT_SPELLCAST_SUCCEEDED(arg1,arg2,arg3)
	if arg1 == 'player' and addon:findMountID(arg3) then
		local channel = addon:getChannel(BMSayDB.ChannelConfigAry.horseYell)
		if channel then
			SendChatMessage(BMSayDB.yellTextAry.horseYell,channel)
		end
	end
end

function aframe:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo() 
	if(subEvent == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player")) then 
		local spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSchool = select(12, CombatLogGetCurrentEventInfo())
		local channel = addon:getChannel(BMSayDB.ChannelConfigAry.interruptYell)
		if channel then
			SendChatMessage(BMSayDB.yellTextAry.interruptYell.."成功打断了>"..destName.."<正在施放的【"..extraSpellName.."】", channel) 
		end
	end
end