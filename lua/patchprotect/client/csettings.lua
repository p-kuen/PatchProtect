--------------------
--  HUD SETTINGS  --
--------------------

-- Create CSettings-Table
cl_PProtect.Settings.CSettings = {}

-- Default Settings-Table
local csettings_default = {
	
	OwnerHUD = 1

}

-- Create new SQL-Table
if !sql.TableExists( "pprotect_csettings" ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_csettings ( setting TEXT, value TEXT )" )

	table.foreach( csettings_default, function( s, v )
		sql.Query( "INSERT INTO pprotect_csettings ( setting, value ) VALUES ( '" .. s .. "', '" .. tostring( v ) .. "' )" )
	end )

end

-- Load CSettings from SQL-Table
if sql.Query( "SELECT * FROM pprotect_csettings" ) then

	local idata = sql.Query( "SELECT * FROM pprotect_csettings" )
	table.foreach( idata, function( id, sql )
		cl_PProtect.Settings.CSettings[ sql.setting ] = tonumber( sql.value )
	end )

end

-- Update Client Settings
function cl_PProtect.update_csetting( setting, value )

	-- Update setting in SQL-Table and current Table
	sql.Query( "UPDATE pprotect_csettings SET value = '" .. value .. "' WHERE setting = '" .. setting .. "'" )
	cl_PProtect.Settings.CSettings[ setting ] = tonumber( value )

end

-- Print Client Settings
concommand.Add( "pprotect_reset_csettings", function( ply, cmd, args )
	
	-- Delete old SQL-Table
	sql.Query( "DROP TABLE pprotect_csettings" )
	print( "[PProtect-CSettings] Successfully deleted all Client Settings!" )
	print( "[PProtect-CSettings] PLEASE RECONNECT TO GET A NEW TABLE!" )

end )
