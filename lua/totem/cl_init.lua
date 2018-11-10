local totem_enabled = CreateConVar("ttt2_totem", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})

CreateConVar("ttt_totem_auto", "1", {FCVAR_ARCHIVE}, "Soll das Totem automatisch plaziert werden?")

net.Receive("TTT2ClientInitTotem", function()
	include("totem/client/cl_menu.lua")
end)

hook.Add("TTTBeginRound", "TTT2TotemAutomaticPlacement", function()
	if not totem_enabled:GetBool() or not GetConVar("ttt_totem_auto"):GetBool() then return end

	LocalPlayer():ConCommand("placetotem")
end)

function LookUpTotem(ply, cmd, args, argStr)
	if not totem_enabled:GetBool() then return end

	if GetRoundState() ~= ROUND_WAIT and LocalPlayer():IsTerror() then
		net.Start("TTT2TotemPlaceTotem")
		net.SendToServer()
	end
end
concommand.Add("placetotem", LookUpTotem, nil, "Places a Totem", {FCVAR_DONTRECORD})

net.Receive("TTT2Totem", function()
	local bool = net.ReadInt(8)

	if bool == 1 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Du hast schon ein Totem platziert!")
	elseif bool == 2 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Du musst beim Plazieren deines Totems auf dem Boden stehen!")
	elseif bool == 3 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Dein Totem wurde erfolgreich platziert!")

		LocalPlayer().PlacedTotem = true
	elseif bool == 4 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Du hast dein Totem erfolgreich aufgehoben!")

		LocalPlayer().PlacedTotem = false
	elseif bool == 5 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Ein Totem wurde zerstört!")
	elseif bool == 6 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Du bist nun deutlich langsamer, weil du kein Totem platziert hast!")
	elseif bool == 7 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Du hast dein Totem schon 2 mal aufgehoben!")
	elseif bool == 8 then
		chat.AddText("TTT2 Totem: ", COLOR_WHITE, "Alle Totems wurden zerstört!")
	end

	chat.PlaySound()
end)

--------------------TTT2Totem Module--------------------
hook.Add("TTTUlxModifySettings", "TTT2TotemModifySettings", function(name)
	local ttt2tpnl = xlib.makelistlayout{w = 415, h = 318, parent = xgui.null}

	local ttt2tclp = vgui.Create("DCollapsibleCategory", ttt2tpnl)
	ttt2tclp:SetSize(390, 25)
	ttt2tclp:SetExpanded(1)
	ttt2tclp:SetLabel("TTT2 Totem")

	local ttt2tlst = vgui.Create("DPanelList", ttt2tclp)
	ttt2tlst:SetPos(5, 25)
	ttt2tlst:SetSize(390, 25)
	ttt2tlst:SetSpacing(5)

	local ttt2tdh = xlib.makecheckbox{label = "ttt2_totem (def. 1)", repconvar = "rep_ttt2_totem", parent = ttt2tlst}
	ttt2tlst:AddItem(ttt2tdh)

	xgui.hookEvent("onProcessModules", nil, ttt2tpnl.processModules)
	xgui.addSubModule("TTT2 Totem", ttt2tpnl, nil, name)
end)
