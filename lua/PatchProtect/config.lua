--NETWORKING
util.AddNetworkString("generalSettings")
util.AddNetworkString("propProtectionSettings")
util.AddNetworkString( "SetOwnerOverProperty" )
util.AddNetworkString( "getOwner" )
util.AddNetworkString( "sendOwner" )

--Notify Networkstrings
util.AddNetworkString( "PProtect_InfoNotify" )
util.AddNetworkString( "PProtect_AdminNotify" )
util.AddNetworkString( "PProtect_Notify" )

-- CREATE CONVARS TABLE
sv_PProtect.ConVars = {}

-- CLIENT CONVARS
sv_PProtect.ConVars.PProtect_AS = {
	use = 1,
	cooldown = 3.5,
	noantiadmin = 1,
	spamcount = 20,
	spamaction = 1,
	bantime = 10.5,
	concommand = "Put your command here",
	toolprotection = 1,
	propblock = 1
}

sv_PProtect.ConVars.PProtect_PP = {
	use = 1,
	noantiadmin = 1,
	use_propdelete = 1,
	propdelete_delay = 120,
	cdrive = 0,
	tool_world = 1,
	damageprotection = 1,
	reloadprotection = 1,
	gravgunprotection = 1
}

sv_PProtect.ConVars.PProtect_AS_tools = {}

function sendNetworks( ply )
 
	net.Start("generalSettings")
		net.WriteTable( sv_PProtect.ConVars.PProtect_AS )
	net.Send( ply )

	net.Start("propProtectionSettings")
		net.WriteTable( sv_PProtect.ConVars.PProtect_PP )
	net.Send( ply )
 
end
hook.Add( "PlayerInitialSpawn", "sendNetworks", sendNetworks )
