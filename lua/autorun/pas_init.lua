sh_PP = {}
sv_PP = {}
cl_PP = {}

AddCSLuaFile() -- Make the client download this file.
AddCSLuaFile("pas/client/hud.lua")
AddCSLuaFile("pas/client/panel_functions.lua")
AddCSLuaFile("pas/client/panel.lua")

if SERVER then
	include( "pas/sh_config.lua" )
	include( "pas/server/settings.lua" )
	include( "pas/pas.lua" )
	include( "pas/propprotection.lua" )
else
	include( "pas/client/hud.lua" )
	include( "pas/client/panel_functions.lua" )
	include( "pas/client/panel.lua" )
end