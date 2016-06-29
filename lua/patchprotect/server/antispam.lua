----------------------
--  ANTISPAM SETUP  --
----------------------

-- SET PLAYER VARS
function sv_PProtect.Setup( ply )

	-- Props
	ply.propcooldown = 0
	ply.props = 0

	-- Tools
	ply.toolcooldown = 0
	ply.tools = 0

	-- Duplicate
	ply.duplicate = false

end
hook.Add( "PlayerInitialSpawn", "pprotect_initialspawn", sv_PProtect.Setup )

-- CHECK ANTISPAM ADMIN
function sv_PProtect.CheckASAdmin( ply )

	if not IsValid(ply) then return false end
	if !sv_PProtect.Settings.Antispam[ "enabled" ] or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.Antispam[ "admins" ] then return true end
	return false

end



-------------------
--  SPAM ACTION  --
-------------------

function sv_PProtect.spamaction( ply )

	local action = sv_PProtect.Settings.Antispam[ "spamaction" ]
	local name = ply:Nick()

	-- Cleanup
	if action == "Cleanup" then

		cleanup.CC_Cleanup( ply, "", {} )
		sv_PProtect.Notify( ply, "Cleaned all your props! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Cleaned " .. name .. "s props! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Cleaned " .. name .. "s props! ( Reason: spamming )" )

	-- Kick
	elseif action == "Kick" then

		ply:Kick( "Kicked by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Kicked " .. name .. "! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Kicked " .. name .. "! ( Reason: spamming )" )

	-- Ban
	elseif action == "Ban" then

		local mins = sv_PProtect.Settings.Antispam[ "bantime" ]
		ply:Ban( mins, "Banned by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Banned " .. name .. " for " .. mins .. " minutes! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Banned " .. name .. " for " .. mins .. " minutes! ( Reason: spamming )" )

	-- ConCommand
	elseif action == "Command" then

		if sv_PProtect.Settings.Antispam[ "concommand" ] == sv_PProtect.Config.Antispam[ "concommand" ] then return end
		local rep = string.Replace( sv_PProtect.Settings.Antispam[ "concommand" ], "<player>", ply:SteamID() )
		local cmd = string.Explode( " ", rep )
		RunConsoleCommand( cmd[1], unpack( cmd, 2 ) )
		print( "[PatchProtect - AntiSpam] Ran console command '" .. rep .. "'! ( Reason: reached spam limit )" )

	end

end



-----------------------
--  SPAWN ANTI SPAM  --
-----------------------

function sv_PProtect.CanSpawn( ply, mdl )

	if sv_PProtect.CheckASAdmin( ply ) then return end
	if ply.duplicate then return end

	-- Prop/Entity-Block
	if sv_PProtect.Settings.Antispam[ "propblock" ] and sv_PProtect.Blocked.props[ string.lower( mdl ) ] or string.find( string.lower( mdl ), "/../" ) or sv_PProtect.Settings.Antispam[ "entblock" ] and sv_PProtect.Blocked.ents[ string.lower( mdl ) ] then
		sv_PProtect.Notify( ply, "This object is in the blacklist!" )
		return false
	end

	-- Cooldown
	if CurTime() > ply.propcooldown then
		ply.props = 0
		ply.propcooldown = CurTime() + sv_PProtect.Settings.Antispam[ "cooldown" ]
		return
	end

	ply.props = ply.props + 1
	sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.propcooldown - CurTime(), 1 ) .. " seconds", "normal" )

	-- Spamaction
	if ply.props >= sv_PProtect.Settings.Antispam[ "spam" ] then
		ply.props = 0
		sv_PProtect.spamaction( ply )
		sv_PProtect.Notify( nil, ply:Nick() .. " is spamming!", "admin" )
		print( "[PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming!" )
	end

	return false

end
hook.Add( "PlayerSpawnProp", "pprotect_spawnprop", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnEffect", "pprotect_spawneffect", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnSENT", "pprotect_spawnSENT", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnRagdoll", "pprotect_spawnragdoll", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnVehicle", "pprotect_spawnvehicle", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnNPC", "pprotect_spawnNPC", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnSWEP", "pprotect_spawnSWEP", sv_PProtect.CanSpawn )



----------------------
--  TOOL ANTI SPAM  --
----------------------

-- TOOL-ANTISPAM
function sv_PProtect.CanTool( ply, trace, tool )

	if sv_PProtect.CheckASAdmin( ply ) then return sv_PProtect.CanToolProtection( ply, trace, tool ) end

	-- Blocked Tool
	if sv_PProtect.Settings.Antispam[ "toolblock" ] and sv_PProtect.Blocked.btools[ tool ] then
		sv_PProtect.Notify( ply, "This tool is in the blacklist!", "normal" )
		return false
	end

	-- Check Dupe
	if tool == "duplicator" or tool == "adv_duplicator" or tool == "advdupe2" or tool == "wire_adv" then ply.duplicate = true else ply.duplicate = false end

	-- Antispamed Tool
	if !sv_PProtect.Blocked.atools[ tool ] then return sv_PProtect.CanToolProtection( ply, trace, tool ) end

	-- Cooldown
	if CurTime() > ply.toolcooldown then
		ply.tools = 0
		ply.toolcooldown = CurTime() + sv_PProtect.Settings.Antispam[ "cooldown" ]
		return sv_PProtect.CanToolProtection( ply, trace, tool )
	end

	ply.tools = ply.tools + 1
	sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.toolcooldown - CurTime(), 1 ) .. " seconds", "normal" )

	-- Spamaction
	if ply.tools >= sv_PProtect.Settings.Antispam[ "spam" ] then
		ply.tools = 0
		sv_PProtect.spamaction( ply )
		sv_PProtect.Notify( nil, ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!", "admin" )
		print( "PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!" )
	end

	return false

end
hook.Add( "CanTool", "pprotect_toolgun", sv_PProtect.CanTool )



--------------------------
--  BLOCKED PROPS/ENTS  --
--------------------------

-- SEND BLOCKED PROPS/ENTS TABLE
net.Receive( "pprotect_request_ents", function( len, pl )

	local typ = net.ReadTable()[1]

	net.Start( "pprotect_send_ents" )
		net.WriteString( typ )
		net.WriteTable( sv_PProtect.Blocked[ typ ] )
	net.Send( pl )

end )

-- SAVE BLOCKED PROPS/ENTS TABLE
net.Receive( "pprotect_save_ents", function( len, pl )

	local d = net.ReadTable()
	local typ, key = d[1], d[2]

	sv_PProtect.Blocked[ typ ][ key ] = nil
	sv_PProtect.saveBlockedEnts( typ, sv_PProtect.Blocked[ typ ] )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " removed " .. key .. " from the blocked-" .. typ .. "-list!" )

end )

-- SAVE BLOCKED PROP/ENT FROM CPANEL
net.Receive( "pprotect_save_cent", function( len, pl )

	local ent = net.ReadTable()

	if sv_PProtect.Blocked[ ent.typ ][ ent.name ] then
		sv_PProtect.Notify( pl, "This object is already in the " .. ent.typ .. "-list!", "info" )
		return
	end

	sv_PProtect.Blocked[ ent.typ ][ string.lower( ent.name ) ] = string.lower( ent.model )
	sv_PProtect.saveBlockedEnts( ent.typ, sv_PProtect.Blocked[ ent.typ ] )

	sv_PProtect.Notify( pl, "Saved " .. ent.name .. " to blocked-" .. ent.typ .. "-list!", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " added " .. ent.name .. " to the blocked-" .. ent.typ .. "-list!" )

end )

-- IMPORT BLOCKED PROPS LIST
concommand.Add( "pprotect_import_blocked_props", function( ply, cmd, args )

	if !file.Read( "pprotect_import_blocked_props.txt", "DATA" ) then print( "Cannot find 'pprotect_import_blocked_props.txt' to import props. Please read the description of patchprotect!" ) return end
	local imp = string.Explode( ";", file.Read( "pprotect_import_blocked_props.txt", "DATA" ) )
	table.foreach( imp, function( key, model )
		if model == "" then return end
		model = string.lower( string.sub( model, string.find( model, "models/" ), string.find( model, ";" ) ) )
		if util.IsValidModel( model ) and !sv_PProtect.Blocked.props[ model ] then sv_PProtect.Blocked.props[ model ] = model end
	end )
	sv_PProtect.saveBlockedEnts( "props", sv_PProtect.Blocked.props )
	print( "\n[PatchProtect] Imported all blocked props. If you experience any errors,\nthen use the command to reset the whole blocked-props-list:\n'pprotect_reset blocked_props'\n" )

end )



--------------------------------
--  ANTISPAMED/BLOCKED TOOLS  --
--------------------------------

-- SEND ANTISPAMED/BLOCKED TOOLS TABLE
net.Receive( "pprotect_request_tools", function( len, pl )

	local t = string.sub( net.ReadTable()[1], 1, 1 ) .. "tools"
	local tools = {}

	table.foreach( weapons.GetList(), function( _, wep )
		if wep.ClassName != "gmod_tool" then return end
		table.foreach( wep.Tool, function( name, tool ) tools[ name ] = false end )
	end )

	table.foreach( sv_PProtect.Blocked[ t ], function( name, value )
		if value == true then tools[ name ] = true end
	end )

	net.Start( "pprotect_send_tools" )
		net.WriteString( t )
		net.WriteTable( tools )
	net.Send( pl )

end )

-- SAVE BLOCKED/ANTISPAMED TOOLS
net.Receive( "pprotect_save_tools", function( len, pl )

	local d = net.ReadTable()
	local t1, t2, k, c = d[1], d[2], d[3], d[4]

	sv_PProtect.Blocked[ t1 ][ k ] = c
	sv_PProtect.saveBlockedTools( t2, sv_PProtect.Blocked[ t1 ] )

	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " set \"" .. k .. "\" from " .. t2 .. "-tools-list to \"" .. tostring( c ) .. "\"!" )

end )
