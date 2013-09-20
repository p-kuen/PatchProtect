--Include Server Files
include("pas/server/settings.lua")
include("pas/pas.lua")
include("pas/propprotection.lua")

--Add Client Side Files
AddCSLuaFile("autorun/client/pas_init.lua")
AddCSLuaFile("pas/client/hud.lua")
AddCSLuaFile("pas/client/panel.lua")