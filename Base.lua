local addonName,addon = ...

addon.frame = CreateFrame('Frame', addonName .. 'Frame')
addon.frame:Hide()
addon.panel = CreateFrame('Frame', addonName .. 'Panel')
addon.panel:Hide()
addon.scrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
addon.scrollFrame:Hide()
addon.version = GetAddOnMetadata(addonName, 'Version')

