TTTVote.AnyTotems = true

util.AddNetworkString("TTTTotem")
util.AddNetworkString("TTTVotePlaceTotem")

function PlaceTotem(len, sender)
	local ply = sender

	if not IsValid(ply) or not ply:IsTerror() then return end

	if not ply.CanSpawnTotem or IsValid(ply:GetNWEntity("Totem", NULL)) or ply.PlaceTotem then
		net.Start("TTTTotem")
		net.WriteInt(1, 8)
		net.Send(ply)

		return
	end

	if not ply:OnGround() then
		net.Start("TTTTotem")
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

			net.Start("TTTTotem")
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
	if GetRoundState() == ROUND_ACTIVE then
		ply.CanSpawnTotem = false
		ply.TotemSuffer = 0

		TotemUpdate()
	end
end

function TotemUpdate()
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

			net.Start("TTTTotem")
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

local function TotemSuffer()
	if GetRoundState() == ROUND_ACTIVE and TTT2Totem.AnyTotems then
		for _, v in ipairs(player.GetAll()) do
			if v:IsTerror() and not v.PlacedTotem and v.TotemSuffer then
				if v.TotemSuffer == 0 then
					v.TotemSuffer = CurTime() + 10
					v.DamageNotified = false
				elseif v.TotemSuffer <= CurTime() then
					if not v.DamageNotified then
						net.Start("TTTTotem")
						net.WriteInt(6, 8)
						net.Send(v)

						v.DamageNotified = true
					end

					v:TakeDamage(1)

					v.TotemSuffer = CurTime() + 0.2
				end
			elseif v:IsTerror() and (v.PlacedTotem or not v.TotemSuffer) then
				v.TotemSuffer = 0
				v.DamageNotified = false
			end
		end
	end
end

function GiveTotemHunterCredits(ply, totem)
	LANG.Msg(ply, "credit_h_all", {num = 1})

	ply:AddCredits(1)
end

local function ResetTotems()
	for _, v in ipairs(player.GetAll()) do
		v.CanSpawnTotem = true
		v.PlacedTotem = false

		v:SetNWEntity("Totem", NULL)

		v.TotemSuffer = 0
		v.DamageNotified = false
		v.totemuses = 0
	end

	TTT2Totem.AnyTotems = true
end

local function ResetSuffer()
	for _, v in ipairs(player.GetAll()) do
		v.TotemSuffer = 0
	end
end

local function TotemInit(ply)
	ply.CanSpawnTotem = true
	ply.PlacedTotem = false

	ply:SetNWEntity("Totem", NULL)

	ply.TotemSuffer = 0
	ply.DamageNotified = false
	ply.totemuses = 0
end

hook.Add("PlayerInitialSpawn", "TTTTotemInit", TotemInit)
hook.Add("TTTPrepareRound", "ResetValues", ResetTotems)
hook.Add("PlayerDeath", "TTTDestroyTotem", DestroyTotem)
hook.Add("Think", "TotemSuffer", TotemSuffer)
hook.Add("TTTBeginRound", "TTTTotemSync", TotemUpdate)
hook.Add("TTTBeginRound", "TTTTotemResetSuffer", ResetSuffer)
hook.Add("PlayerDisconnected", "TTTTotemSync", TotemUpdate)
