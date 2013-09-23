sh_PPP = {}
sv_PPP = {}
cl_PPP = {}

AddCSLuaFile() -- Make the client download this file.
AddCSLuaFile( "pas/cl_test.lua" ) -- Make the client download your "pas/cl_test.lua" file.
AddCSLuaFile("pas/client/hud.lua")
AddCSLuaFile("pas/client/panel.lua")

if SERVER then
	include( "pas/test.lua" ) -- Run the serverside "pas/test.lua" file.
	include( "pas/server/settings.lua" )
	include( "pas/pas.lua" )
	include( "pas/propprotection.lua" )
else
	include( "pas/cl_test.lua" ) -- Run the clientside "pas/cl_test.lua" file.
	include( "pas/client/hud.lua" )
	include( "pas/client/panel.lua" )
end