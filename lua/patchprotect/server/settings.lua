sv_PProtect.Settings = sv_PProtect.Settings or {}



-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSQLSettings( sqlselect, sqltable, localtable, name )

	if sql.TableExists( sqltable ) then

		-- Check if tables are ok
		if sql.Query( "SELECT " .. sqlselect .. " from " .. sqltable ) == false then

			sql.Query( "DROP TABLE " .. sqltable )

			MsgC(
				Color(255, 0, 0), 
				"[PatchProtect] Deleted old " .. name .. "-Table\n"
			)

		end

	end

	if !sql.TableExists( sqltable ) then
		
		local configs = {}
		local values = {}
		local values2 = {}

		table.foreach( localtable, function( k, v )

			local Type = type( v )

			if Type == "number" then

				if v > math.floor( v ) then Type = string.gsub( Type, "number", "DOUBLE" ) else Type = string.gsub( Type, "number", "INTEGER" ) end
					
			end

			Type = string.gsub( Type, "string", "VARCHAR(255)" )

			table.insert( values2, tostring( k ) .. " " .. Type )
			table.insert( configs, k )
			if type( v ) == "string" then v = "'" .. v .. "'" end
			table.insert( values, v )
				
		end )

		sql.Query( "CREATE TABLE IF NOT EXISTS " .. sqltable .. "(" .. table.concat( values2, ", " ) .. ");" )
		sql.Query( "INSERT INTO " .. sqltable .. "(" .. table.concat( configs, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")" )
		
		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new " .. name .. "-Table\n"
		)

	end
	
	return sql.QueryRow( "SELECT * FROM " .. sqltable .. " LIMIT 1" )
	
end

-- ANTISPAMMED TOOLS
function sv_PProtect.setAntiSpamTools()

	sv_PProtect.Settings.AntiSpamTools = {}

	table.foreach( sv_PProtect.Config.AntiSpamTools, function( key, value )

		if tonumber( value ) == 1 then
			table.insert( sv_PProtect.Settings.AntiSpamTools, key )
		end

	end )

end

-- BLOCKED PROPS
function sv_PProtect.setBlockedProps()

	if sql.TableExists( "pprotect_blockedprops" ) then

		sv_PProtect.BlockedProps = {}
		sv_PProtect.LoadedBlockedProps = sql.QueryRow( "SELECT * FROM pprotect_blockedprops LIMIT 1" ) or {}

		table.foreach( sv_PProtect.LoadedBlockedProps, function( key, value )
			table.insert( sv_PProtect.BlockedProps, value )
		end )

	else

		sv_PProtect.BlockedProps = {}

	end

end

-- BLOCKED TOOLS
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

-- LOAD COMMANDS
sv_PProtect.Settings.AntiSpam = sv_PProtect.loadSQLSettings( "enabled", "pprotect_antispam", sv_PProtect.Config.AntiSpam, "AntiSpam" )
sv_PProtect.Settings.PropProtection = sv_PProtect.loadSQLSettings( "reloadprotection", "pprotect_propprotection", sv_PProtect.Config.PropProtection, "PropProtection" )
sv_PProtect.Config.AntiSpamTools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
sv_PProtect.setAntiSpamTools()
sv_PProtect.setBlockedTools()
sv_PProtect.setBlockedProps()

MsgC(
	Color(0, 255, 0),
	"\n[PatchProtect] Successfully loaded!\n\n"
)



---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
function sv_PProtect.saveAntiSpam( ply, cmd, args )

	if !ply:IsSuperAdmin() and !ply:IsAdmin() then
		sv_PProtect.Notify(ply, "You are not an Admin!")
		return
	end

	local update_value
	table.foreach( sv_PProtect.Config.AntiSpam, function( key, value )

		update_value = tonumber( ply:GetInfo( "PProtect_AS_" .. key ) )

		if key != nil and value != nil and update_value != nil then

			if type(update_value) == "number" then
				sql.Query( "UPDATE pprotect_antispam SET " .. key .. " = " .. update_value )
			elseif type(update_value) == "string" then
				sql.Query( "UPDATE pprotect_antispam SET " .. key .. " = '" .. update_value .. "'" )
			end

		end

	end )

	sv_PProtect.Settings.AntiSpam = sql.QueryRow( "SELECT * FROM pprotect_antispam LIMIT 1" )
	sv_PProtect.InfoNotify( ply, "Saved AntiSpam-Settings" )
	
end
concommand.Add( "btn_save_as", sv_PProtect.saveAntiSpam )

-- PROP PROTECTION
function sv_PProtect.savePropProtection( ply, cmd, args )

	if !ply:IsSuperAdmin() and !ply:IsAdmin() then
		sv_PProtect.Notify( ply, "You are not an Admin!" )
		return
	end

	local update_value
	table.foreach( sv_PProtect.Config.PropProtection, function( key, value )

		update_value = tonumber( ply:GetInfo( "PProtect_PP_" .. key ) )

		if key != nil and value != nil and update_value != nil then

			if type(update_value) == "number" then
				sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = " .. update_value )
			elseif type(update_value) == "string" then
				sql.Query( "UPDATE pprotect_propprotection SET " .. key .. " = '" .. update_value .. "'" )
			end

		end

	end )

	sv_PProtect.Settings.PropProtection = sql.QueryRow( "SELECT * FROM pprotect_propprotection LIMIT 1" )
	sv_PProtect.InfoNotify( ply, "Saved PropProtection-Settings" )

end
concommand.Add( "btn_save_pp", sv_PProtect.savePropProtection )

-- ANTISPAMED TOOLS
function sv_PProtect.saveAntiSpammedTools( ply )

	local toolNames = {}
	local toolValues = {}

	table.foreach( weapons.GetList(), function( _, wep )

		if wep.ClassName == "gmod_tool" then

			table.foreach( wep.Tool, function( name, tool )
				table.insert( toolNames, name )
				table.insert( toolValues, tonumber( ply:GetInfo( "PProtect_AS_tools_" .. name ) ) )
			end )

		end

	end )

	if sql.TableExists( "pprotect_antispam_tools" ) then

		table.foreach( toolNames, function( key, value )
			sql.Query( "UPDATE pprotect_antispam_tools SET " .. value .. " = " .. toolValues[ key ] )
		end )

	else

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_antispam_tools(" .. table.concat( toolNames, ", " ) .. ");" )
		sql.Query( "INSERT INTO pprotect_antispam_tools(" .. table.concat( toolNames, ", " ) .. ") VALUES(" .. table.concat( toolValues, ", " ) .. ")" )

	end

	sv_PProtect.Settings.AntiSpamTools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" )
	sv_PProtect.setAntiSpamTools()
	sv_PProtect.InfoNotify( ply, "Saved ToolProtection-Settings" )

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



-----------------------
--  RELOAD SETTINGS  --
-----------------------

-- FOR A SPECIAL PLAYER
function sv_PProtect.reloadSettingsPlayer( ply )
	
	if !ply or !ply:IsValid() then return end

	if sv_PProtect.Settings.AntiSpam then

		table.foreach( sv_PProtect.Settings.AntiSpam, function( key, value )

			if key != "concommand" then
				ply:ConCommand( "PProtect_AS_" .. key .. " " .. value .. "\n" )
			end

		end )

	end

	if sv_PProtect.AntiSpamTools then

		table.foreach( sv_PProtect.AntiSpamTools, function( key, value )

			ply:ConCommand( "PProtect_AS_tools_" .. key .. " " .. value .. "\n" )

		end )

	end

	if sv_PProtect.Settings.PropProtection then

		table.foreach( sv_PProtect.Settings.PropProtection, function( key, value )

			ply:ConCommand( "PProtect_PP_" .. key .. " " .. value .. "\n" )

		end )

	end

end

-- SET INITIAL VARIABLES FOR EACH PLAYER
local function initalSpawn( ply )

	sv_PProtect.reloadSettings( ply )

end
hook.Add( "PlayerInitialSpawn", "initialSpawn", initalSpawn )

-- FOR EVERYONE
function sv_PProtect.reloadSettings( ply )

	if ply != nil and ply:IsPlayer() then

		sv_PProtect.reloadSettingsPlayer( ply )

	else

		table.foreach( player.GetAll(), function( k, v )
			sv_PProtect.reloadSettingsPlayer( v )
		end )

	end

end
concommand.Add( "sh_PProtect.reloadSettings", sv_PProtect.reloadSettings )



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


--[[
-----------------------------------------------------------
--  DROP ALL PATCHPROTECT DATABASES IF THERE ARE ERRORS  --
-----------------------------------------------------------

function sv_PProtect.dropTables()
	
	sql.Query( "DROP TABLE pprotect_antispam" )
	sql.Query( "DROP TABLE pprotect_propprotection" )

	MsgC(
		Color(235, 0, 0), 
		"[PatchProtect] Cause of a Bug, PatchProtect deleted all Settings. Sorry\n"
	)

	sv_PProtect.getData()

end
if sv_PProtect.Settings.AntiSpam == nil or sv_PProtect.Settings.PropProtection == nil then sv_PProtect.dropTables() end
]]
