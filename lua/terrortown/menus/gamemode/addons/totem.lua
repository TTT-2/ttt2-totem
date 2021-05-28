CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"

CLGAMEMODESUBMENU.priority = 0
CLGAMEMODESUBMENU.title = "submenu_addons_totem_title"

function CLGAMEMODESUBMENU:Populate(parent)
	local form = vgui.CreateTTT2Form(parent, "header_addons_totem")

	form:MakeCheckBox({
		label = "label_totem_auto_place_enable",
		convar = "ttt_totem_auto"
	})
end

function CLGAMEMODESUBMENU:ShouldShow()
	return GetGlobalBool("ttt2_totem")
end
