TTT2Totem = {}

hook.Add("TTTPlayerSpeedModifier", "TTT2TotemSpeed", function(ply)
	if not GetConVar("ttt2_totem"):GetBool() or not TTT2Totem.AnyTotems then return end

	local rs = GetRoundState()

	if rs == ROUND_ACTIVE or rs == ROUND_POST then

		if not ply.PlacedTotem then
			return 0.4
		else
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
			else
				return 0.75
			end
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
