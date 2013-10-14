---------------------
--  CREATE TABLES  --
---------------------

sh_PProtect = {}
sv_PProtect = {}
cl_PProtect = {}



-------------------------
--  LOAD CLIENT FILES  --
-------------------------

AddCSLuaFile() -- Make the client download this file.
AddCSLuaFile("PatchProtect/client/hud.lua")
AddCSLuaFile("PatchProtect/client/panel_functions.lua")
AddCSLuaFile("PatchProtect/client/panel.lua")



--------------------------------
--  LOAD SERVER/CLIENT FILES  --
--------------------------------

if SERVER then

	include( "PatchProtect/config.lua" )
	include( "PatchProtect/server/settings.lua" )
	include( "PatchProtect/antispam.lua" )
	include( "PatchProtect/propprotection.lua" )
	include( "PatchProtect/cleanup.lua" )

else

	include( "PatchProtect/client/hud.lua" )
	include( "PatchProtect/client/panel_functions.lua" )
	include( "PatchProtect/client/panel.lua" )
	
end
