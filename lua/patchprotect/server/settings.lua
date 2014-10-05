-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSQLSettings( sqltable, name )

	if !sql.Query( "SELECT setting FROM " .. sqltable ) then sql.Query( "DROP TABLE " .. sqltable ) end
	sql.Query( "CREATE TABLE IF NOT EXISTS " .. sqltable .. " ( setting TEXT, value TEXT )" )
	local SQLSettings = {}

	-- Save/Load SQLSettings
	table.foreach( sv_PProtect.Config[ name ], function( setting, value )

		if !sql.Query( "SELECT value FROM " .. sqltable .. " WHERE setting = '" .. setting .. "'" ) then
			sql.Query( "INSERT INTO " .. sqltable .. " ( setting, value ) VALUES ( '" .. setting .. "', '" .. value .. "' )" )
		end

		SQLSettings[ setting ] = sql.QueryValue( "SELECT value FROM " .. sqltable .. " WHERE setting = '" .. setting .. "'" )

	end )

	-- Convert String-Numbers to Numbers
	table.foreach( SQLSettings, function( setting, value )

		if tonumber( value ) != nil then SQLSettings[ setting ] = tonumber( value ) end

	end )

	return SQLSettings

end

-- ANTISPAMMED TOOLS
function sv_PProtect.setAntispamedTools()

	if !sql.TableExists( "pprotect_antispamtools" ) or !sql.Query( "SELECT tool FROM pprotect_antispamtools" ) then return {} end

	local sql_tools = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_antispamtools" ), function( ind, tool )

		sql_tools[ tool.tool ] = tobool( tool.antispam )

	end )

	return sql_tools

end

-- BLOCKED PROPS
function sv_PProtect.setBlockedProps()

	if !sql.TableExists( "pprotect_blockedprops" ) or !sql.Query( "SELECT id FROM pprotect_blockedprops" ) then return {} end

	local sql_props = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_blockedprops" ), function( ind, prop )

		sql_props[ tonumber( prop.id ) ] = prop.model

	end )

	return sql_props

end

-- BLOCKED TOOLS
function sv_PProtect.setBlockedTools()

	if !sql.TableExists( "pprotect_blockedtools" ) or !sql.Query( "SELECT tool FROM pprotect_blockedtools" ) then return {} end

	local sql_tools = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_blockedtools" ), function( ind, tool )

		sql_tools[ tool.tool ] = tobool( tool.blocked )

	end )

	return sql_tools

end

-- LOAD SETTINGS
sv_PProtect.Settings.Antispam = sv_PProtect.loadSQLSettings( "pprotect_antispam", "Antispam" )
sv_PProtect.Settings.Propprotection = sv_PProtect.loadSQLSettings( "pprotect_propprotection", "Propprotection" )
sv_PProtect.Settings.Antispamtools = sv_PProtect.setAntispamedTools()
sv_PProtect.Settings.Blockedprops = sv_PProtect.setBlockedProps()
sv_PProtect.Settings.Blockedtools = sv_PProtect.setBlockedTools()

MsgC( Color( 255, 255, 0 ), "\n[PatchProtect]", Color( 255, 255, 255 ), " Successfully loaded!\n\n" )



---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
net.Receive( "pprotect_save_antispam", function( len, pl )

	sv_PProtect.Settings.Antispam = net.ReadTable()
	sv_PProtect.Settings.Antispam[ "cooldown" ] = math.Round( sv_PProtect.Settings.Antispam[ "cooldown" ], 1 )
	sv_PProtect.broadcastSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Antispam, function( setting, value )

		if isstring( value ) then value = "'" .. value .. "'" end
		sql.Query( "UPDATE pprotect_antispam SET value = " .. tostring( value ) .. " WHERE setting = '" .. setting .. "'" )

	end )

	sv_PProtect.Notify( pl, "Saved new AntiSpam-Settings", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved new AntiSpam-Settings!" )

end )

-- PROP PROTECTION
net.Receive( "pprotect_save_propprotection", function( len, pl )

	sv_PProtect.Settings.Propprotection = net.ReadTable()
	sv_PProtect.broadcastSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Propprotection, function( setting, value )
		
		sql.Query( "UPDATE pprotect_propprotection SET value = " .. tostring( value ) .. " WHERE setting = '" .. setting .. "'" )

	end )

	sv_PProtect.Notify( pl, "Saved new PropProtection-Settings", "info" )
	print( "[PatchProtect - PropProtection] " .. pl:Nick() .. " saved new PropProtection-Settings!" )

end )

-- ANTISPAMED TOOLS
function sv_PProtect.saveAntiSpamTools( data )

	sql.Query( "DROP TABLE pprotect_antispamtools" )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_antispamtools ( tool TEXT, antispam TEXT )" )

	table.foreach( data, function( tool, antispam )

		sql.Query( "INSERT INTO pprotect_antispamtools ( tool, antispam ) VALUES ( '" .. tool .. "', '" .. tostring( antispam ) .. "' )" )

	end )
	
end

-- BLOCKED PROPS
function sv_PProtect.saveBlockedProps( data )

	sql.Query( "DROP TABLE pprotect_blockedprops" )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_blockedprops ( id INTEGER, model TEXT )" )

	if !data or table.Count( data ) == 0 then return end

	table.foreach( data, function( id, model )

		sql.Query( "INSERT INTO pprotect_blockedprops ( id, model ) VALUES ( " .. id .. ", '" .. model .. "' )" )

	end )
	
end

-- BLOCKED TOOLS
function sv_PProtect.saveBlockedTools( data )

	sql.Query( "DROP TABLE pprotect_blockedtools" )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_blockedtools ( tool TEXT, blocked TEXT )" )

	table.foreach( data, function( tool, blocked )

		sql.Query( "INSERT INTO pprotect_blockedtools ( tool, blocked ) VALUES ( '" .. tool .. "', '" .. tostring( blocked ) .. "' )" )

	end )
	
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
hook.Add( "PlayerInitialSpawn", "pprotect_playersettings", sendPlayerSettings )
concommand.Add( "pprotect_request_newest_settings", sendPlayerSettings )

-- TO EVERY PLAYER
function sv_PProtect.broadcastSettings()

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.Antispam
	new_settings.PropProtection = sv_PProtect.Settings.Propprotection

	net.Start( "pprotect_new_settings" )
		net.WriteTable( new_settings )
	net.Broadcast()

end



---------------------
--  NOTIFICATIONS  --
---------------------

function sv_PProtect.Notify( ply, text, typ )

	if pprotect_cppi_call then return end
	
	net.Start( "pprotect_notify" )
		net.WriteTable( { text, typ } )
	if ply then net.Send( ply ) else net.Broadcast() end

end
