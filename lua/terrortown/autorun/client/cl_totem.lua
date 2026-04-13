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

	if not IsValid(ply) or not ply:IsTerror() or GetRoundState() == ROUND_WAIT or ply:HasTotem() or not ttt2net.GetGlobal({"TTT2Totem", "AnyTotems"}) then
		timer.Remove("TTT2AutoPlaceTotem")

		return
	end

	LookUpTotem()
end

hook.Add("TTTBeginRound", "TTT2TotemAutomaticPlacement", function()
	if not GetGlobalBool("ttt2_totem", false) or not totem_autoplace:GetBool() then return end

	AutoPlace()

	timer.Create("TTT2AutoPlaceTotem", 2, 6, AutoPlace)
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
