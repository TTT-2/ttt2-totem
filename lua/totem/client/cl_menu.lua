local function SettingsTab(dtabs)
	if not GetGlobalBool("ttt2_totem", false) then return end

	local padding = dtabs:GetPadding()
	local PANEL = {}

	vgui.Register("DTotemSettingsPanelList", PANEL, "DPanelList")

	local dsettings = vgui.Create("DTotemSettingsPanelList", dtabs)
	dsettings:StretchToParent(0, 0, padding, 0)
	dsettings:EnableVerticalScrollbar(true)
	dsettings:SetPadding(10)
	dsettings:SetSpacing(10)

	local dguiT = vgui.Create("DForm", dsettings)
	dguiT:SetName("Totem")
	dguiT:CheckBox(GetTranslation("totem_auto_desc"), "ttt_totem_auto")

	dsettings:AddItem(dguiT)

	dtabs:AddSheet("Totem", dsettings, "icon16/wrench.png", false, false, "Totem Settings")
end

-- Register binding functions
bind.Register("placetotem", function()
	LookUpTotem(nil, nil, nil, nil)
end, nil, "TTT2 Totem", "Place Totem")

hook.Add("TTTSettingsTabs", "TTT2TotemBindings", SettingsTab)
