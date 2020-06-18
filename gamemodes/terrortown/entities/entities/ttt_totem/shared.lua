if SERVER then
	AddCSLuaFile()

	resource.AddFile("models/entities/ttt2_totem/totem.mdl")
	resource.AddFile("materials/models/ttt2_totem/Totem.vmt")
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/entities/ttt2_totem/totem.mdl")
ENT.CanUseKey = true
ENT.CanPickup = true

function ENT:Initialize()
	self:SetModel(self.Model)

	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	if SERVER then
		self:SetMaxHealth(100)
		self:SetHealth(100)
		self:SetUseType(SIMPLE_USE)
	end

	self:PhysWake()
end

function ENT:UseOverride(activator)
	local owner = self:GetOwner()

	local max_pickups = GetConVar("ttt2_totem_max_totem_pickups"):GetInt()

	if IsValid(activator) and activator:IsTerror() and owner == activator
		and (activator.numTotemPickups < max_pickups or max_pickups == -1)
	then
		activator.CanSpawnTotem = true
		activator.PlacedTotem = false

		activator:SetNWEntity("Totem", NULL)

		if not activator.numTotemPickups then
			activator.numTotemPickups = 0
		end

		activator.numTotemPickups = activator.numTotemPickups + 1

		LANG.Msg(activator, "totem_picked_up", nil, MSG_MSTACK_PLAIN)

		self:Remove()

		if SERVER then
			timer.Simple(0.01, function()
				TotemUpdate()
			end)
		end
	elseif IsValid(activator) and activator:IsTerror() and owner == activator and activator.numTotemPickups >= max_pickups then
		if max_pickups == 0 then
			LANG.Msg(activator, "totem_already_no_pickup", nil, MSG_MSTACK_WARN)
		elseif activator.numTotemPickups >= max_pickups then
			LANG.Msg(activator, "totem_already_picked_up", {num = max_pickups}, MSG_MSTACK_WARN)
		end
	end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")

function ENT:OnTakeDamage(dmginfo)
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local owner, att, infl = self:GetOwner(), dmginfo:GetAttacker(), dmginfo:GetInflictor()

	if not IsValid(owner) or infl == owner or att == owner or owner:HasTeam(TEAM_TRAITOR) or not infl.IsTotemhunter and not att.IsTotemhunter then return end

	if (infl:IsPlayer() and infl:IsTotemhunter() or att:IsPlayer() and att:IsTotemhunter()) and infl:GetClass() == "weapon_ttt_totemknife" then
		if SERVER and owner:IsValid() and att:IsValid() and att:IsPlayer() then
			LANG.MsgAll("totem_destroyed", nil, MSG_MSTACK_WARN)
		end

		GiveTotemHunterCredits(att, self)

		local effect = EffectData()
		effect:SetOrigin(self:GetPos())

		util.Effect("cball_explode", effect)

		sound.Play(zapsound, self:GetPos())

		self:GetOwner():SetNWEntity("Totem", NULL)
		self:Remove()

		if SERVER then
			timer.Simple(0.01, function()
				TotemUpdate()
			end)
		end
	end
end

function ENT:FakeDestroy()
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())

	util.Effect("cball_explode", effect)

	sound.Play(zapsound, self:GetPos())

	self:GetOwner():SetNWEntity("Totem", NULL)
	self:Remove()

	if SERVER then
		timer.Simple(0.01, function()
			TotemUpdate()
		end)
	end
end

hook.Add("PlayerDisconnected", "TTT2TotemDestroy", function(ply)
	if IsValid(ply:GetTotem()) then
		ply:GetTotem():FakeDestroy()
	end
end)

if CLIENT then
	local TryT = LANG.TryTranslation
	local GetPT = LANG.GetParamTranslation
	local key_params = {
		usekey = Key("+use", "USE"),
	}

	-- target ID function
	hook.Add("TTTRenderEntityInfo", "TTT2TotemEntityInfo", function(tData)
		local client = LocalPlayer()
		local e = tData:GetEntity()
		local owner = e:GetOwner()

		if not TOTEMHUNTER then return end

		if not IsValid(owner) or e:GetClass() ~= "ttt_totem" or tData:GetEntityDistance() > 100 then return end

		local ownsTotem = client == owner
		local sameTeam = owner:GetTeam() == client:GetTeam()
		local isTHunter = client.IsTotemhunter and client:IsTotemhunter()
		local textTotemOwner = TryT("totem_other_terrorist")

		if isTHunter then
			local nick = owner:Nick()
			textTotemOwner = "This is " .. nick .. "'s Totem"

			if string.EndsWith(nick, "s") or string.EndsWith(nick, "x") or string.EndsWith(nick, "z") or string.EndsWith(nick, "ß") then
				textTotemOwner = "This is " .. nick .. "' Totem"
			end
		end

		-- enable targetID rendering
		tData:EnableText()
		tData:EnableOutline(isTHunter)
		tData:SetOutlineColor(not ownsTotem and sameTeam and COLOR_GREEN or COLOR_RED)

		tData:SetTitle("Totem")
		tData:SetSubtitle(textTotemOwner)

		if ownsTotem then
			tData:SetKeyBinding("+use")
			tData:SetSubtitle(GetPT("target_pickup", key_params))
			tData:AddDescriptionLine(TryT("totem_own_totem"))
		else
			tData:AddIcon(
				TOTEMHUNTER.iconMaterial,
				COLOR_WHITE
			)
		end

		if isTHunter and sameTeam and not ownsTotem then
			tData:AddDescriptionLine(TryT("totem_teammate_totem"))
		end

		local activeWeapon = client:GetActiveWeapon()

		if not sameTeam and IsValid(activeWeapon) and activeWeapon:GetClass() == "weapon_ttt_totemknife" then
			tData:AddDescriptionLine(
				TryT("totem_destroy_totem"),
				TOTEMHUNTER.color
			)
		end
	end)
end
