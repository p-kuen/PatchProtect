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
hook.Add( "PlayerInitialSpawn", "Setup_AntiSpamVariables", sv_PProtect.Setup )

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

	--Cleanup
	if action == 2 then

		cleanup.CC_Cleanup( ply, "", {} )
		sv_PProtect.InfoNotify( ply, "Cleaned all your props! ( Reason: spamming )" )
		sv_PProtect.AdminNotify( "Cleaned " .. ply:Nick() .. "s props! ( Reason: spamming )" )
		print( "[PatchProtect - AntiSpam] Cleaned " .. ply:Nick() .. "s props! ( Reason: spamming )" )

	--Kick
	elseif action == 3 then

		ply:Kick( "Kicked by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.AdminNotify( "Kicked " .. ply:Nick() .. "! ( Reason: spamming )" )
		print( "[PatchProtect - AntiSpam] Kicked " .. ply:Nick() .. "! ( Reason: spamming )" )

	--Ban
	elseif action == 4 then

		local mins = sv_PProtect.Settings.Antispam[ "bantime" ]
		ply:Ban( mins, "Banned by PatchProtect! ( Reason: spamming )" )
		sv_PProtect.AdminNotify( "Banned " .. ply:Nick() .. " for " .. mins .. " minutes! ( Reason: spamming )" )
		print( "[PatchProtect - AntiSpam] Banned " .. ply:Nick() .. " for " .. mins .. " minutes! ( Reason: spamming )" )

	--ConCommand
	elseif action == 5 then

		--[[
		local concommand = tostring( sv_PProtect.Settings.Antispam["concommand"] )
		concommand = string.Replace( concommand, "<player>", ply:Nick() )
		local commands = string.Explode( " ", concommand )
		RunConsoleCommand( commands[1], unpack( commands, 2 ) )
		print( "[PatchProtect - AntiSpam] Ran console command " .. tostring( sv_PProtect.Settings.Antispam["concommand"] ) .. " on " .. ply:Nick() )
		]]

	end

end



----------------
--  ANTISPAM  --
----------------

function sv_PProtect.CanSpawn( ply, mdl )

	if sv_PProtect.CheckASAdmin( ply ) then return true end
	if ply.duplicate then return true end
	
	-- Cooldown
	if CurTime() < ply.propcooldown then
		
		ply.props = ply.props + 1

		-- Notify admin
		if ply.props >= sv_PProtect.Settings.Antispam[ "spam" ] then
					
			sv_PProtect.AdminNotify( ply:Nick() .. " is spamming!" )
			print( "[PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming!" )
			ply.props = 0
			sv_PProtect.spamaction( ply )

		end

		sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.propcooldown - CurTime(), 1 ) .. " seconds" )
		return false

	end

	-- Reset cooldown
	ply.props = 0
	ply.propcooldown = CurTime() + sv_PProtect.Settings.Antispam[ "cooldown" ]

end
hook.Add( "PlayerSpawnProp", "SpawningProp", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnEffect", "SpawningEffect", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnSENT", "SpawningSENT", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnRagdoll", "SpawningRagdoll", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnVehicle", "SpawningVehicle", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnNPC", "SpawningNPC", sv_PProtect.CanSpawn )
hook.Add( "PlayerSpawnSWEP", "SpawningSWEP", sv_PProtect.CanSpawn )



----------------------
--  TOOL ANTI SPAM  --
----------------------

-- CHECK IF THE PLAYER FIRED WITH THE DUPLICATOR OR WITH A SIMILAR TOOL
function sv_PProtect.CheckDupe( ply, tool )

	if tool == "duplicator" or tool == "adv_duplicator" or tool == "advdupe2" or tool == "wire_adv" then
		ply.duplicate = true
	else
		ply.duplicate = false
	end

end

-- TOOL-ANTISPAM
function sv_PProtect.CanTool( ply, trace, tool )
	
	if sv_PProtect.CheckASAdmin( ply ) then return true end

	-- Block
	if sv_PProtect.Settings.Antispam[ "toolblock" ] == 1 and sv_PProtect.Settings.Blockedtools[ tool ] then
		sv_PProtect.Notify( ply, "This tool is in the blacklist!" )
		return false
	end

	-- Antispam
	if sv_PProtect.Settings.Antispam[ "toolprotection" ] == 1 and sv_PProtect.Settings.Antispamtools[ tool ] then
		
		-- Cooldown
		if CurTime() < ply.toolcooldown then

			ply.tools = ply.tools + 1

			-- Notify admin
			if ply.tools >= sv_PProtect.Settings.Antispam[ "spam" ] then

				sv_PProtect.AdminNotify( ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!" )
				print( "PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!" )
				ply.tools = 0
				sv_PProtect.spamaction( ply )

			end

			sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.toolcooldown - CurTime(), 1 ) .. " seconds" )
			return false

		else

			-- Reset cooldown
			ply.tools = 0
			ply.toolcooldown = CurTime() + sv_PProtect.Settings.Antispam[ "cooldown" ]

		end
		
	end
	
 	sv_PProtect.CheckDupe( ply, tool )
	if !sv_PProtect.CanToolProtection( ply, trace, tool ) then return false end

end
hook.Add( "CanTool", "FiringToolgun", sv_PProtect.CanTool )



---------------------
--  BLOCKED PROPS  --
---------------------

-- SEND BLOCKEDPROPS-TABLE TO CLIENT
net.Receive( "pprotect_blockedprops", function( len, pl )

	if sv_PProtect.CheckASAdmin( pl ) == false then return end
	net.Start( "get_blocked_prop" )
		net.WriteTable( sv_PProtect.Settings.Blockedprops )
	net.Send( pl )

end )

-- GET NEW BLOCKED PROP
net.Receive( "pprotect_send_blocked_props_cpanel", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then
		sv_PProtect.Notify( pl, "You are not an Admin!" )
		return
	end

	local Prop = net.ReadString()

	if !table.HasValue( sv_PProtect.Settings.Blockedprops, string.lower( Prop ) ) then
		print("vorher")
		PrintTable( sv_PProtect.Settings.Blockedprops )
		table.insert( sv_PProtect.Settings.Blockedprops, string.lower( Prop ) )
		print("nachher")
PrintTable( sv_PProtect.Settings.Blockedprops )
		--Save into SQL-Table
		sv_PProtect.saveBlockedProps( sv_PProtect.Settings.Blockedprops )
		
		sv_PProtect.InfoNotify( pl, "Saved " .. Prop .. " to blocked props!" )
		print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " added " .. Prop .. " to the blocked props!" )

	else

		sv_PProtect.InfoNotify( pl, "This prop is already in the list!" )

	end
	
end )

-- GET NEW BLOCKEDPROPS-TABLE FROM CLIENT
net.Receive( "pprotect_send_blocked_props", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.Blockedprops = net.ReadTable()
	sv_PProtect.saveBlockedProps( sv_PProtect.Settings.Blockedprops )

	sv_PProtect.InfoNotify( pl, "Saved all blocked props!" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the blocked-prop list!" )
	
end )



---------------------
--  BLOCKED TOOLS  --
---------------------

-- SEND BLOCKEDTOOLS-TABLE TO CLIENT
net.Receive( "pprotect_blockedtools", function( len, pl )

	if sv_PProtect.CheckASAdmin( pl ) == false then return end
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

-- GET NEW BLOCKEDTOOLS-TABLE FROM CLIENT
net.Receive( "pprotect_send_blocked_tools", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.Blockedtools = net.ReadTable()
	sv_PProtect.saveBlockedTools( sv_PProtect.Settings.Blockedtools )

	sv_PProtect.InfoNotify( pl, "Saved all blocked Tools!" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the blocked-tools list!" )
	
end )



------------------------
--  ANTISPAMED TOOLS  --
------------------------

net.Receive( "pprotect_antispamtools", function( len, pl )

	if sv_PProtect.CheckASAdmin( pl ) == false then return end
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

net.Receive( "pprotect_send_antispamed_tools", function( len, pl )

	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.Antispamtools = net.ReadTable()
	sv_PProtect.saveAntiSpamTools( sv_PProtect.Settings.Antispamtools )

	sv_PProtect.InfoNotify( pl, "Saved all antispamed tools!" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved the antispamed-tools list!" )

end )
