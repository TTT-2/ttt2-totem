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
	if IsValid(activator) and activator:IsTerror() and self:GetOwner() == activator and activator.totemuses < 2 then
		activator.CanSpawnTotem = true
		activator.PlacedTotem = false

		activator:SetNWEntity("Totem", NULL)

		if not activator.totemuses then
			activator.totemuses = 0
		end

		activator.totemuses = activator.totemuses + 1

		net.Start("TTT2Totem")
		net.WriteInt(4, 8)
		net.Send(activator)

		self:Remove()

		if SERVER then
			timer.Simple(0.01, function()
				TotemUpdate()
			end)
		end
	elseif IsValid(activator) and activator:IsTerror() and self:GetOwner() == activator and activator.totemuses >= 2 then
		net.Start("TTT2Totem")
		net.WriteInt(7, 8)
		net.Send(activator)
	end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")

function ENT:OnTakeDamage(dmginfo)
	if GetRoundState() ~= ROUND_ACTIVE then return end

	local owner, att, infl = self:GetOwner(), dmginfo:GetAttacker(), dmginfo:GetInflictor()

	if not IsValid(owner) or infl == owner or att == owner or owner:HasTeam(TEAM_TRAITOR) or not infl.IsTotemhunter and not att.IsTotemhunter then return end

	if (infl:IsPlayer() and infl:IsTotemhunter() or att:IsPlayer() and att:IsTotemhunter()) and infl:GetClass() == "weapon_ttt_totemknife" then
		if SERVER and owner:IsValid() and att:IsValid() and att:IsPlayer() then
			net.Start("TTT2Totem")
			net.WriteInt(5, 8)
			net.Broadcast()
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
	hook.Add("TTTRenderEntityInfo", "TTT2TotemEntityInfo", function(data, params)
		local client = LocalPlayer()
		local e = data.ent
		local owner = e:GetOwner()

		if not IsValid(owner) or e:GetClass() ~= "ttt_totem" or data.distance > 100 then return end

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

		params.drawInfo = true
		params.displayInfo.title.text = "Totem"

		params.drawOutline = isTHunter
		params.outlineColor = not ownsTotem and sameTeam and COLOR_GREEN or COLOR_RED

		params.displayInfo.subtitle.text = textTotemOwner

		if ownsTotem then
			params.displayInfo.key = input.GetKeyCode(input.LookupBinding("+use"))
			params.displayInfo.subtitle.text = GetPT("target_pickup", key_params)
			params.displayInfo.desc[#params.displayInfo.desc + 1] = {
				text = TryT("totem_own_totem"),
			}
		elseif TOTEMHUNTER then
			params.displayInfo.icon[#params.displayInfo.icon + 1] = {
				material = TOTEMHUNTER.iconMaterial,
				color = COLOR_WHITE,
			}
		end

		if isTHunter and sameTeam and not ownsTotem then
			params.displayInfo.desc[#params.displayInfo.desc + 1] = {
				text = TryT("totem_teammate_totem"),
			}
		end
		local activeWeapon = client:GetActiveWeapon()
		if TOTEMHUNTER and not sameTeam and activeWeapon and activeWeapon:GetClass() == "weapon_ttt_totemknife" then
			params.displayInfo.desc[#params.displayInfo.desc + 1] = {
				text = TryT("totem_destroy_totem"),
				color = TOTEMHUNTER.color,
			}
		end
	end)
end
