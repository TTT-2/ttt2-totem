if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_thunt.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(222, 68, 0, 255)

	self.abbr = "thunt"

	self.score.surviveBonusMultiplier = 0.5
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 2
	self.score.teamKillsMultiplier = -16
	self.score.bodyFoundMuliplier = 0

	self.defaultTeam = TEAM_TRAITOR
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.15,
		maximum = 1,
		minPlayers = 6,

		credits = 0,
		creditsAwardDeadEnable = 0,
		creditsAwardKillEnable = 0,

		random = 50,
		traitorButton = 1,

		togglable = true,
		shopFallback = SHOP_FALLBACK_TRAITOR
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_TRAITOR)
end

if SERVER then
	-- the custom radar for the totemhunter to display all totem positions
	ROLE.CustomRadar = function(ply) -- Custom Radar function
		if ttt2net.GetGlobal({"TTT2Totem", "AnyTotems"}) then
			local targets = {}
			local scan_ents = ents.FindByClass("ttt_totem")

			for _, t in pairs(scan_ents) do
				local pos = t:LocalToWorld(t:OBBCenter())

				pos.x = math.Round(pos.x)
				pos.y = math.Round(pos.y)
				pos.z = math.Round(pos.z)

				local owner = t:GetOwner()
				if owner ~= ply and not owner:HasTeam(TEAM_TRAITOR) then
					table.insert(targets, {subrole = -1, pos = pos})
				end
			end

			return targets
		else
			return false
		end
	end

	-- Give Loadout on respawn and rolechange	
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentWeapon("weapon_ttt_totemknife")
		ply:GiveEquipmentItem("item_ttt_radar")
	end

	-- Remove Loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:StripWeapon("weapon_ttt_totemknife")
		ply:RemoveEquipmentItem("item_ttt_radar")
	end

	hook.Add("TTT2RoleNotSelectable", "TTT2TotemDisableTotemhunter", function(roleData)
		if roleData == TOTEMHUNTER and not GetConVar("ttt2_totem"):GetBool() then
			return true
		end
	end)

	local oldValue

	hook.Add("TTT2RoleVoteWinner", "TTT2ThuntEnableTotem", function(role)
		local cvar = GetConVar("ttt2_totem")

		oldValue = tostring(cvar:GetInt())

		if role == ROLE_TOTEMHUNTER and not cvar:GetBool() then
			RunConsoleCommand("ttt2_totem", "1")
		else
			RunConsoleCommand("ttt2_totem", oldValue)
		end
	end)
end
