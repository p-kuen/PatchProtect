-------------------
--  COUNT PROPS  --
-------------------

function pprotect_count_props( ply )

	local count = 0

	table.foreach( ents.GetAll(), function( key, value )

		if ply == nil and value:IsValid() and value.World != true and value:GetClass() == "prop_physics" then
			count = count + 1
		end

		if ply != nil and value:IsValid() and ply == value:CPPIGetOwner() and value:GetClass() == "prop_physics" then
			count = count + 1
		end
		
	end )

	return count

end

function pprotect_new_counts( ply, cmd, args )

	local counts = {}

	-- GLOBAL COUNT
	counts[ "global" ] = pprotect_count_props()

	-- PLAYER COUNT
	local player_counts = {}
	table.foreach( player.GetAll(), function( key, player )
		player_counts[ player ] = pprotect_count_props( player )
	end )
	counts[ "players" ] = player_counts

	net.Start( "pprotect_new_counts" )
		net.WriteTable( counts )
	net.Send( ply )

end
concommand.Add( "pprotect_request_newest_counts", pprotect_new_counts )



---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
net.Receive( "pprotect_cleanup_map", function( len, pl )

	-- Check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 then
		if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	else
		if !pl:IsSuperAdmin() then return end
	end

	-- Cleanup Map
	game.CleanUpMap()

	-- Define World-Props again!
	sv_PProtect.setWorldProps()

	sv_PProtect.Notify( pl, "Cleaned Map!", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props!" )

end )



-- CLEANUP PLAYERS PROPS
net.Receive( "pprotect_cleanup_player", function( len, pl )

	-- Check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 then
		if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	elseif sv_PProtect.Settings.Propprotection[ "adminscleanup" ] == 0 then
		if !pl:IsSuperAdmin() then return end
	end

	-- Find all props from a special player
	local cleanupdata = net.ReadTable()
	table.foreach( ents.GetAll(), function( key, value )

		if value:CPPIGetOwner() == cleanupdata[1] then
			value:Remove()
		end
		
	end )

	sv_PProtect.Notify( pl, "Cleaned " .. cleanupdata[1]:Nick() .. "'s props! (" .. cleanupdata[2] .. ")", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed " .. cleanupdata[2] .. " props from " .. cleanupdata[1]:Nick() .. "!" )

end )



----------------------------------------
--  CLEAR DISCONNECTED PLAYERS PROPS  --
----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.SetCleanupProps( ply )
	
	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or sv_PProtect.Settings.Propprotection[ "propdelete" ] == 0 then return end
	if sv_PProtect.Settings.Propprotection[ "adminprops" ] == 1 then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end
	
	local cleanupname = ply:Nick()
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " left the server. Props will be deleted in " .. tostring( sv_PProtect.Settings.Propprotection[ "delay" ] ) .. " seconds." )

	table.foreach( ents.GetAll(), function( k, v )
		
		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = ply:Nick()
		end

	end )
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. ply:Nick(), sv_PProtect.Settings.Propprotection[ "delay" ], 1, function()

		table.foreach( ents.GetAll(), function( k, v )

			if v.PatchPPCleanup == cleanupname then
				v:Remove()
			end

		end )

		print( "[PatchProtect - Cleanup] Removed " .. cleanupname .. "s Props! ( Reason: Left the Server )" )

	end )

end
hook.Add( "PlayerDisconnected", "pprotect_playerdisconnected", sv_PProtect.SetCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )
	
	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or sv_PProtect.Settings.Propprotection[ "propdelete" ] == 0 then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		print( "[PatchProtect - Cleanup] Aborded Cleanup! " .. ply:Nick() .. " came back!" )
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	table.foreach( ents.GetAll(), function( k, v )

		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = nil
			v:CPPISetOwner( ply )
		end

	end )

end
hook.Add( "PlayerSpawn", "pprotect_abortcleanup", sv_PProtect.checkComeback )

-- CLEAN ALL DISCONNECTED PLAYERS PROPS (BUTTON)
net.Receive( "pprotect_cleanup_disconnected_player", function( len, pl )

	-- Check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 then
		if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	elseif sv_PProtect.Settings.Propprotection[ "adminscleanup" ] == 0 then
		if !pl:IsSuperAdmin() then return end
	end

	-- Remove all props from disconnected players
	table.foreach( ents.GetAll(), function( k, v )

		if v.PatchPPCleanup != nil and v.PatchPPCleanup != "" then
			v:Remove()
		end

	end )

	sv_PProtect.Notify( pl, "Removed all props from disconnected players!", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props from disconnected players!" )

end )
