local totem_autoplace = CreateConVar("ttt_totem_auto", "1", {FCVAR_ARCHIVE}, "Should the system try to place the Totem automaticially after round start?")

function LookUpTotem(ply, cmd, args, argStr)
	if not GetGlobalBool("ttt2_totem", false) then return end

	if GetRoundState() ~= ROUND_WAIT and LocalPlayer():IsTerror() then
		net.Start("TTT2TotemPlaceTotem")
		net.SendToServer()
	end
end

local function AutoPlace()
	local ply = LocalPlayer()

	if not IsValid(ply) or not ply:IsTerror() or GetRoundState() == ROUND_WAIT or IsValid(ply:GetNWEntity("Totem", NULL)) then
		timer.Remove("TTT2AutoPlaceTotem")

		return
	end

	LookUpTotem()
end

hook.Add("TTTBeginRound", "TTT2TotemAutomaticPlacement", function()
	if not GetGlobalBool("ttt2_totem", false) or not totem_autoplace:GetBool() then return end

	AutoPlace()

	timer.Create("TTT2AutoPlaceTotem", 2, 0, AutoPlace)
end)

hook.Add("PreDrawOutlines", "AddTotemOutlines", function()
	local totem = LocalPlayer():GetTotem()

	if not totem then return end

	outline.Add({totem}, COLOR_GREEN, OUTLINE_MODE_VISIBLE)
end)

-- Register binding functions
bind.Register("placetotem", function()
	LookUpTotem(nil, nil, nil, nil)
end, nil, "header_bindings_totem", "Place Totem", KEY_T)

-- TTT2Totem ULX Module
hook.Add("TTTUlxModifyAddonSettings", "TTT2TotemModifySettings", function(name)
	local ttt2tpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

	local ttt2tclp = vgui.Create("DCollapsibleCategory", ttt2tpnl)
	ttt2tclp:SetSize(390, 110)
	ttt2tclp:SetExpanded(1)
	ttt2tclp:SetLabel("Basic Settings")

	local ttt2tlst = vgui.Create("DPanelList", ttt2tclp)
	ttt2tlst:SetPos(5, 25)
	ttt2tlst:SetSize(390, 110)
	ttt2tlst:SetSpacing(5)

	ttt2tlst:AddItem(xlib.makecheckbox{
		label = "Enable Totem? (ttt2_totem) (Def. 1)",
		repconvar = "rep_ttt2_totem",
		parent = ttt2tlst
	})

	ttt2tlst:AddItem(xlib.makecheckbox{
		label = "ttt2_totem_enable_speedmodifier (Def. 1)",
		repconvar = "rep_ttt2_totem_enable_speedmodifier",
		parent = ttt2tlst
	})

	ttt2tlst:AddItem(xlib.makelabel{
		x = 0,
		y = 0,
		w = 415,
		wordwrap = true,
		label = "",
		parent = ttt2tlst
	})

	ttt2tlst:AddItem(xlib.makelabel{
		x = 0,
		y = 0,
		w = 415,
		wordwrap = true,
		label = "Set to -1 to allow for infinite pickups:",
		parent = ttt2tlst
	})

	ttt2tlst:AddItem(xlib.makeslider{
		label = "ttt2_totem_max_totem_pickups (Def. 2)",
		repconvar = "rep_ttt2_totem_max_totem_pickups",
		min = -1,
		max = 25,
		decimal = 0,
		parent = ttt2tlst
	})

	xgui.hookEvent("onProcessModules", nil, ttt2tpnl.processModules)
	xgui.addSubModule("TTT2 Totem", ttt2tpnl, nil, name)
end)
