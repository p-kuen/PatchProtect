-----------------------
--  CLIENT SETTINGS  --
-----------------------

-- Delete old settings version
if sql.QueryValue( "SELECT value FROM pprotect_csettings WHERE setting = 'OwnerHUD'" ) == "1" then
	sql.Query( "DROP TABLE pprotect_csettings" )
end

-- Create SQL-CSettings-Table
if !sql.TableExists( "pprotect_csettings" ) then
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_csettings ( setting TEXT, value TEXT )" )
end

-- Set default CSettings
local csettings_default = { ownerhud = true, fppmode = false, notes = true }

-- Check/Load SQL-CSettings
table.foreach( csettings_default, function( setting, value )

	local v = sql.QueryValue( "SELECT value FROM pprotect_csettings WHERE setting = '" .. setting .. "'" )
	if !v then
		sql.Query( "INSERT INTO pprotect_csettings ( setting, value ) VALUES ( '" .. setting .. "', '" .. tostring( value ) .. "' )" )
		cl_PProtect.Settings.CSettings[ setting ] = value
	else
		cl_PProtect.Settings.CSettings[ setting ] = tobool( v )
	end

end )

-- Update CSettings
function cl_PProtect.update_csetting( setting, value )

	sql.Query( "UPDATE pprotect_csettings SET value = '" .. tostring( value ) .. "' WHERE setting = '" .. setting .. "'" )
	cl_PProtect.Settings.CSettings[ setting ] = value

end

-- Reset CSettings
concommand.Add( "pprotect_reset_csettings", function( ply, cmd, args )

	sql.Query( "DROP TABLE pprotect_csettings" )
	print( "[PProtect-CSettings] Successfully deleted all Client Settings!" )
	print( "[PProtect-CSettings] PLEASE RECONNECT TO GET A NEW TABLE!" )

end )
