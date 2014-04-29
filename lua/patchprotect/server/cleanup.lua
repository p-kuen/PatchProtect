-------------------
--  COUNT PROPS  --
-------------------

function pprotect_count_props( ply )

	local count = 0

	table.foreach( ents.GetAll(), function( key, value )
		
		if value:IsValid() and ply == value:CPPIGetOwner() then
			count = count + 1
		end
		
	end )

	return count

end

function pprotect_new_counts( ply, cmd, args )

	local counts = {}

	-- GLOBAL COUNT
	local global_count = 0
	table.foreach( ents.GetAll(), function( key, value )
		if value:IsValid() and value:GetClass() == "prop_physics" and value.WorldOwned != true then
			global_count = global_count + 1
		end
	end )
	counts[ "global" ] = global_count

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

	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end

	game.CleanUpMap()

	--Define World-Props again!
	sv_PProtect.SetWorldProps()

	sv_PProtect.InfoNotify( pl, "Cleaned Map!" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props!" )

end )



-----------------------------------------
--  CLIENT DISCONNECTED PLAYERS PROPS  --
-----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.SetCleanupProps( ply )
	
	if sv_PProtect.Settings.PropProtection[ "enabled" ] == 0 or sv_PProtect.Settings.PropProtection[ "use_propdelete" ] == 0 then return end
	if sv_PProtect.Settings.PropProtection[ "adminprops" ] == 1 then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end
	
	local cleanupname = ply:Nick()

	table.foreach( ents.GetAll(), function( k, v )
		
		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = ply:Nick()
		end

	end )
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. ply:Nick(), sv_PProtect.Settings.PropProtection[ "delay" ], 1, function()

		table.foreach( ents.GetAll(), function( k, v )

			if v.PatchPPCleanup == cleanupname then
				v:Remove()
			end

		end )
		print( "[PatchProtect - Cleanup] Removed " .. cleanupname .. "'s Props! (Reason: Left the Server)" )

	end )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.SetCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )
	
	if sv_PProtect.Settings.PropProtection[ "enabled" ] == 0 or sv_PProtect.Settings.PropProtection[ "propdelete" ] == 0 then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		print( "[PatchProtect - Cleanup] Aborded Cleanup! " .. ply:Nick() .. " came back!" )
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	table.foreach( ents.GetAll(), function( k, v )

		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = ""
			v:CPPISetOwner( ply )
		end

	end )

end
hook.Add( "PlayerSpawn", "CheckAbortCleanup", sv_PProtect.checkComeback )

-- CLEAN ALL DISCONNECTED PLAYERS PROPS (BUTTON)
net.Receive( "pprotect_cleanup_disconnected_player", function( len, pl )

	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end

	table.foreach( ents.GetAll(), function( k, v )

		if v.PatchPPCleanup != nil and v.PatchPPCleanup != "" then
			v:Remove()
		end

	end )
	sv_PProtect.InfoNotify( pl, "Removed all props from disconnected players!" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props from disconnected players!" )

end )

-- CLEANUP PLAYERS PROPS
net.Receive( "pprotect_cleanup_player", function( len, pl )

	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end

	local cleanupdata = net.ReadTable()
	table.foreach( player.GetAll(), function( key, value )
		if value:Nick() == cleanupdata[1] then
			cleanupdata[1] = value
		end
	end )

	cleanup.CC_Cleanup( cleanupdata[1], "", {} )

	sv_PProtect.InfoNotify( pl, "Cleaned " .. cleanupdata[1]:GetName() .. "'s props! (" .. cleanupdata[2] .. ")" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed " .. cleanupdata[2] .. " props from " .. cleanupdata[1]:GetName() .. "!" )

end )
