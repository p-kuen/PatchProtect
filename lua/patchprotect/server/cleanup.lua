-----------------------------------------
--  CLIENT DISCONNECTED PLAYERS PROPS  --
-----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )
	
	if tonumber( sv_PProtect.Settings.PropProtection["use"] ) == 0 then return end
	if tonumber( sv_PProtect.Settings.PropProtection["propdelete"] ) == 0 then return end
	if tonumber( sv_PProtect.Settings.PropProtection["keepadminsprops"] ) == 1 then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end
	
	table.foreach( ents.GetAll(), function( k, v )
		
		if v.PatchPPOwnerID == ply:SteamID() then
			v.PatchPPCleanup = ply:Nick()
		end

	end )
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. ply:Nick(), tonumber( sv_PProtect.Settings.PropProtection["propdelete_delay"] ), 1, function()

		table.foreach( ents.GetAll(), function( k, v )

			if v.PatchPPCleanup == ply:Nick() then
				v:Remove()
			end

		end )
		print( "[PatchProtect - Cleanup] Removed " .. ply:Nick() .. "'s Props!" )

	end )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )
	
	if tonumber( sv_PProtect.Settings.PropProtection["propdelete"] ) == 0 or tonumber( sv_PProtect.Settings.PropProtection["use"] ) == 0 then return end

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
	local count = 0
	
	table.foreach( ents.GetAll(), function( k, v )

		if !v:IsValid() or v:IsPlayer() then return end
		local Owner = v:CPPIGetOwner()
		
		if Owner != nil and Owner:GetName() == tostring( args[1] ) then
			v:Remove()
			count = count + 1
		end

	end )

	sv_PProtect.InfoNotify( ply, "Cleaned " .. tostring( args[1] ) .. "'s Props! (" .. count .. ")" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed " .. count .. " Props from " .. tostring(args[1]) .. "!" )

end
concommand.Add( "btn_cleanup_player", sv_PProtect.CleanupPlayersProps )



-------------------
--  COUNT PROPS  --
-------------------

--Get request for counting props from a specific player
net.Receive( "getCount", function( len, pl )
	
	local player = net.ReadEntity()
	local count = 0

	table.foreach( ents.GetAll(), function( k, v )

		local Owner = v:CPPIGetOwner()
		if Owner != nil and Owner == player then
			count = count + 1
		end

	end )
	
	--Send the result back to the player
	net.Start( "sendCount" )
		net.WriteString( tostring( count ) )
	net.Send( pl )

end )
