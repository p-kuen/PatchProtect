--Set PropProtection for Props and Tools (Quite Simple at the moment!)

function CheckPlayer(ply, ent)

	--print(tobool(GetConVarNumber("_PatchProtect_PropProtection_UsePP")))
	if ent.name != nil then

		if ent.name == ply:GetName() then

			return true

		else

			PAS.Notify( ply, "You are not allowed to do this!" )
			return false

		end

	else

		ent.name = ply:GetName()
		return true

	end
	
end

hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )
--hook.Add( "CanTool", "Allow Player Tool-Useage", CheckPlayer )


--Add a Non-Admin Restriction for Property things

function PlayerProperty(ply, string, ent)

	if ply:IsAdmin() then
		return true
	else
		PAS.Notify( ply, "You are not an Admin!")
		return false
	end

end

hook.Add( "CanProperty", "Allow Player Property", PlayerProperty )