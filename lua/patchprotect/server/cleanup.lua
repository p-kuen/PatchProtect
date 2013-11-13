-----------------------------------------
--  CLIENT DISCONNECTED PLAYERS PROPS  --
-----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.SetCleanupProps( ply )
	
	if tobool( sv_PProtect.Settings.PropProtection[ "use" ] ) == false or tobool( sv_PProtect.Settings.PropProtection[ "use_propdelete" ] ) == false then return end
	if tobool( sv_PProtect.Settings.PropProtection[ "keepadminsprops" ] ) then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end
	
	local cleanupname = ply:Nick()

	table.foreach( ents.GetAll(), function( k, v )
		
		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = ply:Nick()
		end

	end )
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. ply:Nick(), tonumber( sv_PProtect.Settings.PropProtection[ "propdelete_delay" ] ), 1, function()

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
	
	if tobool( sv_PProtect.Settings.PropProtection[ "use" ] ) == false or tobool( sv_PProtect.Settings.PropProtection["use_propdelete"] ) == false then return end

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
function sv_PProtect.CleanAllDisconnectedPlayersProps( ply )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	table.foreach( ents.GetAll(), function( k, v )

		if v.PatchPPCleanup != nil and v.PatchPPCleanup != "" then
			v:Remove()
		end

	end )
	sv_PProtect.InfoNotify( ply, "Cleaned all disconnected Players Props!" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all Props from disconnected Players!" )

end
concommand.Add( "btn_cleandiscprops", sv_PProtect.CleanAllDisconnectedPlayersProps )



---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
function sv_PProtect.CleanupEverything( ply )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	game.CleanUpMap()

	--Define World-Props again!
	sv_PProtect.setWorldProps()

	sv_PProtect.InfoNotify(ply, "Cleaned Map!")
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all Props!" )

end
concommand.Add( "btn_cleanup", sv_PProtect.CleanupEverything )

-- CLEANUP PLAYERS PROPS
function sv_PProtect.CleanupPlayersProps( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	local cleanupdata = string.Split( args[1], "´´´" )
	table.foreach( player.GetAll(), function( key, value )
		if value:Nick() == cleanupdata[1] then
			cleanupdata[1] = value
		end
	end )

	cleanup.CC_Cleanup( cleanupdata[1], "", {} )

	sv_PProtect.InfoNotify( ply, "Cleaned " .. cleanupdata[1]:GetName() .. "'s Props! (" .. cleanupdata[2] .. ")" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed " .. cleanupdata[2] .. " Props from " .. cleanupdata[1]:GetName() .. "!" )

end
concommand.Add( "btn_cleanup_player", sv_PProtect.CleanupPlayersProps )



-------------------
--  COUNT PROPS  --
-------------------

--Get request for counting props from a specific player
net.Receive( "getCount", function( len, pl )
	
	local playerents = {}

	table.foreach( player.GetAll(), function( key, value )

		local count = 0

		table.foreach( ents.GetAll(), function( k, v )

			local Owner = v:CPPIGetOwner()
			if Owner == value then
				count = count + 1
			end

		end )

		playerents[value:Nick()] = tostring(count)

	end )
	
	--Send the result back to the player
	net.Start( "sendCount" )
		net.WriteTable( playerents )
	net.Send( pl )

end )
