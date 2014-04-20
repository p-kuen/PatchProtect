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
AddCSLuaFile("patchprotect/client/panel.lua")
AddCSLuaFile("patchprotect/client/panel_functions.lua")


--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	include( "patchprotect/server/config.lua" )
	include( "patchprotect/server/settings.lua" )

else

	include( "patchprotect/client/panel.lua" )
	include( "patchprotect/client/panel_functions.lua" )

end
