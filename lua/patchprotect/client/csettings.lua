-----------------------
--  CLIENT SETTINGS  --
-----------------------

-- Create CSettings-Table
cl_PProtect.Settings.CSettings = {}

-- Set default CSettings
local csettings_default = {

	OwnerHUD = 1

}

-- Create SQL-CSettings-Table
if !sql.TableExists( "pprotect_csettings" ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_csettings ( setting TEXT, value TEXT )" )

	table.foreach( csettings_default, function( s, v )
		sql.Query( "INSERT INTO pprotect_csettings ( setting, value ) VALUES ( '" .. s .. "', '" .. tostring( v ) .. "' )" )
	end )

end

-- Load SQL-CSettings
if sql.Query( "SELECT * FROM pprotect_csettings" ) then

	local idata = sql.Query( "SELECT * FROM pprotect_csettings" )
	table.foreach( idata, function( id, sql )
		cl_PProtect.Settings.CSettings[ sql.setting ] = tonumber( sql.value )
	end )

end

-- Update CSettings
function cl_PProtect.update_csetting( setting, value )

	sql.Query( "UPDATE pprotect_csettings SET value = '" .. value .. "' WHERE setting = '" .. setting .. "'" )
	cl_PProtect.Settings.CSettings[ setting ] = tonumber( value )

end

-- Reset CSettings
concommand.Add( "pprotect_reset_csettings", function( ply, cmd, args )

	sql.Query( "DROP TABLE pprotect_csettings" )
	print( "[PProtect-CSettings] Successfully deleted all Client Settings!" )
	print( "[PProtect-CSettings] PLEASE RECONNECT TO GET A NEW TABLE!" )

end )
