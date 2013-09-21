--Set PropProtection for Props

function CheckPlayer(ply, ent)

	--print(tobool(GetConVarNumber("_PatchProtect_PropProtection_UsePP")))
	if ent.name == ply:GetName() and ent.name != nil then
			
 			return true

 	elseif ent.name != ply:GetName() and ent.name != nil then

 		PAS.Notify( ply, "You are not allowed to do this!" )
 		return false

 	elseif ent.name == nil then

 		ent.name = ply:GetName()
 		return true

 	end
	
end

hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )


--Set PropProtection for Tools

function CanTool(ply, trace, tool)

	if IsValid( trace.Entity ) then
		
		ent = trace.Entity

		if ent.name == ply:GetName() and ent.name != nil then

 			return true

 		elseif ent.name != ply:GetName() and ent.name != nil then

 			PAS.Notify( ply, "You are not allowed to do this!" )
 			return false

 		elseif ent.name == nil then

 			ent.name = ply:GetName()
 			return true

 		end

 	end
 	
end

hook.Add( "CanTool", "Allow Player Tool-Useage", CanTool )


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