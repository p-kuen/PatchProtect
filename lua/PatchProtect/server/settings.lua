sv_PProtect.Settings = sv_PProtect.Settings or {}



-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

function sv_PProtect.SetupSQLSettings( sqlname, name, sqltable, checking )

	if name == "PropProtection" then
		MsgC(
			Color(0,235,200),
			"\n[PatchProtect]"
		)

		MsgC(
			Color(255,255,255),
			" Successfully loaded (Coded by Patcher56 & Ted894)\n\n"
		)
	end

	if sql.TableExists( sqlname ) then

		local checktable = sql.Query( "SELECT " .. checking .. " from " .. sqlname )

		if checktable == false then

			sql.Query( "DROP TABLE " .. sqlname )

			MsgC(
				Color(235, 0, 0), 
				"[PatchProtect] Deleted the old " .. name .. "-Settings-Table\n"
			)

		end

	end

	if not sql.TableExists( sqlname ) then
		
		local options = {}
		local values = {}
		local sqlvars = {}

		table.foreach( sqltable, function( k, v )

			local Type = type( v )

			if Type == "number" then

				local isDecimal
				if tonumber( v ) > math.floor( tonumber( v ) ) then isDecimal = true else isDecimal = false end
				if not isDecimal then Type = string.gsub( Type, "number", "INTEGER" ) else Type = string.gsub( Type, "number", "DOUBLE" ) end
					
			end

			Type = string.gsub( Type, "string", "VARCHAR(255)" )

			table.insert( sqlvars, tostring( k ) .. " " .. Type )

			if k == "concommand" then
				table.insert( values, "'" .. v .. "'" )
				table.insert( options, "'" .. k .. "'" )
			else
				table.insert( values, v )
				table.insert( options, k )
			end
				
		end )

		sql.Query( "CREATE TABLE IF NOT EXISTS " .. sqlname .. "(" .. table.concat( sqlvars, ", " ) .. ");" )
		sql.Query( "INSERT INTO " .. sqlname .. "(" .. table.concat( options, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")" )
		
		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new " .. name .. "-Settings-Table\n"
		)

	end
	
	return sql.QueryRow( "SELECT * FROM " .. sqlname .. " LIMIT 1" )
	
end



-----------------------------
--  SET ANTISPAMMED TOOLS  --
-----------------------------

function sv_PProtect.setAntiSpamTools()

	sv_PProtect.AntiSpamTools = {}

	table.foreach( sv_PProtect.Settings.AntiSpamTools, function( key, value )

		if tonumber( value ) == 1 then
			table.insert( sv_PProtect.AntiSpamTools, key )
		end

	end )

end



---------------------
--  BLOCKED PROPS  --
---------------------

-- SET BLOCKED PROPS
function sv_PProtect.setBlockedProps()

	if sql.TableExists( "pprotect_blockedprops" ) then

		sv_PProtect.BlockedProps = {}
		sv_PProtect.LoadedBlockedProps = sql.QueryRow( "SELECT * FROM pprotect_blockedprops LIMIT 1" ) or {}

		if table.Count( sv_PProtect.LoadedBlockedProps ) != 0 then
			table.foreach( sv_PProtect.LoadedBlockedProps, function( key, value )
				table.insert( sv_PProtect.BlockedProps, value )
			end ) 
		end

	else

		sv_PProtect.BlockedProps = {}

	end

end



---------------------
--  BLOCKED TOOLS  --
---------------------

-- SET BLOCKED TOOLS
function sv_PProtect.setBlockedTools()

	if sql.TableExists( "pprotect_blockedtools" ) then

		sv_PProtect.LoadedBlockedTools = sql.QueryRow( "SELECT * FROM pprotect_blockedtools LIMIT 1" ) or {}
		
		table.foreach( sv_PProtect.LoadedBlockedTools, function( key, value )

			if value == "true" then
				sv_PProtect.LoadedBlockedTools[ key ] = true
			else
				sv_PProtect.LoadedBlockedTools[ key ] = false
			end

		end )
		sv_PProtect.BlockedTools = sv_PProtect.LoadedBlockedTools or {}

	else

		sv_PProtect.BlockedTools = {}

	end

end



--------------------
--  BLOCKED DATA  --
--------------------

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



-----------------------------------
--  GET DATA FROM SQL DATABASES  --
-----------------------------------

function sv_PProtect.getData()

	local SelectAntiSpam = "propblock"
	local SelectPropProtection = "keepadminsprops"

	sv_PProtect.Settings.AntiSpam_General = sv_PProtect.SetupSQLSettings( "pprotect_antispam_general", "AntiSpam", sv_PProtect.ConVars.PProtect_AS, SelectAntiSpam )
	sv_PProtect.Settings.AntiSpamTools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
	sv_PProtect.setAntiSpamTools()
	sv_PProtect.setBlockedTools()
	sv_PProtect.setBlockedProps()
	sv_PProtect.Settings.PropProtection = sv_PProtect.SetupSQLSettings( "pprotect_propprotection", "PropProtection", sv_PProtect.ConVars.PProtect_PP, SelectPropProtection )

end
sv_PProtect.getData()



-----------------------------------------------------------
--  DROP ALL PATCHPROTECT DATABASES IF THERE ARE ERRORS  --
-----------------------------------------------------------

function sv_PProtect.dropTables()
	
	sql.Query( "DROP TABLE pprotect_antispam_general" )
	sql.Query( "DROP TABLE pprotect_propprotection" )

	MsgC(
		Color(235, 0, 0), 
		"[PatchProtect] Cause of a Bug, PatchProtect deleted all Settings. Sorry\n"
	)

	sv_PProtect.getData()

end
if sv_PProtect.Settings.AntiSpam_General == nil or sv_PProtect.Settings.PropProtection == nil then sv_PProtect.dropTables() end



---------------------
--  NOTIFICATIONS  --
---------------------

function sv_PProtect.Notify( ply, text )

	net.Start( "PProtect_Notify" )
		net.WriteString( text )
	net.Send( ply )

end

function sv_PProtect.InfoNotify( ply, text )

	net.Start( "PProtect_InfoNotify" )
		net.WriteString( text )
	net.Send( ply )

end

function sv_PProtect.AdminNotify( text )

	net.Start( "PProtect_AdminNotify" )
		net.WriteString( text )
	net.Broadcast()

end



-----------------------
--  RELOAD SETTINGS  --
-----------------------

-- FOR A SPECIAL PLAYER
function sv_PProtect.reloadSettingsPlayer( ply )
	
	if !ply or !ply:IsValid() then return end

	if sv_PProtect.Settings.AntiSpam_General then

		table.foreach( sv_PProtect.Settings.AntiSpam_General, function( key, value )

			if key != "concommand" then
				ply:ConCommand( "PProtect_AS_" .. key .. " " .. value .. "\n" )
			end

		end )

	end

	if sv_PProtect.Settings.AntiSpamTools then

		table.foreach( sv_PProtect.Settings.AntiSpamTools, function( key, value )

			ply:ConCommand( "PProtect_AS_tools_" .. key .. " " .. value .. "\n" )

		end )

	end

	if sv_PProtect.Settings.PropProtection then

		table.foreach( sv_PProtect.Settings.PropProtection, function( key, value )

			ply:ConCommand( "PProtect_PP_" .. key .. " " .. value .. "\n" )

		end )

	end

end

-- FOR EVERYONE
function sv_PProtect.reloadSettings()

	if ply then

		sv_PProtect.reloadSettingsPlayer( ply )

	else

		table.foreach( player.GetAll(), function( k, v )
			sv_PProtect.reloadSettingsPlayer( v )
		end )

	end

end
concommand.Add( "sh_PProtect.reloadSettings", sv_PProtect.reloadSettings )



---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
function sv_PProtect.Save( ply, cmd, args )

	if !ply:IsSuperAdmin() and !ply:IsAdmin() then
		sv_PProtect.Notify(ply, "You are not an Admin!")
		return
	end

	local s_value
	local toolNames = {}
	local toolValues = {}

	--GENERAL
	table.foreach( sv_PProtect.ConVars.PProtect_AS, function( key, value )

		s_value = tonumber( ply:GetInfo( "PProtect_AS_" .. key ) )

		if key != nil and value != nil and s_value != nil then

			if type(s_value) == "number" then
				sql.Query( "UPDATE pprotect_antispam_general SET " .. key .. " = " .. s_value )
			elseif type(s_value) == "string" then
				sql.Query( "UPDATE pprotect_antispam_general SET " .. key .. " = '" .. s_value .. "'" )
			end

		end

	end )

	sv_PProtect.Settings.AntiSpam_General = sql.QueryRow( "SELECT * FROM pprotect_antispam_general LIMIT 1" )

	--TOOLS
	table.foreach( weapons.GetList(), function( _, wep )

		if wep.ClassName == "gmod_tool" then

			table.foreach( wep.Tool, function(name, tool )
				table.insert( toolNames, name )
				table.insert( toolValues, tonumber( ply:GetInfo("PProtect_AS_tools_" .. name) ) )
			end )

		end

	end )

	if sql.TableExists( "pprotect_antispam_tools" ) then

		table.foreach( toolNames, function( key, value )
			sql.Query( "UPDATE pprotect_antispam_tools SET " .. value .. " = " .. toolValues[key] )
		end )

	end

	if !sql.TableExists( "pprotect_antispam_tools" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_antispam_tools(" .. table.concat( toolNames, ", " ) .. ");" )
		sql.Query( "INSERT INTO pprotect_antispam_tools(" .. table.concat( toolNames, ", " ) .. ") VALUES(" .. table.concat( toolValues, ", " ) .. ")" )

		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new Tools-Settings-Table!\n"
		)

	end

	sv_PProtect.Settings.AntiSpamTools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" )
	sv_PProtect.setAntiSpamTools()
	sv_PProtect.InfoNotify( ply, "Saved AntiSpam Settings" )
		
end
concommand.Add( "btn_save", sv_PProtect.Save )

-- PROP PROTECTION
function sv_PProtect.Save_PP( ply, cmd, args )

	if !ply:IsSuperAdmin() and !ply:IsAdmin() then
		sv_PProtect.Notify( ply, "You are not an Admin!" )
		return
	end

	local s_value

	table.foreach( sv_PProtect.ConVars.PProtect_PP, function( key, value )

		s_value = tonumber( ply:GetInfo( "PProtect_PP_" .. key ) )

		if key != nil and value != nil and s_value != nil then

			if type(s_value) == "number" then
				sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = " .. s_value )
			elseif type(s_value) == "string" then
				sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = '" .. s_value .. "'" )
			end

		end

	end )

	sv_PProtect.Settings.PropProtection = sql.QueryRow( "SELECT * FROM pprotect_propprotection LIMIT 1" )
	sv_PProtect.InfoNotify( ply, "Saved PropProtection Settings" )

end
concommand.Add( "btn_save_pp", sv_PProtect.Save_PP )




--------------------
--  OTHER THINGS  --
--------------------

-- RELOAD SETTINGS FOR EACH PLAYER
local function initalSpawn( ply )

	sv_PProtect.reloadSettings( ply )

end
hook.Add( "PlayerInitialSpawn", "initialSpawn", initalSpawn )
