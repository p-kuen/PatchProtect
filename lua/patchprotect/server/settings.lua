-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSQLSettings( sqltable, name )

	-- Delete old version of settings
	if sql.QueryValue( "SELECT value FROM " .. sqltable .. " WHERE setting = 'enabled'" ) != "true" and sql.QueryValue( "SELECT value FROM " .. sqltable .. " WHERE setting = 'enabled'" ) != "false" then
		print( "PPROTECT: ATTENTION! DELETED " .. sqltable .. " BECAUSE OF A NEW SETTINGS-VERSION! PLEASE SET ALL SETTINGS AS YOU HAD THEM BEFORE!" )
		sql.Query( "DROP TABLE " .. sqltable )
	end
	if !sql.Query( "SELECT setting FROM " .. sqltable ) then sql.Query( "DROP TABLE " .. sqltable ) end
	sql.Query( "CREATE TABLE IF NOT EXISTS " .. sqltable .. " ( setting TEXT, value TEXT )" )
	local sql_settings = {}

	-- Save/Load SQLSettings
	table.foreach( sv_PProtect.Config[ name ], function( setting, value )

		if !sql.Query( "SELECT value FROM " .. sqltable .. " WHERE setting = '" .. setting .. "'" ) then
			sql.Query( "INSERT INTO " .. sqltable .. " ( setting, value ) VALUES ( '" .. setting .. "', '" .. tostring( value ) .. "' )" )
		end

		sql_settings[ setting ] = sql.QueryValue( "SELECT value FROM " .. sqltable .. " WHERE setting = '" .. setting .. "'" )

	end )

	-- Convert strings to numbers and booleans
	table.foreach( sql_settings, function( setting, value )

		if tonumber( value ) != nil then sql_settings[ setting ] = tonumber( value ) end
		if value == "true" or value == "false" then sql_settings[ setting ] = tobool( value ) end

	end )

	return sql_settings

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

-- BLOCKED ENTS
function sv_PProtect.setBlockedEnts()

	if !sql.TableExists( "pprotect_blockedents" ) or !sql.Query( "SELECT name FROM pprotect_blockedents" ) then return {} end

	local sql_ents = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_blockedents" ), function( ind, ent )

		sql_ents[ ent.name ] = ent.model

	end )

	return sql_ents

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
sv_PProtect.Settings.Blockedents = sv_PProtect.setBlockedEnts()
sv_PProtect.Settings.Blockedtools = sv_PProtect.setBlockedTools()

MsgC( Color( 255, 255, 0 ), "\n[PatchProtect]", Color( 255, 255, 255 ), " Successfully loaded!\n\n" )



---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
net.Receive( "pprotect_save_antispam", function( len, pl )

	sv_PProtect.Settings.Antispam = net.ReadTable()
	sv_PProtect.sendSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Antispam, function( setting, value )

		sql.Query( "UPDATE pprotect_antispam SET value = '" .. tostring( value ) .. "' WHERE setting = '" .. setting .. "'" )

	end )

	sv_PProtect.Notify( pl, "Saved new AntiSpam-Settings", "info" )
	print( "[PatchProtect - AntiSpam] " .. pl:Nick() .. " saved new AntiSpam-Settings!" )

end )

-- PROP PROTECTION
net.Receive( "pprotect_save_propprotection", function( len, pl )

	sv_PProtect.Settings.Propprotection = net.ReadTable()
	sv_PProtect.sendSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings.Propprotection, function( setting, value )
		
		sql.Query( "UPDATE pprotect_propprotection SET value = '" .. tostring( value ) .. "' WHERE setting = '" .. setting .. "'" )

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

-- BLOCKED ENTS
function sv_PProtect.saveBlockedEnts( data )

	sql.Query( "DROP TABLE pprotect_blockedents" )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_blockedents ( name TEXT, model TEXT )" )

	if !data or table.Count( data ) == 0 then return end

	table.foreach( data, function( name, model )

		sql.Query( "INSERT INTO pprotect_blockedents ( name, model ) VALUES ( '" .. name .. "', '" .. model .. "' )" )

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



----------------------
--  RESET SETTINGS  --
----------------------

concommand.Add( "pprotect_reset_antispam", function()
	sql.Query( "DROP TABLE pprotect_antispam" )
	print( "[PatchProtect-AntiSpam] Successfully deleted all AntiSpam-Settings!\n[PatchProtect-AntiSpam] PLEASE RESTART THE SERVER WHEN YOU ARE FINISHED WITH ALL RESETS!" )
end )

concommand.Add( "pprotect_reset_propprotection", function()
	sql.Query( "DROP TABLE pprotect_propprotection" )
	print( "[PatchProtect-PropProtection] Successfully deleted all PropProtection-Settings!\n[PatchProtect-PropProtection] PLEASE RESTART THE SERVER WHEN YOU ARE FINISHED WITH ALL RESETS!" )
end )



---------------
--  NETWORK  --
---------------

-- SEND SETTINGS
function sv_PProtect.sendSettings( ply, cmd, args )

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.Antispam
	new_settings.PropProtection = sv_PProtect.Settings.Propprotection

	net.Start( "pprotect_new_settings" )
		net.WriteTable( new_settings )
		if args != nil and args[1] != nil then net.WriteString( args[1] ) end
	if ply then net.Send( ply ) else net.Broadcast() end

end
hook.Add( "PlayerInitialSpawn", "pprotect_playersettings", sv_PProtect.sendSettings )
concommand.Add( "pprotect_request_newest_settings", sv_PProtect.sendSettings )

-- SEND NOTIFICATION
function sv_PProtect.Notify( ply, text, typ )

	if pprotect_cppi_call then return end
	
	net.Start( "pprotect_notify" )
		net.WriteTable( { text, typ } )
	if ply then net.Send( ply ) else net.Broadcast() end

end
