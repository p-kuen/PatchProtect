-------------------------------
--  LOAD/WRITE SQL SETTINGS  --
-------------------------------

-- ANTISPAM AND PROP PROTECTION
function sv_PProtect.loadSQLSettings( sqlselect, sqltable, localtable, name )

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
	
	return sql.QueryRow( "SELECT * FROM " .. sqltable .. " LIMIT 1" )
	
end

-- ANTISPAMMED TOOLS
function sv_PProtect.setAntiSpamTools()

	local sql_as_tools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
	local as_tools = {}

	table.foreach( sql_as_tools, function( tool, blocked )

		if tonumber( blocked ) == 1 then
			table.insert( as_tools, tool )
		end

	end )

	return as_tools

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
sv_PProtect.Settings = {}
sv_PProtect.Settings.AntiSpam = sv_PProtect.loadSQLSettings( "enabled", "pprotect_antispam", sv_PProtect.Config.AntiSpam, "AntiSpam" )
sv_PProtect.Settings.AntiSpamTools = sv_PProtect.setAntiSpamTools()
sv_PProtect.Settings.PropProtection = sv_PProtect.loadSQLSettings( "enabled", "pprotect_propprotection", sv_PProtect.Config.PropProtection, "PropProtection" )
sv_PProtect.Settings.BlockedProps = sv_PProtect.setBlockedProps()
sv_PProtect.Settings.BlockedTools = sv_PProtect.setBlockedTools()

MsgC(
	Color(0, 255, 0),
	"\n[PatchProtect] Successfully loaded!\n\n"
)

--print("\nHier sind alle anzeigen:\n\n")
--print("AntiSpam:")
--PrintTable( sv_PProtect.Settings.AntiSpam )
--print("\nAntiSpamTools:")
--PrintTable( sv_PProtect.Settings.AntiSpamTools )
--print("\nPropProtection:")
--PrintTable( sv_PProtect.Settings.PropProtection )
--print("\nBlockedProps:")
--PrintTable( sv_PProtect.Settings.BlockedProps )
--print("\nBlockedTools:")
--PrintTable( sv_PProtect.Settings.BlockedTools )
--print("\n\n")

---------------------
--  SAVE SETTINGS  --
---------------------

-- ANTI SPAM
function sv_PProtect.saveAntiSpam( ply, cmd, args )

end
--NET RECEIVE NEW ANTISPAM SETTINGS TABLE

-- PROP PROTECTION
function sv_PProtect.savePropProtection( ply, cmd, args )

end
--NET RECEIVE NEW PROP PROTECTION SETTINGS TABLE

-- ANTISPAMED TOOLS
function sv_PProtect.saveAntiSpammedTools( ply )

end
--NET RECEIVE NEW ANTISPAMMED TOOLS TABLE



-----------------------
--  RELOAD SETTINGS  --
-----------------------

-- FOR A SPECIFIC PLAYER
local function sendPlayerSettings( ply )

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.AntiSpam
	new_settings.PropProtection = sv_PProtect.Settings.PropProtection

	net.Start( "new_client_settings" )
		net.WriteTable( new_settings )
	net.Send( ply )

end
hook.Add( "PlayerInitialSpawn", "sendPlayerSettings", sendPlayerSettings )
concommand.Add( "request_newest_settings", sendPlayerSettings )

-- FOR EVERYONE
local function broadcastSettings()

	local new_settings = {}
	new_settings.AntiSpam = sv_PProtect.Settings.AntiSpam
	new_settings.PropProtection = sv_PProtect.Settings.PropProtection

	net.Start( "new_client_settings" )
		net.WriteTable( new_settings )
	net.Broadcast()

end
