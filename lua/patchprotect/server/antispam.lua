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

	if tobool( sv_PProtect.Settings.AntiSpam_General["use"] ) == false or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and tobool( sv_PProtect.Settings.AntiSpam_General["noantiadmin"] ) then return true end

end



-------------------
--  SPAM ACTION  --
-------------------

-- SET SPAM ACTION
function sv_PProtect.spamaction( ply )

	local action = tonumber( sv_PProtect.Settings.AntiSpam_General["spamaction"] )

	--Cleanup
	if action == 2 then

		cleanup.CC_Cleanup( ply, "", {} )
		ply.cleanedup = true
		sv_PProtect.InfoNotify( ply, "Your props have been cleanuped!" )
		sv_PProtect.AdminNotify( ply:Nick() .. "s props were cleaned up! (Reason: Spam)" )
		print( "[PatchProtect - AS] " .. ply:Nick() .. "s props have been cleaned up!" )

	--Kick
	elseif action == 3 then

		ply:Kick( "Kicked by PProtect: Spammer" )
		sv_PProtect.AdminNotify( ply:Nick() .. " was kicked from the server! (Reason: Spam)" )
		print( "[PatchProtect - AS] " .. ply:Nick() .. " was kicked from the server!" )

	--Ban
	elseif action == 4 then

		local banminutes = tonumber( sv_PProtect.Settings.AntiSpam_General["bantime"] )
		ply:Ban(banminutes, "Banned by PProtect: Spammer")
		sv_PProtect.AdminNotify(ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes! (Reason: Spam)")
		print("[PatchProtect - AS] " .. ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring( sv_PProtect.Settings.AntiSpam_General["concommand"] )
		concommand = string.Replace( concommand, "<player>", ply:Nick() )
		local commands = string.Explode( " ", concommand )
		RunConsoleCommand( commands[1], unpack( commands, 2 ) )
		print( "[PatchProtect - AS] Ran console command " .. tostring( sv_PProtect.Settings.AntiSpam_General["concommand"] ) .. " on " .. ply:Nick() )

	end

end



----------------
--  ANTISPAM  --
----------------

function sv_PProtect.CanSpawn( ply, mdl )

	if sv_PProtect.CheckASAdmin( ply ) == true then return true end
	if ply.duplicate == true then return true end
	
	--Prop block
	if tobool( sv_PProtect.Settings.AntiSpam_General["propblock"] ) and isstring( mdl ) then
		if table.HasValue( sv_PProtect.BlockedProps, string.lower( mdl ) ) then
			sv_PProtect.Notify( ply, "This Prop is in the Blacklist!" )
			return false
		end
	end
	
	--Check Cooldown
	if CurTime() < ply.propcooldown then
		
		--Add one Prop to the Warning-List
		ply.props = ply.props + 1

		--Notify Admin about the Spam
		if ply.props >= tonumber( sv_PProtect.Settings.AntiSpam_General["spamcount"] ) then
					
			sv_PProtect.AdminNotify( ply:Nick() .. " is spamming!" )
			print( "[PatchProtect - AS] " .. ply:Nick() .. " is spamming!" )
			ply.props = 0
			sv_PProtect.spamaction( ply )

		end

		--Block Prop-Spawning
		sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.propcooldown - CurTime(), 1 ) )
		return false

	end

	--Set new Cooldown
	ply.props = 0
	ply.propcooldown = CurTime() + tonumber( sv_PProtect.Settings.AntiSpam_General["cooldown"] )

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

-- THE TOOL-ANTISPAM ITSELF
function sv_PProtect.CanTool( ply, trace, tool )
	
	local IsBlockedTool = false

	if sv_PProtect.CheckASAdmin( ply ) == true then return true end
	
	--Tool block
	if tobool( sv_PProtect.Settings.AntiSpam_General["toolblock"] ) == true then
		table.foreach( sv_PProtect.BlockedTools, function( key, value )
			if tool == key then
				IsBlockedTool = tobool(value)
				if IsBlockedTool == true then sv_PProtect.Notify( ply, "Sry, this Tool is blocked on this server!" ) end
			end
		end )
	end

	if IsBlockedTool == true then return false end
	
	--Check AntiSpam if Tool is in the Block-List
	if table.HasValue( sv_PProtect.AntiSpamTools, tool ) and tobool( sv_PProtect.Settings.AntiSpam_General["toolprotection"] ) == true then
		
		--Check Cooldown
		if CurTime() < ply.toolcooldown then

			--Add one Tool-Action to the Warning-List
			ply.tools = ply.tools + 1

			--Notify Admin about Tool-Spam
			if ply.tools >= tonumber( sv_PProtect.Settings.AntiSpam_General["spamcount"] ) then

				sv_PProtect.AdminNotify( "PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming with " .. tostring( tool ) .. "s!" )
				ply.tools = 0
				spamaction( ply )

			end

			--Block Toolgun-Firing
			sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.toolcooldown - CurTime(), 1) )
			return false

		else

			--Set new Cooldown
			ply.tools = 0
			ply.toolcooldown = CurTime() + tonumber( sv_PProtect.Settings.AntiSpam_General["cooldown"] )

		end
		
	end
	
 	sv_PProtect.CheckDupe( ply, tool )
	if sv_PProtect.CanToolProtection( ply, trace, tool ) == false then return false end

end
hook.Add( "CanTool", "FiringToolgun", sv_PProtect.CanTool )



---------------------
--  BLOCKED PROPS  --
---------------------

-- GET NEW BLOCKED PROP
net.Receive( "sendBlockedProp", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then
		sv_PProtect.Notify( pl, "You are not an Admin!" )
		return
	end

	local Prop = net.ReadString()

	if !table.HasValue( sv_PProtect.BlockedProps, string.lower( Prop ) ) then

		table.insert( sv_PProtect.BlockedProps, string.lower( Prop ) )

		--Save into SQL-Table
		sv_PProtect.saveBlockedData( sv_PProtect.BlockedProps, "props" )
		
		sv_PProtect.InfoNotify( pl, "Saved " .. Prop .. " to blocked Props!" )
		print( "[PatchProtect - AS] " .. pl:Nick() .. " added " .. Prop .. " to the blocked Props!" )

	else

		sv_PProtect.InfoNotify( pl, "This Prop is already in the List!" )

	end
	
end )

-- SEND BLOCKEDPROPS-TABLE TO CLIENT
concommand.Add( "btn_bprops", function( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
	net.Start( "getBlockedPropData" )
		net.WriteTable( sv_PProtect.BlockedProps )
	net.Send( ply )

end )

-- GET NEW BLOCKEDPROPS-TABLE FROM CLIENT
net.Receive( "sendNewBlockedPropTable", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.BlockedProps = net.ReadTable()

	--Save into SQL-Table
	sv_PProtect.saveBlockedData( sv_PProtect.BlockedProps, "props" )
	
	sv_PProtect.InfoNotify( pl, "Saved new blocked Prop Table!" )
	
end )



---------------------
--  BLOCKED TOOLS  --
---------------------

-- SEND BLOCKEDTOOLS-TABLE TO CLIENT
concommand.Add( "btn_btools", function( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	local sendingTable = {}

	--This is here, that we get everytime the new tools from addons
	table.foreach( weapons.GetList(), function( _, wep )

		if wep.ClassName == "gmod_tool" then

			table.foreach( wep.Tool, function( name, tool )
				sendingTable[ name ] = false
			end )

		end

	end )
	
	if table.Count( sendingTable ) != 0 then

		table.foreach( sv_PProtect.BlockedTools, function( key, value )
			
			if value == true then
				sendingTable[ key ] = true
			end

		end )

	end
	
	net.Start( "getBlockedToolData" )
		net.WriteTable( sendingTable )
	net.Send( ply )

end )

-- GET NEW BLOCKEDTOOLS-TABLE FROM CLIENT
net.Receive( "sendNewBlockedToolTable", function( len, pl )
	
	if !pl:IsAdmin() and !pl:IsSuperAdmin() then return end
	sv_PProtect.BlockedTools = net.ReadTable()

	--Save into SQL-Table
	sv_PProtect.saveBlockedData( sv_PProtect.BlockedTools, "tools" )
	
	sv_PProtect.InfoNotify( pl, "Saved new blocked Tool Table!" )
	
end )