----------------------
--  RESET SETTINGS  --
----------------------

local function resetSettings( ply, cmd, args, auto )

	-- all valid tables
	local tabs = { "all", "help", "antispam", "propprotection", "blocked_props", "blocked_ents", "blocked_tools", "antispam_tools" }

	-- help for reset command
	if args[1] == "help" then MsgC( Color( 255, 0, 0 ), "\n[PatchProtect-Reset]", Color( 255, 255, 255 ), " Use all, antispam, propprotection, blocked_props, blocked_ents, blocked_tools or antispam_tools!\n" ) return end

	-- reset all sql-tables
	if args[1] == "all" then
		table.foreach( tabs, function( key, value ) sql.Query( "DROP TABLE pprotect_" .. value ) end )
		if auto == "auto" then return end
		MsgC( Color( 255, 0, 0 ), "\n[PatchProtect-Reset]", Color( 255, 255, 255 ), " Successfully deleted all sql-settings!\n", Color( 255, 0, 0 ), "[PatchProtect-Reset]", Color( 255, 255, 255 ), " PLEASE RESTART YOUR SERVER!\n" ) return
	end

	-- check argument
	if !table.HasValue( tabs, args[1] ) then MsgC( Color( 255, 0, 0 ), "\n[PatchProtect-Reset]", Color( 255, 255, 255 ), " " .. args[1] .. " is not a valid sql-table!\n" ) return end

	-- delete sql-table
	sql.Query( "DROP TABLE pprotect_" .. args[1] )
	MsgC( Color( 255, 0, 0 ), "\n[PatchProtect-Reset]", Color( 255, 255, 255 ), " Successfully deleted all " .. args[1] .. "-settings!\n", Color( 255, 0, 0 ), "[PatchProtect-Reset]", Color( 255, 255, 255 ), " PLEASE RESTART THE SERVER WHEN YOU ARE FINISHED WITH ALL RESETS!\n" )

end 
concommand.Add( "pprotect_reset", resetSettings )



---------------------
--  LOAD SETTINGS  --
---------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSettings( name )

	local sqltable = "pprotect_" .. string.lower( name )
	if !sql.TableExists( sqltable ) then sql.Query( "DROP TABLE " .. sqltable ) end
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

-- BLOCKED ENTS
function sv_PProtect.loadBlockedEnts( typ )

	if !sql.TableExists( "pprotect_blocked_" .. typ ) or !sql.Query( "SELECT * FROM pprotect_blocked_" .. typ ) then return {} end

	local sql_ents = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_blocked_" .. typ ), function( id, ent )
		sql_ents[ ent.name ] = ent.model
	end )

	return sql_ents

end

-- ANTISPAMMED/BLOCKED TOOLS
function sv_PProtect.loadBlockedTools( typ )

	if !sql.TableExists( "pprotect_" .. typ .. "_tools" ) or !sql.Query( "SELECT * FROM pprotect_" .. typ .. "_tools" ) then return {} end

	local sql_tools = {}
	table.foreach( sql.Query( "SELECT * FROM pprotect_" .. typ .. "_tools" ), function( ind, tool )
		sql_tools[ tool.tool ] = tobool( tool.bool )
	end )

	return sql_tools

end

-- LOAD SETTINGS
local sql_version = "2.3"
if !sql.TableExists( "pprotect_version" ) or sql.QueryValue( "SELECT * FROM pprotect_version" ) != sql_version then
	resetSettings( nil, nil, { "all" }, "auto" )
	sql.Query( "DROP TABLE pprotect_version" ) sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_version ( info TEXT )" ) sql.Query( "INSERT INTO pprotect_version ( info ) VALUES ( '" .. sql_version .. "' )" )
	MsgC( Color( 255, 0, 0 ), "\n[PatchProtect-Reset]", Color( 255, 255, 255 ), " Reset all sql-settings due a new sql-table-version, sry!\nYou don't need to resetart the server, but please check all settings. Thanks!\n" )
end
sv_PProtect.Settings = { Antispam = sv_PProtect.loadSettings( "Antispam" ), Propprotection = sv_PProtect.loadSettings( "Propprotection" ) }
sv_PProtect.Blocked = { props = sv_PProtect.loadBlockedEnts( "props" ), ents = sv_PProtect.loadBlockedEnts( "ents" ), atools = sv_PProtect.loadBlockedTools( "antispam" ), btools = sv_PProtect.loadBlockedTools( "blocked" ) }
MsgC( Color( 255, 255, 0 ), "\n[PatchProtect]", Color( 255, 255, 255 ), " Successfully loaded!\n\n" )



---------------------
--  SAVE SETTINGS  --
---------------------

-- SAVE ANTISPAM/PROP PROTECTION
net.Receive( "pprotect_save", function( len, pl )

	if !pl:IsSuperAdmin() then return end

	local data = net.ReadTable()
	sv_PProtect.Settings[ data[1] ] = data[2]
	sv_PProtect.sendSettings()

	-- SAVE TO SQL TABLES
	table.foreach( sv_PProtect.Settings[ data[1] ], function( setting, value )
		sql.Query( "UPDATE pprotect_" .. string.lower( data[1] ) .. " SET value = '" .. tostring( value ) .. "' WHERE setting = '" .. setting .. "'" )
	end )

	sv_PProtect.Notify( pl, "Saved new " .. data[1] .. "-Settings", "info" )
	print( "[PatchProtect - " .. data[1] .. "] " .. pl:Nick() .. " saved new " .. data[1] .. "-Settings!" )

end )

-- SAVE BLOCKED PROPS/ENTS
function sv_PProtect.saveBlockedEnts( typ, data )

	sql.Query( "DROP TABLE pprotect_blocked_" .. typ )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_blocked_" .. typ .. " ( name TEXT, model TEXT )" )

	table.foreach( data, function( n, m )
		sql.Query( "INSERT INTO pprotect_blocked_" .. typ .. " ( name, model ) VALUES ( '" .. n .. "', '" .. m .. "' )" )
	end )

end

-- SAVE ANTISPAMED/BLOCKED TOOLS
function sv_PProtect.saveBlockedTools( typ, data )

	sql.Query( "DROP TABLE pprotect_" .. typ .. "_tools" )
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_" .. typ .. "_tools ( tool TEXT, bool TEXT )" )

	table.foreach( data, function( tool, bool )
		sql.Query( "INSERT INTO pprotect_" .. typ .. "_tools ( tool, bool ) VALUES ( '" .. tool .. "', '" .. tostring( bool ) .. "' )" )
	end )

end



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
		if args and args[1] then net.WriteString( args[1] ) end
	if ply then net.Send( ply ) else net.Broadcast() end

end
hook.Add( "PlayerInitialSpawn", "pprotect_playersettings", sv_PProtect.sendSettings )
concommand.Add( "pprotect_request_new_settings", sv_PProtect.sendSettings )

-- SEND NOTIFICATION
function sv_PProtect.Notify( ply, text, typ )

	net.Start( "pprotect_notify" )
		net.WriteTable( { text, typ } )
	if ply then net.Send( ply ) else net.Broadcast() end

end
