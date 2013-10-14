----------------
--  SETTINGS  --
----------------

sv_PProtect.Settings = sv_PProtect.Settings or {}



-----------------------------
--  ANTISPAM SQL SETTINGS  --
-----------------------------

function sv_PProtect.SetupGeneralSettings()

	-- STARTUP MESSAGE
	MsgC(
		Color(0,235,200),
		"\n[PatchProtect]"
	)

	MsgC(
		Color(255,255,255),
		" Successfully loaded (Coded by Patcher56 & Ted894)\n\n"
	)

	if sql.TableExists("pprotect_antispam_general") then

		local checktable = sql.Query("SELECT propblock from pprotect_antispam_general")

		if checktable == false then

			sql.Query("DROP TABLE pprotect_antispam_general")

			MsgC(
				Color(235, 0, 0), 
				"[PatchProtect] Deleted the old General-Settings-Table\n"
			)

		end

	end

	if not sql.TableExists( "pprotect_antispam_general" ) then
		
		local options = {}
		local values = {}
		local sqlvars = {}

		for k, v in pairs( sv_PProtect.ConVars.PProtect_AS ) do

			local Type = type(v)

			if Type == "number" then

				local isDecimal
				if tonumber(v) > math.floor( tonumber(v) ) then isDecimal = true else isDecimal = false end
				if  not isDecimal then Type = string.gsub( Type, "number", "INTEGER" ) else Type = string.gsub( Type, "number", "DOUBLE" ) end
					
			end

			Type = string.gsub( Type, "string", "VARCHAR(255)" )

			if k == "spamcount" or k == "cooldown" then
				table.insert( sqlvars, tostring( k ) .. " " .. Type )
			else
				table.insert( sqlvars, tostring( k ) .. " " .. Type )
			end

			if k == "concommand" then
				table.insert( values, "'" .. v .. "'" )
				table.insert( options, "'" .. k .. "'" )
			else
				table.insert( values, v )
				table.insert( options, k )
			end
				
		end

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_antispam_general(" .. table.concat( sqlvars, ", " ) .. ");" )
		sql.Query( "INSERT INTO pprotect_antispam_general(" .. table.concat( options, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")" )
		
		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new General-Settings-Table\n"
		)

	end
	
	return sql.QueryRow( "SELECT * FROM pprotect_antispam_general LIMIT 1" )
	
end



------------------------------------
--  PROP PROTECTION SQL SETTINGS  --
------------------------------------

function sv_PProtect.SetupPropProtectionSettings()

	if sql.TableExists( "pprotect_propprotection" ) then

		local checktable = sql.Query( "SELECT blockcreatortool from pprotect_propprotection" )

		if checktable == false then

			sql.Query( "DROP TABLE pprotect_propprotection" )

			MsgC(
				Color(235, 0, 0), 
				"[PatchProtect] Deleted the old PropProtection-Table\n"
			)

		end

	end

	if !sql.TableExists( "pprotect_propprotection" ) then
		
		local options = {}
		local values = {}
		local sqlvars = {}

		for k, v in pairs( sv_PProtect.ConVars.PProtect_PP ) do

			local Type = type(v)

			if Type == "number" then

				local isDecimal
				if tonumber(v) > math.floor( tonumber(v) ) then isDecimal = true else isDecimal = false end
				if not isDecimal then Type = string.gsub( Type, "number", "INTEGER" ) else Type = string.gsub( Type, "number", "DOUBLE" ) end
					
			end

			table.insert( sqlvars, tostring(k) .. " " .. Type )
			table.insert( values, v )
			table.insert( options, k )
				
		end

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_propprotection(" .. table.concat( sqlvars, ", " ) .. ");" )
		sql.Query( "INSERT INTO pprotect_propprotection(" .. table.concat( options, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")" )
		
		MsgC(
			Color(0, 240, 100),
			"[PatchProtect] Created new PropProtection-Table\n"
		)

	end

	return sql.QueryRow( "SELECT * FROM pprotect_propprotection LIMIT 1" )
	
end



-------------------------
--  SET BLOCKED TOOLS  --
-------------------------

function sv_PProtect.setBlockedTools()

	sv_PProtect.BlockedTools = {}

	table.foreach( sv_PProtect.Settings.Tools, function( key, value )

		if tonumber( value ) == 1 then
			table.insert( sv_PProtect.BlockedTools, key )
		end

	end )

end



-------------------------------------
--  DROP TABLES IF THERE ARE BUGS  --
-------------------------------------

function sv_PProtect.dropTables()

	sql.Query( "DROP TABLE pprotect_propprotection" )
	sql.Query( "DROP TABLE pprotect_antispam_general" )

	MsgC(
		Color(235, 0, 0), 
		"[PatchProtect] DROPPED ALL TABLES FROM PATCHPROTECT. SORRY\n"
	)

	sv_PProtect.Settings.General = sv_PProtect.SetupGeneralSettings()
	sv_PProtect.Settings.Tools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
	sv_PProtect.setBlockedTools()
	sv_PProtect.Settings.PropProtection = sv_PProtect.SetupPropProtectionSettings()

end

sv_PProtect.Settings.General = sv_PProtect.SetupGeneralSettings()
sv_PProtect.Settings.Tools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" ) or {}
sv_PProtect.setBlockedTools()
sv_PProtect.Settings.PropProtection = sv_PProtect.SetupPropProtectionSettings()

if sv_PProtect.Settings.General == nil or sv_PProtect.Settings.PropProtection == nil then sv_PProtect.dropTables() end



---------------------
--  NOTIFICATIONS  --
---------------------

function sv_PProtect.InfoNotify( ply, text )

	net.Start("PProtect_InfoNotify")
		net.WriteString( text )
	net.Send( ply )

end

function sv_PProtect.AdminNotify( text )

	net.Start("PProtect_AdminNotify")
		net.WriteString( text )
	net.Broadcast()

end

function sv_PProtect.Notify( ply, text )

	net.Start("PProtect_Notify")
		net.WriteString( text )
	net.Send( ply )

end



-----------------------
--  RELOAD SETTINGS  --
-----------------------

function sv_PProtect.reloadSettingsPlayer( ply )
	
	if !ply or !ply:IsValid() then return end

	if sv_PProtect.Settings.General then

		table.foreach( sv_PProtect.Settings.General, function(key, value)

			if key ~= "concommand" then
				ply:ConCommand( "PProtect_AS_" .. key .. " " .. value .. "\n" )
			end

		end )

	end

	if sv_PProtect.Settings.Tools then

		table.foreach( sv_PProtect.Settings.Tools, function(key, value)

			ply:ConCommand( "PProtect_AS_tools_" .. key .. " " .. value .. "\n" )

		end )

	end

	if sv_PProtect.Settings.PropProtection then

		table.foreach( sv_PProtect.Settings.PropProtection, function(key, value)

			ply:ConCommand( "PProtect_PP_" .. key .. " " .. value .. "\n" )

		end )

	end

end

function sv_PProtect.reloadSettings()

	if ply then

		sv_PProtect.reloadSettingsPlayer( ply )

	else

		for k,v in pairs( player.GetAll() ) do
			sv_PProtect.reloadSettingsPlayer( v )
		end

	end

end
concommand.Add("sh_PProtect.reloadSettings", sv_PProtect.reloadSettings)



---------------------
--  SAVE SETTINGS  --
---------------------

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

		if key ~= nil and value ~= nil and s_value ~= nil then

			if type(s_value) == "number" then
				sql.Query("UPDATE pprotect_antispam_general SET " .. key .. " = " .. s_value)
			elseif type(s_value) == "string" then
				sql.Query("UPDATE pprotect_antispam_general SET " .. key .. " = '" .. s_value .. "'")
			end

		end

	end )

	sv_PProtect.Settings.General = sql.QueryRow( "SELECT * FROM pprotect_antispam_general LIMIT 1" )

	--TOOLS
	for _, wep in pairs( weapons.GetList() ) do

		if wep.ClassName == "gmod_tool" then

			local t = wep.Tool

			for name, tool in pairs( t ) do
				table.insert( toolNames, name )
				table.insert( toolValues, tonumber( ply:GetInfo("PProtect_AS_tools_" .. name) ) )
			end

		end

	end

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

	sv_PProtect.Settings.Tools = sql.QueryRow( "SELECT * FROM pprotect_antispam_tools LIMIT 1" )
	sv_PProtect.setBlockedTools()
	sv_PProtect.InfoNotify( ply, "Saved AntiSpam Settings" )
		
end
concommand.Add( "btn_save", sv_PProtect.Save )



---------------------
--  SAVE SETTINGS  --
---------------------

function sv_PProtect.Save_PP( ply, cmd, args )

	if !ply:IsSuperAdmin() and !ply:IsAdmin() then
		sv_PProtect.Notify( ply, "You are not an Admin!" )
		return
	end

	local s_value

	table.foreach( sv_PProtect.ConVars.PProtect_PP, function( key, value )

		s_value = tonumber( ply:GetInfo( "PProtect_PP_" .. key ) )

		if key ~= nil and value ~= nil and s_value ~= nil then

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

-- RELOAD SETTINGS FOR EACH PLAYER
local function initalSpawn( ply )
 
	sv_PProtect.reloadSettings( ply )
 
end
hook.Add( "PlayerInitialSpawn", "initialSpawn", initalSpawn )
