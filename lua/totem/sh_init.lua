TTT2Totem = {}

hook.Add("TTTPlayerSpeedModifier", "TTT2TotemSpeed", function(ply)
	if (GetRoundState() == ROUND_ACTIVE or GetRoundState() == ROUND_POST) and TTT2Totem.AnyTotems then
		local Totem = ply:GetTotem()

		if IsValid(Totem) then
			local distance = Totem:GetPos():Distance(ply:GetPos())
			if distance >= 2500 then
				return math.Round(math.Remap(distance, 2500, 5000, 1, 0.75), 2)
			elseif distance <= 1000 then
				return 1.25
			elseif distance > 1000 and distance < 2500 then
				return 1
			end
		elseif not ply.PlacedTotem then
			return 0.5
		else
			return 0.75
		end
	end
end)

local plymeta = FindMetaTable("Player")

function plymeta:GetTotem()
	return self:GetNWEntity("Totem", NULL)
end

function plymeta:HasTotem()
	return IsValid(self:GetTotem())
end
