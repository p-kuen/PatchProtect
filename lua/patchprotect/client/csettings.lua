--------------------
--  HUD SETTINGS  --
--------------------

-- Create CSettings-Table
cl_PProtect.Settings.CSettings = {}

-- Load CSettings from SQL-Database
if sql.Query( "SELECT * FROM pprotect_csettings" ) then

	local idata = sql.Query( "SELECT * FROM pprotect_csettings" )
	table.foreach( idata, function( id, sql )
		
		cl_PProtect.Settings.CSettings[ sql.setting ] = tonumber( sql.value )

	end )

end

-- Update Client Settings
function cl_PProtect.update_csetting( setting, value )

	-- Create new SQL-Database
	if !sql.TableExists( "pprotect_csettings" ) then
		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_csettings ( setting TEXT, value TEXT )" )
	end

	-- Add/Update setting to the SQL-Database
	if !sql.QueryValue( "SELECT value from pprotect_csettings WHERE setting = '" .. setting .. "'" ) then
		sql.Query( "INSERT INTO pprotect_csettings ( setting, value ) VALUES ( '" .. setting .. "', '" .. value .. "' )" )
	else
		sql.Query( "UPDATE pprotect_csettings SET value = '" .. value .. "' WHERE setting = '" .. setting .. "'" )
	end

	cl_PProtect.Settings.CSettings[ setting ] = tonumber( value )

end

-- Print Client Settings
concommand.Add( "pprotect_reset_csettings", function( ply, cmd, args )
	
	sql.Query( "DROP TABLE pprotect_csettings" )
	cl_PProtect.Settings.CSettings = {}
	print( "[PProtect-CSettings] Successfully delted all Client Settings" )

end )
