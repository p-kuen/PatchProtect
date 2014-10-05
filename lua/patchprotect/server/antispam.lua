----------------
--  SETTINGS  --
----------------

-- SET PLAYER VARS
function sv_PProtect.Setup( ply )

	-- PROPS
	ply.propcooldown = 0
	ply.props = 0

	-- TOOLS
	ply.toolcooldown = 0
	ply.tools = 0
	ply.duplicate = false

end
hook.Add( "PlayerInitialSpawn", "pprotect_initialspawn", sv_PProtect.Setup )

-- CHECK ANTISPAM ADMIN
function sv_PProtect.CheckASAdmin( ply )

	if sv_PProtect.Settings.Antispam[ "enabled" ] == 0 or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.Antispam[ "admins" ] == 1 then return true end
	return false

end



-------------------
--  SPAM ACTION  --
-------------------

-- SET SPAM ACTION
function sv_PProtect.spamaction( ply )

	local action = sv_PProtect.Settings.Antispam[ "spamaction" ]
	local name = ply:Nick()

	--Cleanup
	if action == "Cleanup" then

		cleanup.CC_Cleanup( ply, "", {} )
		sv_PProtect.Notify( ply, "Cleaned all your props! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Cleaned " .. name .. "s props! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Cleaned " .. name .. "s props! ( Reason: spamming )" )

	--Kick
	elseif action == "Kick" then

		ply:Kick( "Kicked by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Kicked " .. name .. "! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Kicked " .. name .. "! ( Reason: spamming )" )

	--Ban
	elseif action == "Ban" then

		local mins = sv_PProtect.Settings.Antispam[ "bantime" ]
		ply:Ban( mins, "Banned by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.Notify( nil, "Banned " .. name .. " for " .. mins .. " minutes! ( Reason: spamming )", "admin" )
		print( "[PatchProtect - AntiSpam] Banned " .. name .. " for " .. mins .. " minutes! ( Reason: spamming )" )

	--ConCommand
	elseif action == "Command" then

		if sv_PProtect.Settings.Antispam[ "concommand" ] == sv_PProtect.Config.Antispam[ "concommand" ] then return end
		local rep = string.Replace( sv_PProtect.Settings.Antispam[ "concommand" ], "<player>", name )
		local cmd = string.Explode( " ", rep )
		RunConsoleCommand( cmd[1], unpack( cmd, 2 ) )
		print( "[PatchProtect - AntiSpam] Ran console command '" .. rep .. "'! ( Reason: reached spam limit )" )

	end

end



----------------
--  ANTISPAM  --
----------------

function sv_PProtect.CanSpawn( ply, mdl )

	if sv_PProtect.CheckASAdmin( ply ) then return true end
	if ply.duplicate then return true end

	-- Cooldown
	if CurTime() > ply.propcooldown then
		ply.props = 0
		ply.propcooldown = CurTime() + sv_PProtect.Settings.Antispam[ "cooldown" ]
		return true
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
	if sv_PProtect.Settings.Antispam[ "toolblock" ] == 1 and sv_PProtect.Settings.Blockedtools[ tool ] then
		sv_PProtect.Notify( ply, "This tool is in the blacklist!", "normal" )
		return false
	end

	-- Check Dupe
	if tool == "duplicator" or tool == "adv_duplicator" or tool == "advdupe2" or tool == "wire_adv" then ply.duplicate = true else ply.duplicate = false end

	-- Antispamed Tool
	if !sv_PProtect.Settings.Antispamtools[ tool ] then return sv_PProtect.CanToolProtection( ply, trace, tool ) end

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



---------------------
--  BLOCKED PROPS  --
---------------------

-- SEND TABLE
net.Receive( "pprotect_blockedprops", function( len, pl )

	net.Start( "get_blocked_prop" )
		net.WriteTable( sv_PProtect.Settings.Blockedprops )
	net.Send( pl )

end )

-- GET NEW PROP
net.Receive( "pprotect_send_blocked_props_cpanel", function( len, pl )

	local Prop = net.ReadString()

	if !table.HasValue( sv_PProtect.Settings.Blockedprops, string.lower( Prop ) ) then

		table.insert( sv_PProtect.Settings.Blockedprops, string.lower( Prop ) )
		sv_PProtect.saveBlockedProps( sv_PProtect.Settings.Blockedprops )
		
		sv_PProtect.Notify( pl, "Saved " .. Prop .. " to blocked props!", "info" )
		print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " added " .. Prop .. " to the blocked props!" )

	else

		sv_PProtect.Notify( pl, "This prop is already in the list!", "info" )

	end

end )

-- GET NEW TABLE
net.Receive( "pprotect_send_blocked_props", function( len, pl )

	sv_PProtect.Settings.Blockedprops = net.ReadTable()
	sv_PProtect.saveBlockedProps( sv_PProtect.Settings.Blockedprops )

	sv_PProtect.Notify( pl, "Saved all blocked props!", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the blocked-prop list!" )

end )



---------------------
--  BLOCKED TOOLS  --
---------------------

-- SEND TABLE
net.Receive( "pprotect_blockedtools", function( len, pl )

	local sendingTable = {}

	--This is here, that we get everytime the new tools from addons
	table.foreach( weapons.GetList(), function( _, wep )

		if wep.ClassName == "gmod_tool" then
			table.foreach( wep.Tool, function( name, tool )
				sendingTable[ name ] = false
			end )
		end

	end )

	table.foreach( sv_PProtect.Settings.Blockedtools, function( key, value )

		if value == true then
			sendingTable[ key ] = true
		end
		
	end )

	net.Start( "get_blocked_tool" )
		net.WriteTable( sendingTable )
	net.Send( pl )

end )

-- GET NEW TABLE
net.Receive( "pprotect_send_blocked_tools", function( len, pl )

	sv_PProtect.Settings.Blockedtools = net.ReadTable()
	sv_PProtect.saveBlockedTools( sv_PProtect.Settings.Blockedtools )

	sv_PProtect.Notify( pl, "Saved all blocked Tools!", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the blocked-tools list!" )

end )



------------------------
--  ANTISPAMED TOOLS  --
------------------------

-- SEND TABLE
net.Receive( "pprotect_antispamtools", function( len, pl )

	local sendingTable = {}

	--This is here, that we get everytime the new tools from addons
	table.foreach( weapons.GetList(), function( _, wep )

		if wep.ClassName == "gmod_tool" then
			table.foreach( wep.Tool, function( name, tool )
				sendingTable[ name ] = false
			end )
		end

	end )

	table.foreach( sv_PProtect.Settings.Antispamtools, function( key, value )

		if value == true then
			sendingTable[ key ] = true
		end
		
	end )

	net.Start( "get_antispam_tool" )
		net.WriteTable( sendingTable )
	net.Send( pl )

end )

-- GET NEW TABLE
net.Receive( "pprotect_send_antispamed_tools", function( len, pl )

	sv_PProtect.Settings.Antispamtools = net.ReadTable()
	sv_PProtect.saveAntiSpamTools( sv_PProtect.Settings.Antispamtools )

	sv_PProtect.Notify( pl, "Saved all antispamed tools!", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the antispamed-tools list!" )

end )
