-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile()
AddCSLuaFile( "patchprotect/client/csettings.lua" )
AddCSLuaFile( "patchprotect/client/hud.lua" )
AddCSLuaFile( "patchprotect/client/derma.lua" )
AddCSLuaFile( "patchprotect/client/panel.lua" )
AddCSLuaFile( "patchprotect/client/buddy.lua" )



--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	-- Create tables
	sv_PProtect = {}
	sv_PProtect.Settings = {}

	-- Include server-files
	include( "patchprotect/server/config.lua" )
	include( "patchprotect/server/settings.lua" )
	include( "patchprotect/server/antispam.lua" )
	include( "patchprotect/server/propprotection.lua" )
	include( "patchprotect/server/cleanup.lua" )
	include( "patchprotect/server/buddy.lua" )

else

	-- Create tables
	cl_PProtect = {}
	cl_PProtect.Settings = {}

	-- Include client-files
	include( "patchprotect/client/csettings.lua" )
	include( "patchprotect/client/hud.lua" )
	include( "patchprotect/client/derma.lua" )
	include( "patchprotect/client/panel.lua" )
	include( "patchprotect/client/buddy.lua" )

end
