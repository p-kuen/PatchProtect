---------------------
--  CREATE TABLES  --
---------------------

sh_PProtect = {}
sv_PProtect = {}
cl_PProtect = {}
cl_PProtect.Settings = {}



-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile()
AddCSLuaFile( "patchprotect/client/hud.lua" )
AddCSLuaFile( "patchprotect/client/panel_functions.lua" )
AddCSLuaFile( "patchprotect/client/panel.lua" )
AddCSLuaFile( "patchprotect/client/buddy.lua" )


--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	include( "patchprotect/server/config.lua" )
	include( "patchprotect/server/settings.lua" )
	include( "patchprotect/server/antispam.lua" )
	include( "patchprotect/server/propprotection.lua" )
	include( "patchprotect/server/cleanup.lua" )
	include( "patchprotect/server/buddy.lua" )

else

	include( "patchprotect/client/hud.lua" )
	include( "patchprotect/client/panel_functions.lua" )
	include( "patchprotect/client/panel.lua" )
	include( "patchprotect/client/buddy.lua" )

end
