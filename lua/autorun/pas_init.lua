sh_PPP = {}
sv_PPP = {}
cl_PPP = {}

AddCSLuaFile() -- Make the client download this file.
AddCSLuaFile("pas/client/hud.lua")
AddCSLuaFile("pas/client/panel.lua")

if SERVER then
	include( "pas/server/settings.lua" )
	include( "pas/pas.lua" )
	include( "pas/propprotection.lua" )
else
	include( "pas/client/hud.lua" )
	include( "pas/client/panel.lua" )
end