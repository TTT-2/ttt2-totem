CreateConVar("ttt_totem_auto", "1", {FCVAR_ARCHIVE}, "Should the system try to place the Totem automaticially at round start?")

net.Receive("TTT2ClientInitTotem", function()
	include("totem/client/cl_menu.lua")
end)

hook.Add("TTT2FinishedLoading", "TTT2TotemInitLang", function()
	if CLIENT then
		include("totem/client/cl_lang.lua")
	end
end)

hook.Add("TTTBeginRound", "TTT2TotemAutomaticPlacement", function()
	if not GetGlobalBool("ttt2_totem", false) or not GetConVar("ttt_totem_auto"):GetBool() then return end

	LocalPlayer():ConCommand("placetotem")
end)

function LookUpTotem(ply, cmd, args, argStr)
	if not GetGlobalBool("ttt2_totem", false) then return end

	if GetRoundState() ~= ROUND_WAIT and LocalPlayer():IsTerror() then
		net.Start("TTT2TotemPlaceTotem")
		net.SendToServer()
	end
end
concommand.Add("placetotem", LookUpTotem, nil, "Places a Totem", {FCVAR_DONTRECORD})

net.Receive("TTT2Totem", function()
	local bool = net.ReadInt(8)
	local GetTranslation = LANG.GetTranslation

	if bool == 1 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_already_placed"))
	elseif bool == 2 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_place_ground_needed"))
	elseif bool == 3 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_placed"))

		LocalPlayer().PlacedTotem = true
	elseif bool == 4 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_picked_up"))

		LocalPlayer().PlacedTotem = false
	elseif bool == 5 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_destroyed"))
	elseif bool == 6 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_slow"))
	elseif bool == 7 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_already_picked_up"))
	elseif bool == 8 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, GetTranslation("totem_all_destroyed"))
	end

	chat.PlaySound()
end)

--------------------TTT2Totem Module--------------------
hook.Add("TTTUlxModifyAddonSettings", "TTT2TotemModifySettings", function(name)
	local ttt2tpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

	local ttt2tclp = vgui.Create("DCollapsibleCategory", ttt2tpnl)
	ttt2tclp:SetSize(390, 50)
	ttt2tclp:SetExpanded(1)
	ttt2tclp:SetLabel("Basic Settings")

	local ttt2tlst = vgui.Create("DPanelList", ttt2tclp)
	ttt2tlst:SetPos(5, 25)
	ttt2tlst:SetSize(390, 50)
	ttt2tlst:SetSpacing(5)

	local ttt2tdh = xlib.makecheckbox{label = "Enable Totem? (ttt2_totem) (def. 1)", repconvar = "rep_ttt2_totem", parent = ttt2tlst}
	ttt2tlst:AddItem(ttt2tdh)

	local ttt2tdh2 = xlib.makecheckbox{label = "ttt2_totem_enable_speedmodifier (def. 1)", repconvar = "rep_ttt2_totem_enable_speedmodifier", parent = ttt2tlst}
	ttt2tlst:AddItem(ttt2tdh2)

	xgui.hookEvent("onProcessModules", nil, ttt2tpnl.processModules)
	xgui.addSubModule("TTT2 Totem", ttt2tpnl, nil, name)
end)
