----------------------------------------
--  PICKUP AND DRIVE PROP PROTECTION  --
----------------------------------------

function sv_PProtect.checkPlayer(ply, ent)

	if ply:IsAdmin() or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end

	if !ent:IsWorld() and ent.name == ply:Nick() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPlayerPickup", sv_PProtect.checkPlayer )
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.checkPlayer )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.canTool(ply, trace, tool)

	if ply:IsAdmin() or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end

	local ent = trace.Entity
	if ent:IsWorld() and tonumber(sv_PProtect.Settings.PropProtection["tool_world"]) == 0 then return false end
	if ent.name == ply:Nick() or ent:IsWorld() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end
 	
end
hook.Add( "CanTool", "AllowToolUsage", sv_PProtect.canTool )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

function sv_PProtect.playerProperty(ply, string, ent)

	if ply:IsAdmin() or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end

	if string == "drive" and tonumber(sv_PProtect.Settings.PropProtection["cdrive"]) == 0 then return false end

	if !ent.IsWorld() and ent.name == ply:Nick() and string != "persist" then
 		return true
 	else
 		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
 		return false
 	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.playerProperty )


------------------------------------------
--  DISCONNECTED PLAYER'S PROP CLEANUP  --
------------------------------------------

-- CREATE TIMER
local function CleanupDiscPlayersProps( name )

	timer.Create( "CleanupPropsOf" .. name , tonumber(sv_PProtect.Settings.PropProtection["propdelete_delay"]), 1, function()

		for k, v in pairs( ents.GetAll() ) do

			ent = v
			if ent.cleanuped == name and ent.name == "Disconnected Player" then
				ent:Remove()
			end

		end
		print("[PatchProtect - Cleanup] Removed " .. name .. "'s Props!")

	end)
	
end


-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.name == ply:Nick() then
			ent.name = "Disconnected Player"
			ent.cleanuped = ply:Nick()
		end

	end
	CleanupDiscPlayersProps( ply:Nick() )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( name )

	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

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
hook.Add( "PlayerConnect", "CheckAbortCleanup", sv_PProtect.checkComeback )

---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
function sv_PProtect.CleanupEverything()

	game.CleanUpMap()
	sv_PProtect.InfoNotify(ply, "Cleaned Map!")

end
concommand.Add("btn_cleanup", sv_PProtect.CleanupEverything)

-- CLEANUP PLAYERS PROPS
function sv_PProtect.CleanupPlayersProps( ply, cmd, args )

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.name == tostring(args[1]) then
			ent:Remove()
		end

	end

	sv_PProtect.InfoNotify(ply, "Cleaned " .. tostring(args[1]) .. "'s Props!")

end
concommand.Add("btn_cleanup_player", sv_PProtect.CleanupPlayersProps)
