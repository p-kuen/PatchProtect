--Set PropProtection for Props

function CheckPlayer(ply, ent)

	if !ply:IsAdmin() then

		if ent.name == ply:Nick() and !ent:IsWorld() then

			return true

		else

			PAS.Notify( ply, "You are not allowed to do this!" )
			return false

		end

	else
		return true
	end
	
end
hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )
hook.Add( "CanDrive", "Allow Driving", CheckPlayer )


--Set PropProtection for Tools

function CanTool(ply, trace, tool)

	if !ply:IsAdmin() then

		if IsValid( trace.Entity ) then

			ent = trace.Entity

			if !ent:IsWorld() and ent.name == ply:Nick() then

				return true

			else

				PAS.Notify( ply, "You are not allowed to do this!" )
				return false

			end

		end

	else
		return true
	end
 	
end
hook.Add( "CanTool", "Allow Player Tool-Useage", CanTool )


--Add a Non-Admin Restriction for Property things

function PlayerProperty(ply, string, ent)

	if !ply:IsAdmin() then

		if string != "drive" and string != "persist" then

			if ent.name != nil and ent.name == ply:Nick() and !ent.IsWorld() then
			
 				return true

 			else

 				PAS.Notify( ply, "You are not allowed to do this!" )
 				return false

 			end

		else
			return false
		end

	else
		return true
	end

end
hook.Add( "CanProperty", "Allow Player Property", PlayerProperty )


--DISCONNECTED PLAYER'S PROP CLEANUP

--Create timer for cleanup, if player goes from server
function CleanupDiscPlayersProps( name )

	timer.Create( "CleanupPropsOf" .. name , 10, 1, function() --ATM at 10. We should add a slider or sth to change this!

		for k, v in pairs( ents.GetAll() ) do

			ent = v

			if ent.cleanuped == name and ent.name == "Disconnected Player" then
			
				ent:Remove()

			end

		end

		print("[PatchProtect - Cleanup] Removed " .. name .. "'s Props!")

	end)
	
end

--If player goes from server
function SetCleanupProps( ply )

	for k, v in pairs( ents.GetAll() ) do

		ent = v

		if ent.name == ply:Nick() then

			ent.name = "Disconnected Player"
			ent.cleanuped = ply:Nick()

		end

	end

	CleanupDiscPlayersProps( ply:Nick() )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", SetCleanupProps )

--If player comes back in time
function CheckComeback( name )

	if timer.Exists( "CleanupPropsOf" .. name ) then

		timer.Destroy( "CleanupPropsOf" .. name )

		for k, v in pairs( ents.GetAll() ) do

			ent = v

			if ent.cleanuped == name and ent.name == "Disconnected Player" then
			
				ent.name = name

			end

		end

	end

end
hook.Add( "PlayerConnect", "CheckAbortCleanup", CheckComeback )