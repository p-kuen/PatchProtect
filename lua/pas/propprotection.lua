--Set PropProtection for Props

function CheckPlayer(ply, ent)

	if !Entity:IsWorld or ply:IsAdmin() then

		if ent.name == ply:Nick() and ent.name != nil then
			
 			return true

 		elseif ent.name != ply:Nick() and ent.name != nil then

 			PAS.Notify( ply, "You are not allowed to do this!" )
 			return false

 		end

 	else

 		return false

 	end
	
end
hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )


--Set PropProtection for Tools

function CanTool(ply, trace, tool)

	if trace.HitNonWorld or ply:IsAdmin() then

		if IsValid( trace.Entity ) then
		
			ent = trace.Entity

			if ent.name == ply:Nick() and ent.name != nil then

 				return true

 			elseif ent.name != ply:Nick() and ent.name != nil then

 				PAS.Notify( ply, "You are not allowed to do this!" )
 				return false

 			elseif ent.name == nil then

 				ent.name = ply:Nick()
 				return true

 			end

 		end

 	else

 		PAS.Notify( ply, "You are not allowed to do somethign with world props!" )
 		return false

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
