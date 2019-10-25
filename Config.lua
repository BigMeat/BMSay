local addonName, addon = ...
setfenv(1, select(2, ...)) 

local config = addon.config
local panel = addon.panel
local scrollFrame = addon.scrollFrame
--设置面板初始化
panel:SetSize(500, 1000)
scrollFrame.ScrollBar:ClearAllPoints()
scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -20)
scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -20, 20)
scrollFrame:SetScrollChild(panel)
scrollFrame.name = addonName
InterfaceOptions_AddCategory(scrollFrame)
--标题
local title = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLargeLeft')
title:SetPoint('TOPLEFT', 16, -16)
title:SetText(addonName.." v"..addon.version)
--所有组件表
panel.controls = {}
--创建唯一命名函数
local UniqueName
do
	local controlID = 1

	function UniqueName(name)
		controlID = controlID + 1
		return string.format('%s_%s_%02d', addonName, name, controlID)
	end
end
--设置面板确定函数
function scrollFrame:ConfigOkay()
	for _, control in pairs(panel.controls) do
		control.SaveValue(control.currentValue)
	end
	addon:UpdateConfig(BMSayDB,config)
	addon:ResetAllSettings()
end
--设置面板回到默认设置函数
function scrollFrame:ConfigDefault()
	for _, control in pairs(panel.controls) do
		control.currentValue = control.defaultValue
		control.SaveValue(control.currentValue)
	end
end
--设置面板刷新函数
function scrollFrame:ConfigRefresh()
	for _, control in pairs(panel.controls) do
		control.currentValue = control.LoadValue()
		control:UpdateValue()
	end
end
--创建标题函数
function panel:CreateHeading(text)
	local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLeft')
	title:SetText(text)

	return title
end
--创建文本函数
function panel:CreateText(text)
	local blob = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmallLeft')
	blob:SetText(text)
	return blob
end
--创建选择框函数
function panel:CreateCheckBox(text, LoadValue, SaveValue, defaultValue)
	local checkBox = CreateFrame('CheckButton', UniqueName('CheckButton'), self, 'InterfaceOptionsCheckButtonTemplate')

	checkBox.LoadValue = LoadValue
	checkBox.SaveValue = SaveValue
	checkBox.defaultValue = defaultValue
	checkBox.UpdateValue = function(self) self:SetChecked(self.currentValue) end
	getglobal(checkBox:GetName() .. 'Text'):SetText(text)

	self.controls[checkBox:GetName()] = checkBox
	return checkBox
end
--下拉菜单点击函数
local function DropDownOnClick(_, dropDown, selectedValue)
	dropDown.currentValue = selectedValue
	UIDropDownMenu_SetText(dropDown, dropDown.valueTexts[selectedValue])
end
--下拉菜单初始化函数
local function DropDownInitialize(frame)
	local info = UIDropDownMenu_CreateInfo()

	for i=1,#frame.valueList,2 do
		local k, v = frame.valueList[i], frame.valueList[i + 1]
		info.text = v
		info.value = k
		info.checked = frame.currentValue == k
		info.func = DropDownOnClick
		info.arg1, info.arg2 = frame, k
		UIDropDownMenu_AddButton(info)
	end
end
--创建下拉菜单函数
function panel:CreateDropDown(text, valueList, LoadValue, SaveValue, defaultValue)
	local dropDown = CreateFrame('Frame', UniqueName('DropDown'), self, 'UIDropDownMenuTemplate')

	local title = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmallLeft')
	title:SetText(text)
	title:SetPoint('BOTTOMLEFT', dropDown, 'left', -80, -6)

	dropDown.LoadValue = LoadValue
	dropDown.SaveValue = SaveValue
	dropDown.defaultValue = defaultValue
	dropDown.UpdateValue = function(self)
		UIDropDownMenu_SetText(self, self.valueTexts[self.currentValue])
	end

	dropDown.valueList = valueList
	dropDown.valueTexts = {}
	for i=1,#valueList,2 do
		local k, v = valueList[i], valueList[i + 1]
		dropDown.valueTexts[k] = v
	end

	dropDown:SetScript('OnShow', function(self)
		UIDropDownMenu_Initialize(self, DropDownInitialize)
	end)

	UIDropDownMenu_JustifyText(dropDown, 'LEFT')
	UIDropDownMenu_SetWidth(dropDown, 120)
	UIDropDownMenu_SetButtonWidth(dropDown, 144)

	self.controls[dropDown:GetName()] = dropDown
	return dropDown
end
--创建文本框
function panel:CreateTextView(headTitle, LoadValue, SaveValue, defaultValue,selfP,pView,pP,x,y)
	local f = CreateFrame("Frame", UniqueName('Frame'), self)
	f:SetPoint(selfP,pView,pP,x,y)
	f:SetSize(300, 120)
	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	f:SetBackdropColor(0, 0, 0)
	f:SetBackdropBorderColor(0.3, 0.3, 0.3)

	local editbox = CreateFrame("EditBox", UniqueName('EditBox'), f)
	editbox:SetPoint("LEFT", 10, 0)
	editbox:SetPoint("RIGHT", -8, 0)
	editbox:SetPoint("TOP", 0, -12)
	editbox:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
	editbox:SetFontObject("ChatFontNormal")

	editbox.LoadValue = LoadValue
	editbox.SaveValue = SaveValue
	editbox.defaultValue = defaultValue
	editbox.UpdateValue = function(self)
		editbox:SetText(self.currentValue)
	end

	editbox:SetAutoFocus(false)
	editbox:SetMultiLine(true)

	editbox:SetScript('OnEditFocusLost',function(self)
		self.currentValue = self:GetText()
	end)
	editbox:SetScript("OnEscapePressed", editbox.ClearFocus)

	if headTitle then
		local titleT = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmallLeft')
		titleT:SetText(headTitle)
		titleT:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', -80, -20)
	end

	self.controls[editbox:GetName()] = editbox
	return editbox
end
--创建按钮
function panel:CreateButton(btnTitle)
	local btn = CreateFrame("Button", UniqueName('Button'), self , 'GameMenuButtonTemplate')
	btn:SetText(btnTitle)

	return btn
end

--设置面板初始化函数
function panel:Initialize()
	--上马宏
	local horseTitle = self:CreateHeading('------上马宏')
	horseTitle:SetPoint('TOPLEFT',title,'BOTTOMLEFT',0,-20)

	local horseYellCB = self:CreateCheckBox(
		'开启上马宏',
		function () return config.horseYellOpen end,
		function (v) config.horseYellOpen = v end,
		config.horseYellOpen)
	horseYellCB:SetPoint('TOPLEFT',horseTitle,"BOTTOMLEFT",0,-20)
	horseYellCB:SetScript('OnClick', function(self) 
		self.currentValue = self:GetChecked()
	end)

	local horseChannelDD = self:CreateDropDown(
		'输出频道',
		{'say','说','yell','大喊','emote','表情'},
		function() return config.ChannelConfigAry.horseYell end,
		function(v) config.ChannelConfigAry.horseYell = v end,
		config.ChannelConfigAry.horseYell)
	horseChannelDD:SetPoint('TOPLEFT',horseYellCB,'BOTTOMLEFT',100,-10)

	local horseText = self:CreateTextView(
		'内容',
		function() return config.yellTextAry.horseYell end,
		function(v) config.yellTextAry.horseYell = v end,
		config.yellTextAry.horseYell,'TOPLEFT',horseChannelDD,'BOTTOMLEFT',0,-10)

	local btnHoresTextSure = self:CreateButton('确定')
	btnHoresTextSure:SetWidth(80)
	btnHoresTextSure:SetPoint('LEFT',horseText,'RIGHT',30,0)
	btnHoresTextSure:SetScript('OnClick',function()
		--保存记录内容
		horseText:ClearFocus()
	end)

	--打断宏
	local ruptTitle = self:CreateHeading('------打断喊话宏')
	ruptTitle:SetPoint('BOTTOMLEFT',horseText,'LEFT',-114,-80)

	local ruptYellCB = self:CreateCheckBox(
		'开启打断喊话宏',
		function () return config.interruptOpen end,
		function (v) config.interruptOpen = v end,
		config.interruptOpen)
	ruptYellCB:SetPoint('TOPLEFT',ruptTitle,"BOTTOMLEFT",0,-20)
	ruptYellCB:SetScript('OnClick', function(self) 
		self.currentValue = self:GetChecked()
	end)
	addon:SetViewToolTip(ruptYellCB,'喊话内容为：前置内容+成功打断了>怪名字<正在施放的【技能名】')

	local ruptChannelDD = self:CreateDropDown(
		'输出频道',
		{'say','说','yell','大喊','emote','表情','party','小队','raid','团队'},
		function() return config.ChannelConfigAry.interruptYell end,
		function(v) config.ChannelConfigAry.interruptYell = v end,
		config.ChannelConfigAry.interruptYell)
	ruptChannelDD:SetPoint('TOPLEFT',ruptYellCB,'BOTTOMLEFT',100,-10)

	local ruptText = self:CreateTextView(
		'前置内容',
		function() return config.yellTextAry.interruptYell end,
		function(v) config.yellTextAry.interruptYell = v end,
		config.yellTextAry.interruptYell,'TOPLEFT',ruptChannelDD,'BOTTOMLEFT',0,-10)

	local ruptTextSure = self:CreateButton('确定')
	ruptTextSure:SetWidth(80)
	ruptTextSure:SetPoint('LEFT',ruptText,'RIGHT',30,0)
	ruptTextSure:SetScript('OnClick',function()
		--保存记录内容
		ruptText:ClearFocus()
	end)

end

--面板初始化
panel:Initialize()
panel:Show()
scrollFrame.okay = scrollFrame.ConfigOkay
scrollFrame.default = scrollFrame.ConfigDefault
scrollFrame.refresh = scrollFrame.ConfigRefresh
scrollFrame:ConfigRefresh()
scrollFrame:Show()



