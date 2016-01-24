-------------------
--  COUNT PROPS  --
-------------------

local function countProps( ply, dels )

	local result = { global = 0, players = {} }

	table.foreach( ents.GetAll(), function( key, ent )

		if !ent or !ent:IsValid() then return end
		local o = ent:CPPIGetOwner()
		if ent:GetNWBool( "pprotect_world" ) or !o or isnumber(o) or !o:IsValid() then return end

		-- check deleted entities (which shouldn't be counted, because they shouldn't exist anymore)
		if istable( dels ) and table.HasValue( dels, ent:EntIndex() ) then return end
		
		-- Global-Count
		result.global = result.global + 1

		-- Player-Count
		if !result.players[ o ] then result.players[ o ] = 0 end
		result.players[ o ] = result.players[ o ] + 1

	end )

	net.Start( "pprotect_new_counts" )
		net.WriteTable( result )
	net.Send( ply )

end
concommand.Add( "pprotect_request_new_counts", countProps )



---------------------
--  CLEANUP PROPS  --
---------------------

-- Cleanup Map
local function cleanupMap( typ, ply )

	-- cleanup map
	game.CleanUpMap()

	-- set world props
	sv_PProtect.setWorldProps()

	-- count props
	if typ then countProps( ply ) end

	-- console exception
	if !ply:IsValid() then
		print( "[PatchProtect - Cleanup] Removed all props!" )
		return
	end

	sv_PProtect.Notify( ply, "Cleaned Map!", "info" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all props!" )

end

-- Cleanup Disconnected Players Props
local function cleanupDisc( ply )

	local del_ents = {}
	table.foreach( ents.GetAll(), function( key, ent )

		if ent.pprotect_cleanup != nil then
			ent:Remove()
			table.insert( del_ents, ent:EntIndex() )
		end

	end )

	sv_PProtect.Notify( ply, "Removed all props from disconnected players!", "info" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all props from disconnected players!" )

end

-- Cleanup Players Props
local function cleanupPly( pl, c, ply )

	local del_ents = {}
	table.foreach( ents.GetAll(), function( key, ent )

		if ent:GetNWEntity( "pprotect_owner" ) == pl then
			ent:Remove()
			table.insert( del_ents, ent:EntIndex() )
		end

	end )

	sv_PProtect.Notify( ply, "Cleaned " .. pl:Nick() .. "'s props! (" .. tostring( c ) .. ")", "info" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed " .. tostring( c ) .. " props from " .. pl:Nick() .. "!" )
	countProps( pl, del_ents )

end

-- Cleanup Unowned Props
local function cleanupUnowned( ply )

	table.foreach( ents.GetAll(), function( key, ent )

		if ent:IsValid() and !ent:CPPIGetOwner() and !ent:GetNWBool( "pprotect_world" ) and string.find( ent:GetClass(), "prop_" ) then
			ent:Remove()
		end

	end )

	sv_PProtect.Notify( ply, "Removed all unowned props!", "info" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all unowned props!" )

end

-- General Cleanup-Function
function sv_PProtect.Cleanup( typ, ply )

	-- check permissions
	if ply:IsValid() and ( !sv_PProtect.Settings.Propprotection[ "adminscleanup" ] or !ply:IsAdmin() ) and !ply:IsSuperAdmin() then
		sv_PProtect.Notify( ply, "You are not allowed to clean the map!" ) return
	end

	-- get cleanup-type
	local d = {}
	if !isstring( typ ) then
		d = net.ReadTable()
		typ = d[1]
	end

	if typ == "all" then
		cleanupMap( d[1], ply )
		return
	end

	if typ == "disc" then
		cleanupDisc( ply )
		return
	end

	if typ == "ply" then
		cleanupPly( d[2], d[3], ply )
		return
	end

	if typ == "unowned" then
		cleanupUnowned( ply )
	end

end
net.Receive( "pprotect_cleanup", sv_PProtect.Cleanup )
concommand.Add( "gmod_admin_cleanup", function( ply, cmd, args ) sv_PProtect.Cleanup( "all", ply ) end )



----------------------------------------
--  CLEAR DISCONNECTED PLAYERS PROPS  --
----------------------------------------

-- PLAYER LEFT SERVER
local function setCleanup( ply )

	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "propdelete" ] then return end
	if sv_PProtect.Settings.Propprotection[ "adminprops" ] and ( ply:IsSuperAdmin() or ply:IsAdmin() ) then return end

	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " left the server. Props will be deleted in " .. tostring( sv_PProtect.Settings.Propprotection[ "delay" ] ) .. " seconds." )

	table.foreach( ents.GetAll(), function( k, v )
		
		if v:CPPIGetOwner() and v:CPPIGetOwner():UniqueID() == ply:UniqueID() then
			v.pprotect_cleanup = ply:Nick()
		end

	end )

	local nick = ply:Nick()
	timer.Create( "pprotect_cleanup_" .. nick, sv_PProtect.Settings.Propprotection[ "delay" ], 1, function()

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

	if !timer.Exists( "pprotect_cleanup_" .. ply:Nick() ) then return end

	print( "[PatchProtect - Cleanup] Aborded Cleanup! " .. ply:Nick() .. " came back!" )
	timer.Destroy( "pprotect_cleanup_" .. ply:Nick() )

	table.foreach( ents.GetAll(), function( k, v )

		if v:CPPIGetOwner() and v:CPPIGetOwner():UniqueID() == ply:UniqueID() then
			v.pprotect_cleanup = nil
			v:CPPISetOwner( ply )
		end

	end )

end
hook.Add( "PlayerSpawn", "pprotect_abortcleanup", abortCleanup )
