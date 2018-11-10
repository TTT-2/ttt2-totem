if SERVER then
	AddCSLuaFile()

	resource.AddFile("models/gamefreak/frenchie/bulkytotem.mdl")
	resource.AddFile("materials/models/frenchie/bulkytotem/ed3555af.vmt")
	resource.AddFile("materials/models/frenchie/bulkytotem/a4c3dbeb.vmt")
	resource.AddFile("materials/models/frenchie/bulkytotem/6348b211.vmt")
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/gamefreak/frenchie/bulkytotem.mdl")
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
	hook.Add("HUDDrawTargetID", "DrawTotem", function()
		local client = LocalPlayer()
		local e = client:GetEyeTrace().Entity

		if IsValid(e) and IsValid(e:GetOwner()) and e:GetClass() == "ttt_totem" and (e:GetOwner() == client or client.IsTotemhunter and client:IsTotemhunter()) then
			local owner = e:GetOwner():Nick()

			if string.EndsWith(owner, "s") or string.EndsWith(owner, "x") or string.EndsWith(owner, "z") or string.EndsWith(owner, "ß") then
				draw.SimpleText(e:GetOwner():Nick() .. "' Totem", "TargetID", ScrW() * 0.5 + 1, ScrH() * 0.5 + 41, COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(e:GetOwner():Nick() .. "' Totem", "TargetID", ScrW() * 0.5, ScrH() * 0.5 + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText(e:GetOwner():Nick() .. "s Totem", "TargetID", ScrW() * 0.5 + 1, ScrH() * 0.5 + 41, COLOR_BLACK, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(e:GetOwner():Nick() .. "s Totem", "TargetID", ScrW() * 0.5, ScrH() * 0.5 + 40, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end)
end
