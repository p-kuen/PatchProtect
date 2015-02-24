-------------------
--  COUNT PROPS  --
-------------------

local function countProps( ply, dels )

	local result = { global = 0, players = {} }

	table.foreach( ents.GetAll(), function( key, ent )

		if !ent:IsValid() or ent.World or ent.pprotect_owner == nil or !ent.pprotect_owner:IsValid() then return end

		-- check deleted entities
		if istable( dels ) and table.HasValue( dels, ent:EntIndex() ) then return end
		
		-- Global-Count
		result.global = result.global + 1

		-- Player-Count
		local owner = ent.pprotect_owner

		if !result.players[ owner ] then result.players[ owner ] = 0 end
		result.players[ owner ] = result.players[ owner ] + 1

	end )

	-- check permissions
	if sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !ply:IsAdmin() and !ply:IsSuperAdmin() then return
	elseif !sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and !ply:IsSuperAdmin() then return end

	net.Start( "pprotect_new_counts" )
		net.WriteTable( result )
	net.Send( ply )

end
concommand.Add( "pprotect_request_new_counts", countProps )



function sv_PProtect.Cleanup( typ, ply )

	-- check permissions
	if ( sv_PProtect.Settings.Propprotection[ "adminscleanup" ] and ply:IsAdmin() ) or ply:IsSuperAdmin() then else
		sv_PProtect.Notify( ply, "You are not allowed to clean the map!" ) return
	end

	-- get cleanup-type
	if !isstring( typ ) then
		local d = net.ReadTable()
		typ = d[1]
	end

	-- cleanup whole map
	if typ == "all" then

		-- cleanup map
		game.CleanUpMap()

		-- set world props
		sv_PProtect.setWorldProps()

		-- count props
		if d then countProps( ply ) end

		sv_PProtect.Notify( ply, "Cleaned Map!", "info" )
		print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all props!" )
		return

	end

	-- cleanup props from a special player
	if IsEntity( typ ) then

		local del_ents = {}
		table.foreach( ents.GetAll(), function( key, ent )

			if ent.pprotect_owner == typ then

				-- delete entity
				ent:Remove()

				-- add it to deleted entities
				table.insert( del_ents, ent:EntIndex() )

			end

		end )

		countProps( typ, del_ents )

		sv_PProtect.Notify( ply, "Cleaned " .. typ:Nick() .. "'s props! (" .. tostring( d[2] ) .. ")", "info" )
		print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed " .. tostring( d[2] ) .. " props from " .. typ:Nick() .. "!" )
		return

	end

	-- cleanup props from disconnected players
	table.foreach( ents.GetAll(), function( key, ent )

		if IsEntity( typ ) and ent.pprotect_owner == typ then

			if ent.pprotect_cleanup != nil then ent:Remove() end

		end

	end )

	sv_PProtect.Notify( ply, "Removed all props from disconnected players!", "info" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all props from disconnected players!" )

end
net.Receive( "pprotect_cleanup", sv_PProtect.Cleanup )
concommand.Add( "gmod_admin_cleanup", function( ply, cmd, args ) sv_PProtect.Cleanup( "all" ) end )



----------------------------------------
--  CLEAR DISCONNECTED PLAYERS PROPS  --
----------------------------------------

-- PLAYER LEFT SERVER
local function setCleanup( ply )

	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "propdelete" ] then return end
	if sv_PProtect.Settings.Propprotection[ "adminprops" ] then
		if ply:IsAdmin() or ply:IsSuperAdmin() then return end
	end

	local nick = ply:Nick()
	print( "[PatchProtect - Cleanup] " .. nick .. " left the server. Props will be deleted in " .. tostring( sv_PProtect.Settings.Propprotection[ "delay" ] ) .. " seconds." )

	table.foreach( ents.GetAll(), function( k, v )
		
		if v.pprotect_owner_id == ply:UniqueID() then
			v.pprotect_cleanup = nick
		end

	end )

	-- create timer
	timer.Create( "CleanupPropsOf" .. nick, sv_PProtect.Settings.Propprotection[ "delay" ], 1, function()

		table.foreach( ents.GetAll(), function( k, v )

			if v.pprotect_cleanup == nick then
				v:Remove()
			end

		end )

		print( "[PatchProtect - Cleanup] Removed " .. nick .. "s Props! ( Reason: Left the Server )" )

	end )

end
hook.Add( "PlayerDisconnected", "pprotect_playerdisconnected", setCleanup )

-- PLAYER CAME BACK
local function abortCleanup( ply )
	
	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "propdelete" ] then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		print( "[PatchProtect - Cleanup] Aborded Cleanup! " .. ply:Nick() .. " came back!" )
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	table.foreach( ents.GetAll(), function( k, v )

		if v.pprotect_owner_id == ply:UniqueID() then
			v.pprotect_cleanup = nil
			v:CPPISetOwner( ply )
		end

	end )

end
hook.Add( "PlayerSpawn", "pprotect_abortcleanup", abortCleanup )
