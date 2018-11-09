CreateConVar("ttt_totem_auto", "1", {FCVAR_ARCHIVE}, "Soll das Totem automatisch plaziert werden?")

hook.Add("TTTBeginRound", "TTTTotemAutomaticPlacement", function()
	if not GetConVar("ttt_totem_auto"):GetBool() then return end

	LocalPlayer():ConCommand("placetotem")
end)

local function LookUpTotem(ply, cmd, args, argStr)
	if not TotemEnabled() then return end

	if GetRoundState() ~= ROUND_WAIT and LocalPlayer():IsTerror() then
		net.Start("TTTVotePlaceTotem")
		net.SendToServer()
	end
end
concommand.Add("placetotem", LookUpTotem, nil, "Places a Totem", {FCVAR_DONTRECORD})
