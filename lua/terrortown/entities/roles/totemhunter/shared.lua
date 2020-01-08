if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_thunt.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(222, 68, 0, 255) -- ...
	self.dkcolor = Color(138, 43, 0, 255) -- ...
	self.bgcolor = Color(0, 150, 93, 255) -- ...
	self.abbr = "thunt" -- abbreviation
	self.surviveBonus = 0.5 -- bonus multiplier for every survive while another player was killed
	self.scoreKillsMultiplier = 5 -- multiplier for kill of player of another team
	self.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
	self.defaultTeam = TEAM_TRAITOR -- the team name: roles with same team name are working together
	self.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
	self.conVarData = {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		credits = 0, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 50,
		traitorButton = 1, -- can use traitor buttons
		shopFallback = SHOP_FALLBACK_TRAITOR
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_TRAITOR)

	if CLIENT then
		-- setup basic translation !
		LANG.AddToLanguage("English", self.name, "Totemhunter")
		LANG.AddToLanguage("English", "info_popup_" .. self.name, [[You are a Totemhunter! Try to destroy some Totems!]])
		LANG.AddToLanguage("English", "body_found_" .. self.abbr, "This was a Totemhunter...")
		LANG.AddToLanguage("English", "search_role_" .. self.abbr, "This person was a Totemhunter!")
		LANG.AddToLanguage("English", "target_" .. self.name, "Totemhunter")
		LANG.AddToLanguage("English", "ttt2_desc_" .. self.name, [[The Totemhunter is a Traitor (who works together with the other traitors) and the goal is to kill all other roles except the other traitor roles ^^ The Totemhunter is able to destroy the totems of his enemies.]])

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", self.name, "Totemhunter")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. self.name, [[Du bist ein Totemhunter! Versuche ein paar Totems zu zerstören!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. self.abbr, "Er war ein Totemhunter...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. self.abbr, "Diese Person war ein Totemhunter!")
		LANG.AddToLanguage("Deutsch", "target_" .. self.name, "Totemhunter")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. self.name, [[Der Totemhunter ist ein Verräter (der mit den anderen Verräter-Rollen zusammenarbeitet) und dessen Ziel es ist, alle anderen Rollen (außer Verräter-Rollen) zu töten ^^ Er kann die Totems seiner Feinde zerstören.]])
	end
end

if SERVER then

	-- the custom radar for the totemhunter to display all totem positions
	ROLE.CustomRadar = function(ply) -- Custom Radar function
		if TTT2Totem.AnyTotems then
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
