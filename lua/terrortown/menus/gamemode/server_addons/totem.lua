CLGAMEMODESUBMENU.base = "base_gamemodesubmenu"

CLGAMEMODESUBMENU.priority = 0
CLGAMEMODESUBMENU.title = "submenu_server_addons_totem_title"

function CLGAMEMODESUBMENU:Populate(parent)
    local form = vgui.CreateTTT2Form(parent, "header_addons_totem")

    local totem = form:MakeCheckBox({
        label = "label_totem",
        serverConvar = "ttt2_totem",
    })

    form:MakeCheckBox({
        label = "label_totem_enable_speedmodifier",
        serverConvar = "ttt2_totem_enable_speedmodifier",
        master = totem,

    })

    form:MakeHelp({
        label = "help_totem_max_totem_pickups",
        master = totem,
    })

    form:MakeSlider({
        serverConvar = "ttt2_totem_max_totem_pickups",
        label = "label_totem_max_totem_pickups",
        min = -1,
        max = 25,
        decimal = 0,
        master = totem,
    })
end
