TTT2Totem.AnyTotems = true

util.AddNetworkString("TTT2Totem")
util.AddNetworkString("TTT2TotemPlaceTotem")
util.AddNetworkString("TTT2ClientInitTotem")

local totem_enabled = CreateConVar("ttt2_totem", "1", {FCVAR_NOTIFY, FCVAR_ARCHIVE})

function PlaceTotem(len, sender)
	if not totem_enabled:GetBool() then return end

	local ply = sender

	if not IsValid(ply) or not ply:IsTerror() then return end

	if not ply.CanSpawnTotem or IsValid(ply:GetNWEntity("Totem", NULL)) or ply.PlaceTotem then
		net.Start("TTT2Totem")
		net.WriteInt(1, 8)
		net.Send(ply)

		return
	end

	if not ply:OnGround() then
		net.Start("TTT2Totem")
		net.WriteInt(2, 8)
		net.Send(ply)

		return
	end

	if ply:IsInWorld() then
		local totem = ents.Create("ttt_totem")

		if IsValid(totem) then
			totem:SetAngles(ply:GetAngles())
			totem:SetPos(ply:GetPos())
			totem:SetOwner(ply)
			totem:Spawn()

			ply.CanSpawnTotem = false
			ply.PlacedTotem = true

			ply:SetNWEntity("Totem", totem)

			net.Start("TTT2Totem")
			net.WriteInt(3, 8)
			net.Send(ply)

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

local function DestroyTotem(ply)
	if not totem_enabled:GetBool() then return end

	local totem = ply:GetTotem()

	if IsValid(totem) then
		totem:FakeDestroy()
	end
end

function TotemUpdate()
	if not totem_enabled:GetBool() then return end

	if GetRoundState() == ROUND_ACTIVE or GetRoundState() == ROUND_POST then
		local totems = {}

		for _, v in ipairs(player.GetAll()) do
			if (v:IsTerror() or not v:Alive()) and (v:HasTotem() or v.CanSpawnTotem) and TTT2Totem.AnyTotems then
				table.insert(totems, v)
			end
		end

		if #totems >= 1 then
			TTT2Totem.AnyTotems = true
		else
			TTT2Totem.AnyTotems = false

			net.Start("TTT2Totem")
			net.WriteInt(8, 8)
			net.Broadcast()

			return
		end

		local innototems = {}

		for _, v in ipairs(totems) do
			if not v:HasTeam(TEAM_TRAITOR) then
				table.insert(innototems, v)
			end
		end

		if TTT2Totem.AnyTotems and #innototems == 0 then
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
		v.totemuses = 0
	end

	TTT2Totem.AnyTotems = true
end

local function TotemInit(ply)
	if not totem_enabled:GetBool() then return end

	net.Start("TTT2ClientInitTotem")
	net.Send(ply)

	ply.CanSpawnTotem = true
	ply.PlacedTotem = false

	ply:SetNWEntity("Totem", NULL)

	ply.DamageNotified = false
	ply.totemuses = 0
end

hook.Add("PlayerInitialSpawn", "TTT2TotemInit", TotemInit)
hook.Add("TTTPrepareRound", "TTT2ResetValues", ResetTotems)
hook.Add("PlayerDeath", "TTT2DestroyTotem", DestroyTotem)
hook.Add("TTTBeginRound", "TTT2TotemSync", TotemUpdate)
hook.Add("PlayerDisconnected", "TTT2TotemSync", TotemUpdate)

hook.Add("TTTUlxInitRWCVar", "TTTTotemInitRWCVar", function(name)
	ULib.replicatedWritableCvar("ttt2_totem", "rep_ttt2_totem", GetConVar("ttt2_totem"):GetInt(), true, false, name)
end)

cvars.AddChangeCallback("ttt2_totem", function(cvar, old, new)
	if old ~= new and old == "1" and new == "0" then
		DestroyAllTotems()
		ResetTotems()
	end
end)
