util.AddNetworkString("TTT2TotemPlaceTotem")
util.AddNetworkString("TTT2ClientInitTotem")

local totem_enabled = CreateConVar("ttt2_totem", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})
local walk_speed_enabled = CreateConVar("ttt2_totem_enable_speedmodifier", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

CreateConVar("ttt2_totem_max_totem_pickups", "2", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

-- initial global var sync
hook.Add("TTT2SyncGlobals", "TTT2TotemSyncGlobals", function()
	SetGlobalBool("ttt2_totem", totem_enabled:GetBool())
	SetGlobalBool("ttt2_totem_enable_speedmodifier", walk_speed_enabled:GetBool())
end)

function PlaceTotem(len, sender)
	if not totem_enabled:GetBool() then return end

	local ply = sender

	if not IsValid(ply) or not ply:IsTerror() then return end

	if not ply.CanSpawnTotem or IsValid(ply:GetNWEntity("Totem", NULL)) or ply.PlaceTotem then
		LANG.Msg(ply, "totem_already_placed", nil, MSG_MSTACK_WARN)

		return
	end

	if not ply:OnGround() then
		LANG.Msg(ply, "totem_place_ground_needed", nil, MSG_MSTACK_WARN)

		return
	end

	if ply:IsInWorld() then
		local totem = ents.Create("ttt_totem")

		if IsValid(totem) then
			totem:SetAngles(ply:GetAngles())
			totem:SetPos(ply:GetPos() + Vector(0, 0, 18))
			totem:SetOwner(ply)
			totem:Spawn()

			ply.CanSpawnTotem = false
			ply.PlacedTotem = true

			ply:SetNWEntity("Totem", totem)

			LANG.Msg(ply, "totem_placed", nil, MSG_MSTACK_ROLE)

			TotemUpdate()
		end
	end
end
net.Receive("TTT2TotemPlaceTotem", PlaceTotem)

local function DestroyAllTotems()
	for _, v in pairs(ents.FindByClass("ttt_totem")) do
		v:FakeDestroy()
	end

	for _, v in ipairs(player.GetAll()) do
		v.CanSpawnTotem = false
	end

	TotemUpdate()
end

function TotemUpdate()
	if not totem_enabled:GetBool() then return end

	if GetRoundState() == ROUND_ACTIVE or GetRoundState() == ROUND_POST then
		local totems = {}

		for _, v in ipairs(player.GetAll()) do
			if (v:IsTerror() or not v:Alive()) and (v:HasTotem() or v.CanSpawnTotem) and ttt2net.GetGlobal({"TTT2Totem", "AnyTotems"}) then
				table.insert(totems, v)
			end
		end

		if #totems >= 1 then
			ttt2net.SetGlobal({"TTT2Totem", "AnyTotems"}, { type = "bool" }, true)
		else
			ttt2net.SetGlobal({"TTT2Totem", "AnyTotems"}, { type = "bool" }, false)

			LANG.MsgAll("totem_all_destroyed", nil, MSG_MSTACK_WARN)

			return
		end

		local innototems = {}

		for _, v in ipairs(totems) do
			if not v:HasTeam(TEAM_TRAITOR) then
				table.insert(innototems, v)
			end
		end

		if ttt2net.GetGlobal({"TTT2Totem", "AnyTotems"}) and #innototems == 0 then
			DestroyAllTotems()
		end
	end
end

function GiveTotemHunterCredits(ply, totem)
	LANG.Msg(ply, "credit_h_all", {num = 1}) -- TODO localization

	ply:AddCredits(1)
end

local function ResetTotems()
	for _, v in ipairs(player.GetAll()) do
		v.CanSpawnTotem = true
		v.PlacedTotem = false

		v:SetNWEntity("Totem", NULL)

		v.DamageNotified = false
		v.numTotemPickups = 0
	end

	ttt2net.SetGlobal({"TTT2Totem", "AnyTotems"}, { type = "bool" }, false)
end

local function TotemInit(ply)
	if not totem_enabled:GetBool() then return end

	net.Start("TTT2ClientInitTotem")
	net.Send(ply)

	ply.CanSpawnTotem = true
	ply.PlacedTotem = false

	ply:SetNWEntity("Totem", NULL)

	ply.DamageNotified = false
	ply.numTotemPickups = 0
end

hook.Add("PlayerInitialSpawn", "TTT2TotemInit", TotemInit)
hook.Add("TTTPrepareRound", "TTT2ResetValues", ResetTotems)
hook.Add("TTTBeginRound", "TTT2TotemSync", TotemUpdate)
hook.Add("PlayerDisconnected", "TTT2TotemSync", TotemUpdate)

hook.Add("TTTUlxInitCustomCVar", "TTTTotemInitRWCVar", function(name)
	ULib.replicatedWritableCvar("ttt2_totem", "rep_ttt2_totem", GetConVar("ttt2_totem"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt2_totem_enable_speedmodifier", "rep_ttt2_totem_enable_speedmodifier", GetConVar("ttt2_totem_enable_speedmodifier"):GetBool(), true, false, name)
	ULib.replicatedWritableCvar("ttt2_totem_max_totem_pickups", "rep_ttt2_totem_max_totem_pickups", GetConVar("ttt2_totem_max_totem_pickups"):GetBool(), true, false, name)
end)

cvars.AddChangeCallback("ttt2_totem", function(cvar, old, new)
	SetGlobalBool("ttt2_totem", tobool(tonumber(new)))

	if old ~= new and old == "1" and new == "0" then
		DestroyAllTotems()
		ResetTotems()
	end
end)
cvars.AddChangeCallback("ttt2_totem_enable_speedmodifier", function(cv, old, new)
	SetGlobalBool("ttt2_totem_enable_speedmodifier", tobool(tonumber(new)))
end)
