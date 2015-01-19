-------------------
--  COUNT PROPS  --
-------------------

function pprotect_countProps( ply, dels )

	local result = { global = 0, players = {} }

	table.foreach( ents.GetAll(), function( key, ent )

		if !ent:IsValid() or ent.World or ent:GetClass() != "prop_physics" or ent.pprotect_owner == nil or !ent.pprotect_owner:IsValid() then return end

		-- check deleted Entities
		if istable( dels ) and table.HasValue( dels, ent:EntIndex() ) then return end
		
		-- Global-Count
		result.global = result.global + 1

		-- Player-Count
		local owner = ent.pprotect_owner

		if !result.players[ owner ] then result.players[ owner ] = 0 end
		result.players[ owner ] = result.players[ owner ] + 1

	end )

	-- check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !ply:IsAdmin() and !ply:IsSuperAdmin() then return
	elseif !sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !ply:IsSuperAdmin() then return end

	net.Start( "pprotect_new_counts" )
		net.WriteTable( result )
	net.Send( ply )

end
concommand.Add( "pprotect_request_new_counts", pprotect_countProps )



---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
net.Receive( "pprotect_cleanup_map", function( len, pl )

	-- Check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] then
		if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	else
		if !pl:IsSuperAdmin() then return end
	end

	-- Cleanup Map
	game.CleanUpMap()

	-- Define World-Props again!
	sv_PProtect.setWorldProps()

	-- recount Ents
	pprotect_countProps( pl )

	sv_PProtect.Notify( pl, "Cleaned Map!", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props!" )

end )



-- CLEANUP PLAYERS PROPS
net.Receive( "pprotect_cleanup_player", function( len, pl )

	-- check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !pl:IsAdmin() and !pl:IsSuperAdmin() then return
	elseif !sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !pl:IsSuperAdmin() then return end

	-- find all props from a special player
	local owner = net.ReadTable()
	local del_ents = {}
	table.foreach( ents.GetAll(), function( key, ent )

		if ent.pprotect_owner == owner[1] then
			ent:Remove()
			table.insert( del_ents, ent:EntIndex() )
		end

	end )

	-- recount Ents
	pprotect_countProps( pl, del_ents )

	sv_PProtect.Notify( pl, "Cleaned " .. owner[1]:Nick() .. "'s props! (" .. owner[2] .. ")", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed " .. owner[2] .. " props from " .. owner[1]:Nick() .. "!" )

end )



----------------------------------------
--  CLEAR DISCONNECTED PLAYERS PROPS  --
----------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )
	
	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "propdelete" ] then return end
	if sv_PProtect.Settings.Propprotection[ "adminprops" ] then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end
	
	local cleanupname = ply:Nick()
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " left the server. Props will be deleted in " .. tostring( sv_PProtect.Settings.Propprotection[ "delay" ] ) .. " seconds." )

	table.foreach( ents.GetAll(), function( k, v )
		
		if v.pprotect_owner_id == ply:SteamID() then
			v.pprotect_cleanup = ply:Nick()
		end

	end )
	
	--Create Timer
	timer.Create( "CleanupPropsOf" .. ply:Nick(), sv_PProtect.Settings.Propprotection[ "delay" ], 1, function()

		table.foreach( ents.GetAll(), function( k, v )

			if v.pprotect_cleanup == cleanupname then
				v:Remove()
			end

		end )

		print( "[PatchProtect - Cleanup] Removed " .. cleanupname .. "s Props! ( Reason: Left the Server )" )

	end )

end
hook.Add( "PlayerDisconnected", "pprotect_playerdisconnected", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )
	
	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "propdelete" ] then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		print( "[PatchProtect - Cleanup] Aborded Cleanup! " .. ply:Nick() .. " came back!" )
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	table.foreach( ents.GetAll(), function( k, v )

		if v.pprotect_owner_id == ply:SteamID() then
			v.pprotect_cleanup = nil
			v:CPPISetOwner( ply )
		end

	end )

end
hook.Add( "PlayerSpawn", "pprotect_abortcleanup", sv_PProtect.checkComeback )

-- CLEAN ALL DISCONNECTED PLAYERS PROPS (BUTTON)
net.Receive( "pprotect_cleanup_disconnected_player", function( len, pl )

	-- check Permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !pl:IsAdmin() and !pl:IsSuperAdmin() then return
	elseif !sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !pl:IsSuperAdmin() then return end

	-- Remove all props from disconnected players
	table.foreach( ents.GetAll(), function( k, v )

		if v.pprotect_cleanup != nil and v.pprotect_cleanup != "" then
			v:Remove()
		end

	end )

	sv_PProtect.Notify( pl, "Removed all props from disconnected players!", "info" )
	print( "[PatchProtect - Cleanup] " .. pl:Nick() .. " removed all props from disconnected players!" )

end )
