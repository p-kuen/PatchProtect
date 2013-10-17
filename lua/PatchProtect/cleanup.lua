-----------------------------------------
--  CLIENT DISCONNECTED PLAYERS PROPS  --
-----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )

	local plyname = ply:Nick()
	
	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v

		local Owner = ent:CPPIGetOwner()
		if Owner == ply then
			ent.PatchPPCleanup = ply:Nick()
		end

	end
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. plyname , tonumber(sv_PProtect.Settings.PropProtection["propdelete_delay"]), 1, function()

		for k, v in pairs( ents.GetAll() ) do

			ent = v
			if ent.PatchPPCleanup == plyname then
				ent:Remove()
			end

		end
		print( "[PatchProtect - Cleanup] Removed " .. plyname .. "'s Props!" )

	end )

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPCleanup == ply then
			ent.PatchPPCleanup = ""
		end

	end

end
hook.Add( "PlayerSpawn", "CheckAbortCleanup", sv_PProtect.checkComeback )

-- CLEAN ALL DISCONNECTED PLAYERS PROPS (BUTTON)
function sv_PProtect.CleanAllDisconnectedPlayersProps( ply )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPCleanup != nil and ent.PatchPPCleanup != "" then
			ent:Remove()
		end

	end
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
	sv_PProtect.InfoNotify(ply, "Cleaned Map!")
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all Props!" )

end
concommand.Add( "btn_cleanup", sv_PProtect.CleanupEverything )

-- CLEANUP PLAYERS PROPS
function sv_PProtect.CleanupPlayersProps( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
	local count = 0
	
	for k, v in pairs( ents.GetAll() ) do

		if v:IsValid() and !v:IsPlayer() then ent = v end
		local Owner = ent:CPPIGetOwner()
		
		if Owner != nil and Owner:GetName() == tostring( args[1] ) then
			ent:Remove()
			count = count + 1
		end

	end

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

	for k, v in pairs( ents.GetAll() ) do

		local Owner = v:CPPIGetOwner()
		if Owner != nil and Owner == player then
			count = count + 1
		end

	end
	
	--Send the result back to the player
	net.Start( "sendCount" )
		net.WriteString( tostring( count ) )
	net.Send( pl )

end )
