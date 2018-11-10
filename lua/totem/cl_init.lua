CreateConVar("ttt_totem_auto", "1", {FCVAR_ARCHIVE}, "Soll das Totem automatisch plaziert werden?")

net.Receive("TTT2ClientInitTotem", function()
	include("totem/client/cl_menu.lua")
end)

hook.Add("TTTBeginRound", "TTT2TotemAutomaticPlacement", function()
	if not GetConVar("ttt_totem_auto"):GetBool() then return end

	LocalPlayer():ConCommand("placetotem")
end)

function LookUpTotem(ply, cmd, args, argStr)
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
