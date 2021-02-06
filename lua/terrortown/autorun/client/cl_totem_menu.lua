local function PopulateTotemPanel(parent)
	local form = vgui.CreateTTT2Form(parent, "header_addons_totem")

	form:MakeCheckBox({
		label = "label_totem_auto_place_enable",
		convar = "ttt_totem_auto"
	})
end

hook.Add("TTT2ModifyHelpSubMenu", "ttt2_populate_totem_settings", function(helpData, menuId)
	if not GetGlobalBool("ttt2_totem", false) or menuId ~= "ttt2_addons" then return end

	local totemSettings = helpData:PopulateSubMenu(menuId .. "_totem")

	totemSettings:SetTitle("submenu_addons_totem_title")
	totemSettings:PopulatePanel(PopulateTotemPanel)
end)
