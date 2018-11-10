local function SettingsTab(dtabs)
	local padding = dtabs:GetPadding()
	local PANEL = {}

	vgui.Register("DTotemSettingsPanelList", PANEL, "DPanelList")

	local dsettings = vgui.Create("DTotemSettingsPanelList", dtabs)
	dsettings:StretchToParent(0, 0, padding, 0)
	dsettings:EnableVerticalScrollbar(true)
	dsettings:SetPadding(10)
	dsettings:SetSpacing(10)

	local dgui = vgui.Create("DForm", dsettings)
	dgui:SetName("Bindings") -- TODO Add localization

	-- Totem placement
	local dTPlabel = vgui.Create("DLabel")
	dTPlabel:SetText("Place Totem:")

	local dTPBinder = vgui.Create("DBinder")
	dTPBinder:SetSize(170, 30)

	local curBindingT = bind.Find("placetotem")
	dTPBinder:SetValue(curBindingT)

	function dTPBinder:OnChange(num)
		if num == 0 then
			bind.Remove(curBindingT, "placetotem")
		else
			bind.Remove(curBindingT, "placetotem")
			bind.Add(num, "placetotem", true)

			LocalPlayer():ChatPrint("New bound key for placing a totem: " .. input.GetKeyName(num))
		end

		curBindingT = num
	end

	dgui:AddItem(dTPlabel, dTPBinder)

	dsettings:AddItem(dgui)

	local dguiT = vgui.Create("DForm", dsettings)
	dguiT:SetName("Totem")
	dguiT:CheckBox("Automaticially try placing a Totem", "ttt_totem_auto")

	dsettings:AddItem(dguiT)

	dtabs:AddSheet("Totem", dsettings, "icon16/wrench.png", false, false, "Totem Settings")
end

-- Register binding functions
bind.Register("placetotem", function()
	LookUpTotem(nil, nil, nil, nil)
end)

hook.Add("TTTSettingsTabs", "TTT2TotemBindings", SettingsTab)
