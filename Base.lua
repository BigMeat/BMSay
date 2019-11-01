local addonName,addon = ...

addon.frame = CreateFrame('Frame', addonName .. 'Frame')
addon.frame:Hide()
addon.panel = CreateFrame('Frame', addonName .. 'Panel')
addon.panel:Hide()
addon.scrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
addon.scrollFrame:Hide()
addon.version = GetAddOnMetadata(addonName, 'Version')

function addon:SetViewToolTip(view,tips)

	view:SetScript('OnEnter',function(view)
		GameTooltip:SetOwner(view, "ANCHOR_TOP") -- 提示顯示於滑鼠的上方
		GameTooltip:AddLine(tips, 1, 1, 1) -- 白色文字
		GameTooltip:Show() -- 使其顯示
	end)

	view:SetScript('OnLeave',function(view)
		GameTooltip:Hide() -- 隐藏
	end)

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
	if addon:IsInArray(config.MountIDList,mountID) then
		return true
	elseif addon:IsInArray(addon.MountIDList,mountID) then
		if not addon:IsInArray(config.MountIDList,mountID) then
			table.insert(config.MountIDList,mountID)
			--更新数据库
			addon:UpdateConfig(BMSayDB, config)
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

--坐骑法术ID
addon.MountIDList = {
	30174,
	29059,
	26656,
	26056,
	26055,
	26054,
	25953,
	24252,
	24242,
	23510,
	23509,
	23338,
	23252,
	23251,
	23250,
	23249,
	23248,
	23247,
	23246,
	23243,
	23242,
	23241,
	23240,
	23239,
	23238,
	23229,
	23228,
	23227,
	23225,
	23223,
	23222,
	23221,
	23220,
	23219,
	23214,
	23161,
	22724,
	22723,
	22722,
	22721,
	22720,
	22719,
	22718,
	22717,
	18992,
	18991,
	18990,
	18989,
	18363,
	17481,
	17465,
	17464,
	17463,
	17462,
	17461,
	17460,
	17459,
	17458,
	17456,
	17455,
	17454,
	17453,
	17450,
	17229,
	16084,
	16083,
	16082,
	16081,
	16080,
	16060,
	16059,
	16058,
	16056,
	16055,
	15781,
	15780,
	15779,
	13819,
	10969,
	10873,
	10799,
	10798,
	10796,
	10795,
	10793,
	10789,
	8980,
	8395,
	8394,
	6899,
	6898,
	6897,
	6896,
	6777,
	6654,
	6653,
	6648,
	5784,
	3363,
	581,
	580,
	579,
	578,
	472,
	471,
	470,
	468,
	459,
	458
}
