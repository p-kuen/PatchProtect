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

	if tobool( sv_PProtect.Settings.AntiSpam[ "enabled" ] ) == false or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and tobool( sv_PProtect.Settings.AntiSpam[ "admins" ] ) == true then return true end
	return false

end



-------------------
--  SPAM ACTION  --
-------------------

-- SET SPAM ACTION
function sv_PProtect.spamaction( ply )

	local action = tonumber( sv_PProtect.Settings.AntiSpam["spamaction"] )

	--Cleanup
	if action == 2 then

		cleanup.CC_Cleanup( ply, "", {} )
		sv_PProtect.InfoNotify( ply, "Cleaned all your Props! (Reason: Spam)" )
		sv_PProtect.AdminNotify( "Cleaned " .. ply:Nick() .. "s props! (Reason: Spam)" )
		print( "[PatchProtect - AS] Cleaned " .. ply:Nick() .. "s props! (Reason: Spam)" )

	--Kick
	elseif action == 3 then

		ply:Kick( "Kicked by PProtect: Spammer" )
		sv_PProtect.AdminNotify( ply:Nick() .. " was kicked from the server! (Reason: Spam)" )
		print( "[PatchProtect - AS] " .. ply:Nick() .. " was kicked from the server!" )

	--Ban
	elseif action == 4 then

		local banminutes = tonumber( sv_PProtect.Settings.AntiSpam["bantime"] )
		ply:Ban(banminutes, "Banned by PProtect: Spammer")
		sv_PProtect.AdminNotify(ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes! (Reason: Spam)")
		print("[PatchProtect - AS] " .. ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring( sv_PProtect.Settings.AntiSpam["concommand"] )
		concommand = string.Replace( concommand, "<player>", ply:Nick() )
		local commands = string.Explode( " ", concommand )
		RunConsoleCommand( commands[1], unpack( commands, 2 ) )
		print( "[PatchProtect - AS] Ran console command " .. tostring( sv_PProtect.Settings.AntiSpam["concommand"] ) .. " on " .. ply:Nick() )

	end

end



----------------
--  ANTISPAM  --
----------------

function sv_PProtect.CanSpawn( ply, mdl )

	if sv_PProtect.CheckASAdmin( ply ) == true then return true end
	if ply.duplicate == true then return true end
	
	--Prop block
	if tobool( sv_PProtect.Settings.AntiSpam["propblock"] ) and isstring( mdl ) and table.HasValue( sv_PProtect.BlockedProps, string.lower( mdl ) ) or string.find( mdl, "/../" ) then
		sv_PProtect.Notify( ply, "This Prop is in the Blacklist!" )
		return false
	end
	
	--Check Cooldown
	if CurTime() < ply.propcooldown then
		
		--Add one Prop to the Warning-List
		ply.props = ply.props + 1

		--Notify Admin about the Spam
		if ply.props >= tonumber( sv_PProtect.Settings.AntiSpam["spam"] ) then
					
			sv_PProtect.AdminNotify( ply:Nick() .. " is spamming!" )
			print( "[PatchProtect - AS] " .. ply:Nick() .. " is spamming!" )
			ply.props = 0
			sv_PProtect.spamaction( ply )

		end

		--Block Prop-Spawning
		sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.propcooldown - CurTime(), 1 ) .. " seconds" )
		return false

	end

	--Set new Cooldown
	ply.props = 0
	ply.propcooldown = CurTime() + tonumber( sv_PProtect.Settings.AntiSpam["cooldown"] )

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

	if tool == "duplicator" or tool == "adv_duplicator" or tool == "adv_duplicator2" then
		ply.duplicate = true
	else
		ply.duplicate = false
	end

end

-- TOOL-ANTISPAM
function sv_PProtect.CanTool( ply, trace, tool )
	
	if sv_PProtect.CheckASAdmin( ply ) == true then return true end
	
	local isBlocked = false
	local isAntiSpam = false

	--Tool-Block
	if tobool( sv_PProtect.Settings.AntiSpam[ "toolblock" ] ) == true then
		isBlocked = sv_PProtect.Settings.BlockedTools[ tool ]
	end
	if isBlocked == true then return false end

	--Tool-Antispam
	if tobool( sv_PProtect.Settings.AntiSpam[ "toolprotection" ] ) == true then
		isAntiSpam = sv_PProtect.Settings.AntiSpamTools[ tool ]
	end

	if isAntiSpam then
		
		--Check Cooldown
		if CurTime() < ply.toolcooldown then

			--Add one Tool-Action to the Warning-List
			ply.tools = ply.tools + 1

			--Notify Admin about Tool-Spam
			if ply.tools >= tonumber( sv_PProtect.Settings.AntiSpam[ "spam" ] ) then

				sv_PProtect.AdminNotify( "PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!" )
				ply.tools = 0
				spamaction( ply )

			end

			--Block Toolgun-Firing
			sv_PProtect.Notify( ply, "Please wait " .. math.Round( ply.toolcooldown - CurTime(), 1) .. " seconds" )
			return false

		else

			--Set new Cooldown
			ply.tools = 0
			ply.toolcooldown = CurTime() + tonumber( sv_PProtect.Settings.AntiSpam[ "cooldown" ] )

		end
		
	end
	
 	sv_PProtect.CheckDupe( ply, tool )
	if sv_PProtect.CanToolProtection( ply, trace, tool ) == false then return false end

end
hook.Add( "CanTool", "FiringToolgun", sv_PProtect.CanTool )



---------------------
--  BLOCKED PROPS  --
---------------------

-- SEND BLOCKEDPROPS-TABLE TO CLIENT
net.Receive( "open_blocked_prop", function( len, pl )

	if sv_PProtect.CheckASAdmin( pl ) == false then return end
	net.Start( "get_blocked_prop" )
		net.WriteTable( sv_PProtect.Settings.BlockedProps )
	net.Send( pl )

end )

-- GET NEW BLOCKED PROP
net.Receive( "send_blocked_prop_cpanel", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then
		sv_PProtect.Notify( pl, "You are not an Admin!" )
		return
	end

	local Prop = net.ReadString()

	if !table.HasValue( sv_PProtect.Settings.BlockedProps, string.lower( Prop ) ) then

		table.insert( sv_PProtect.Settings.BlockedProps, string.lower( Prop ) )

		--Save into SQL-Table
		sv_PProtect.saveBlockedData( sv_PProtect.Settings.BlockedProps, "props" )
		
		sv_PProtect.InfoNotify( pl, "Saved " .. Prop .. " to blocked Props!" )
		print( "[PatchProtect - AS] " .. pl:Nick() .. " added " .. Prop .. " to the blocked Props!" )

	else

		sv_PProtect.InfoNotify( pl, "This Prop is already in the List!" )

	end
	
end )

-- GET NEW BLOCKEDPROPS-TABLE FROM CLIENT
net.Receive( "send_blocked_prop", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.BlockedProps = net.ReadTable()
	sv_PProtect.saveBlockedData( sv_PProtect.Settings.BlockedProps, "props" )

	sv_PProtect.InfoNotify( pl, "Saved all blocked props!" )
	print( "[PatchProtect - AS] " .. pl:Nick() .. " saved the blocked-prop list!" )
	
end )



---------------------
--  BLOCKED TOOLS  --
---------------------

-- SEND BLOCKEDTOOLS-TABLE TO CLIENT
net.Receive( "open_blocked_tool", function( len, pl )

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

	table.foreach( sv_PProtect.Settings.BlockedTools, function( key, value )

		if value == true then
			sendingTable[ key ] = true
		end
		
	end )
	
	net.Start( "get_blocked_tool" )
		net.WriteTable( sendingTable )
	net.Send( pl )

end )

-- GET NEW BLOCKEDTOOLS-TABLE FROM CLIENT
net.Receive( "send_blocked_tool", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.BlockedTools = net.ReadTable()
	sv_PProtect.saveBlockedData( sv_PProtect.Settings.BlockedTools, "tools" )

	sv_PProtect.InfoNotify( pl, "Saved all blocked Tools!" )
	print( "[PatchProtect - AS] " .. pl:Nick() .. " saved the blocked-tools list!" )
	
end )



------------------------
--  ANTISPAMED TOOLS  --
------------------------

net.Receive( "open_antispam_tool", function( len, pl )

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

	table.foreach( sv_PProtect.Settings.AntiSpamTools, function( key, value )

		if value == true then
			sendingTable[ key ] = true
		end
		
	end )

	net.Start( "get_antispam_tool" )
		net.WriteTable( sendingTable )
	net.Send( pl )

end )

net.Receive( "send_antispam_tool", function( len, pl )

	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.Settings.AntiSpamTools = net.ReadTable()
	sv_PProtect.saveAntiSpamTools( sv_PProtect.Settings.AntiSpamTools )

	sv_PProtect.InfoNotify( pl, "Saved all antispamed tools!" )
	print( "[PatchProtect - AS] " .. pl:Nick() .. " saved the antispamed-tools list!" )

end )
