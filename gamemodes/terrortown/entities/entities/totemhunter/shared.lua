if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_thunt.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_thunt.vmt")
end

local tmp = { -- first param is access for ROLES array => ROLES["TOTEMHUNTER"] or ROLES.TOTEMHUNTER or TOTEMHUNTER
	color = Color(255, 128, 0, 255), -- ...
	dkcolor = Color(155, 78, 0, 255), -- ...
	bgcolor = Color(5, 125, 159, 255), -- ...
	abbr = "thunt", -- abbreviation
	defaultTeam = TEAM_TRAITOR, -- the team name: roles with same team name are working together
	defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
	surviveBonus = 0.5, -- bonus multiplier for every survive while another player was killed
	scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
	scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
}

if SERVER then
	tmp.CustomRadar = function(ply) -- Custom Radar function
		if TTT2Totem.AnyTotems then
			local targets = {}
			local scan_ents = ents.FindByClass("ttt_totem")

			for _, t in pairs(scan_ents) do
				local pos = t:LocalToWorld(t:OBBCenter())

				pos.x = math.Round(pos.x)
				pos.y = math.Round(pos.y)
				pos.z = math.Round(pos.z) - 100

				local owner = t:GetOwner()
				if owner ~= ply and not owner:HasTeam(TEAM_TRAITOR) then
					table.insert(targets, {role = -1, pos = pos})
				end
			end

			return targets
		else
			return false
		end
	end
end

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
InitCustomRole("TOTEMHUNTER", tmp, {
		pct = 0.15, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 6, -- minimum amount of players until this role is able to get selected
		credits = 0, -- the starting credits of a specific role
		togglable = true, -- option to toggle a role for a client if possible (F1 menu)
		random = 50,
		shopFallback = SHOP_FALLBACK_TRAITOR
})

-- now link this subrole with its baserole
hook.Add("TTT2BaseRoleInit", "TTT2ConBRTWithThunt", function()
	SetBaseRole(TOTEMHUNTER, ROLE_TRAITOR)
end)

-- if sync of roles has finished
hook.Add("TTT2FinishedLoading", "TotemhunterInitT", function()
	if CLIENT then
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", TOTEMHUNTER.name, "Totemhunter")
		LANG.AddToLanguage("English", "info_popup_" .. TOTEMHUNTER.name, [[You are a Totemhunter! Try to destroy some Totems!]])
		LANG.AddToLanguage("English", "body_found_" .. TOTEMHUNTER.abbr, "This was a Totemhunter...")
		LANG.AddToLanguage("English", "search_role_" .. TOTEMHUNTER.abbr, "This person was a Totemhunter!")
		LANG.AddToLanguage("English", "target_" .. TOTEMHUNTER.name, "Totemhunter")
		LANG.AddToLanguage("English", "ttt2_desc_" .. TOTEMHUNTER.name, [[The Totemhunter is a Traitor (who works together with the other traitors) and the goal is to kill all other roles except the other traitor roles ^^ The Totemhunter is able to destroy the totems of his enemies.]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", TOTEMHUNTER.name, "Totemhunter")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. TOTEMHUNTER.name, [[Du bist ein Totemhunter! Versuche ein paar Totems zu zerstören!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. TOTEMHUNTER.abbr, "Er war ein Totemhunter...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. TOTEMHUNTER.abbr, "Diese Person war ein Totemhunter!")
		LANG.AddToLanguage("Deutsch", "target_" .. TOTEMHUNTER.name, "Totemhunter")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. TOTEMHUNTER.name, [[Der Totemhunter ist ein Verräter (der mit den anderen Verräter-Rollen zusammenarbeitet) und dessen Ziel es ist, alle anderen Rollen (außer Verräter-Rollen) zu töten ^^ Er kann die Totems seiner Feinde zerstören.]])
	end
end)

if SERVER then
	-- is called if the role has been selected in the normal way of team setup
	hook.Add("TTT2UpdateSubrole", "UpdateToTotemhunterRole", function(ply, old, new)
		if new == ROLE_TOTEMHUNTER then
			ply:StripWeapon("weapon_zm_improvised")
			ply:Give("weapon_ttt_totemknife")
			ply:GiveItem(EQUIP_RADAR)
		end
	end)

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
