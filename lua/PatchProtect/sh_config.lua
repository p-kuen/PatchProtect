-- CHECK FOR EXISTING TABLE
if sv_PProtect.ConVars then
	--return
end

--NETWORKING
util.AddNetworkString("generalSettings")
util.AddNetworkString("propProtectionSettings")
util.AddNetworkString("PatchPPOwner")

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
	concommand = "blabla",
	toolprotection = 1
}

sv_PProtect.ConVars.PProtect_PP = {
	use = 1,
	noantiadmin = 1,
	use_propdelete = 1,
	propdelete_delay = 120,
	cdrive = 0,
	tool_world = 1
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
