-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSQLSettings( sqlselect, sqltable, localtable, name )

	if !sql.Query( "SELECT * FROM " .. sqltable ) or !sql.Query( "SELECT " .. sqlselect .. " FROM " .. sqltable ) then
		sql.Query( "DROP TABLE " .. sqltable )
		MsgC(
			Color(255, 0, 0),
			"[PatchProtect] Removed old " .. name .. "-Table to get the new version of it!\n"
		)
	end

	if !sql.TableExists( sqltable ) then
		
		local settings = {}
		local values = {}
		local values2 = {}

		table.foreach( localtable, function( k, v )

			local Type = type( v )
			if Type == "number" then
				if v > math.floor( v ) then Type = string.gsub( Type, "number", "DOUBLE" ) else Type = string.gsub( Type, "number", "INTEGER" ) end
			end
			Type = string.gsub( Type, "string", "VARCHAR(255)" )

			table.insert( values2, tostring( k ) .. " " .. Type )
			table.insert( settings, k )
			if type( v ) == "string" then v = "'" .. v .. "'" end
			table.insert( values, v )
				
		end )
		
		sql.Query( "CREATE TABLE IF NOT EXISTS " .. sqltable .. "(" .. table.concat( values2, ", " ) .. ");" )
		sql.Query( "INSERT INTO " .. sqltable .. "(" .. table.concat( settings, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")" )
		
		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new " .. name .. "-Table\n"
		)

	end

	local SQLSettingsTable = sql.QueryRow( "SELECT * FROM " .. sqltable .. " LIMIT 1" )
	table.foreach( SQLSettingsTable, function( setting, value )

		if tonumber( value ) != nil then SQLSettingsTable[ setting ] = tonumber( value ) end

	end )

	return SQLSettingsTable
	
end

-- ANTISPAMMED TOOLS
function sv_PProtect.setAntiSpamTools()

	if sql.TableExists( "pprotect_antispam_tools" ) then

		local antispam_tools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
		
		table.foreach( antispam_tools, function( key, value )

			if value == "true" then
				antispam_tools[ key ] = true
			else
				antispam_tools[ key ] = false
			end

		end )

		return antispam_tools or {}

	else

		return {}

	end

end

-- BLOCKED PROPS
function sv_PProtect.setBlockedProps()

	if sql.TableExists( "pprotect_blockedprops" ) then

		local sql_blocked_props = sql.QueryRow( "SELECT * FROM pprotect_blockedprops LIMIT 1" ) or {}
		local blocked_props = {}

		table.foreach( sql_blocked_props, function( id, prop )
			table.insert( blocked_props, prop )
		end )

		return blocked_props or {}

	else
		
		return {}

	end

end

-- BLOCKED TOOLS
function sv_PProtect.setBlockedTools()

	if sql.TableExists( "pprotect_blockedtools" ) then

		local blocked_tools = sql.QueryRow( "SELECT * FROM pprotect_blockedtools LIMIT 1" ) or {}
		
		table.foreach( blocked_tools, function( key, value )

			if value == "true" then
				blocked_tools[ key ] = true
			else
				blocked_tools[ key ] = false
			end

		end )

		return blocked_tools or {}

	else

		return {}

	end

end

-- LOAD SETTINGS
sv_PProtect.Settings.Antispam = sv_PProtect.loadSQLSettings( "enabled", "pprotect_antispam", sv_PProtect.Config.AntiSpam, "AntiSpam" )
sv_PProtect.Settings.Antispamtools = sv_PProtect.setAntiSpamTools()
sv_PProtect.Settings.Propprotection = sv_PProtect.loadSQLSettings( "proppickup", "pprotect_propprotection", sv_PProtect.Config.PropProtection, "PropProtection" )
sv_PProtect.Settings.Blockedprops = sv_PProtect.setBlockedProps()
sv_PProtect.Settings.Blockedtools = sv_PProtect.setBlockedTools()

MsgC(
	Color(0, 255, 0),
	"\n[PatchProtect] Successfully loaded!\n\n"
)



---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
net.Receive( "pprotect_save_antispam", function( len, pl )

	sv_PProtect.Settings.Antispam = net.ReadTable()
	sv_PProtect.Settings.Antispam[ "cooldown" ] = math.Round( sv_PProtect.Settings.Antispam[ "cooldown" ], 1 )
	sv_PProtect.broadcastSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Antispam, function( key, value )
		if type( sv_PProtect.Settings.Antispam[ key ] ) == "number" then
			sql.Query( "UPDATE pprotect_antispam SET " .. key .. " = " .. value )
		else
			sql.Query( "UPDATE pprotect_antispam SET " .. key .. " = '" .. value .. "'" )
		end
	end )

	sv_PProtect.InfoNotify( pl, "Saved new AntiSpam-Settings" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved new AntiSpam-Settings!" )

end )

-- PROP PROTECTION
net.Receive( "pprotect_save_propprotection", function( len, pl )

	sv_PProtect.Settings.Propprotection = net.ReadTable()
	sv_PProtect.broadcastSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Propprotection, function( key, value )
		if type( sv_PProtect.Settings.Propprotection[ key ] ) == "number" then
			sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = " .. value )
		else
			sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = '" .. value .. "'" )
		end
	end )

	sv_PProtect.InfoNotify( pl, "Saved new PropProtection-Settings" )
	print( "[PatchProtect - PropProtection] " .. pl:Nick() .. " saved new PropProtection-Settings!" )

end )

-- ANTISPAMED TOOLS
function sv_PProtect.saveAntiSpamTools( datatable )

	local keys1 = {}
	local keys2 = {}
	local values = {}

	if sql.TableExists( "pprotect_antispam_tools" ) then
		sql.Query( "DROP TABLE pprotect_antispam_tools" )
	end

	if not sql.TableExists( "pprotect_antispam_tools" ) then

		table.foreach( datatable, function( k, v )
			
			table.insert( keys1, k .. " VARCHAR(255)" )
			table.insert( keys2, "'" .. k .. "'" )
			table.insert( values, "'" .. tostring( v ) .. "'" )

		end )

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_antispam_tools( " .. table.concat( keys1, ", " ) .. " );" )
		sql.Query( "INSERT INTO pprotect_antispam_tools( " .. table.concat( keys2, ", " ) .. " ) VALUES( " .. table.concat( values, ", " ) .. " )" )

	end
	
end

-- BLOCKED DATA
function sv_PProtect.saveBlockedData( datatable, datatype )

	local keys1 = {}
	local keys2 = {}
	local values = {}

	if sql.TableExists( "pprotect_blocked" .. datatype ) then
		sql.Query( "DROP TABLE pprotect_blocked" .. datatype )
	end

	if not sql.TableExists( "pprotect_blocked" .. datatype ) then

		table.foreach( datatable, function( k, v )
			if datatype == "props" then
				table.insert( keys1, "prop_" .. k .. " VARCHAR(255)" )
				table.insert( keys2, "'prop_" .. k .. "'" )
				table.insert( values, "'" .. v .. "'" )
			elseif datatype == "tools" then
				table.insert( keys1, k .. " VARCHAR(255)" )
				table.insert( keys2, "'" .. k .. "'" )
				table.insert( values, "'" .. tostring( v ) .. "'" )
			end
		end )

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_blocked" .. datatype .. "( " .. table.concat( keys1, ", " ) .. " );" )
		sql.Query( "INSERT INTO pprotect_blocked" .. datatype .. "( " .. table.concat( keys2, ", " ) .. " ) VALUES( " .. table.concat( values, ", " ) .. " )" )

	end
	
end



---------------------------
--  SEND SETTING-TABLES  --
---------------------------

-- TO A SPECIFIC PLAYER
local function sendPlayerSettings( ply, cmd, args )

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.Antispam
	new_settings.PropProtection = sv_PProtect.Settings.Propprotection

	net.Start( "pprotect_new_settings" )
		net.WriteTable( new_settings )
		if args != nil and args[1] != nil then net.WriteString( args[1] ) end
	net.Send( ply )

end
hook.Add( "PlayerInitialSpawn", "sendPlayerSettings", sendPlayerSettings )
concommand.Add( "pprotect_request_newest_settings", sendPlayerSettings )

-- TO EVERY PLAYER
function sv_PProtect.broadcastSettings()

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.Antispam
	new_settings.PropProtection = sv_PProtect.Settings.Propprotection

	net.Start( "pprotect_new_settings" )
		net.WriteTable( new_settings )
		net.WriteString( "broadcast" )
	net.Broadcast()

end



---------------------
--  NOTIFICATIONS  --
---------------------

function sv_PProtect.Notify( ply, text )

	net.Start( "pprotect_notify_normal" )
		net.WriteString( text )
	net.Send( ply )

end

function sv_PProtect.InfoNotify( ply, text )

	net.Start( "pprotect_notify_info" )
		net.WriteString( text )
	net.Send( ply )

end

function sv_PProtect.AdminNotify( text )

	net.Start( "pprotect_notify_admin" )
		net.WriteString( text )
	net.Broadcast()

end
