sh_PP = {}
sv_PP = {}
cl_PP = {}

AddCSLuaFile() -- Make the client download this file.
AddCSLuaFile("PatchProtect/client/hud.lua")
AddCSLuaFile("PatchProtect/client/panel_functions.lua")
AddCSLuaFile("PatchProtect/client/panel.lua")

if SERVER then
	include( "PatchProtect/sh_config.lua" )
	include( "PatchProtect/server/settings.lua" )
	include( "PatchProtect/pas.lua" )
	include( "PatchProtect/propprotection.lua" )
else
	include( "PatchProtect/client/hud.lua" )
	include( "PatchProtect/client/panel_functions.lua" )
	include( "PatchProtect/client/panel.lua" )
end