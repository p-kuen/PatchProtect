------------------
--  NETWORKING  --
------------------

-- ANTISPAM
util.AddNetworkString( "sendAntiSpamSettings" )
util.AddNetworkString( "sendBlockedProp" )
util.AddNetworkString( "getBlockedPropData" )
util.AddNetworkString( "sendNewBlockedPropTable" )
util.AddNetworkString( "getBlockedToolData" )
util.AddNetworkString( "sendNewBlockedToolTable" )
util.AddNetworkString( "sendNewAntiSpammedToolTable" )

-- PROP PROTECTION
util.AddNetworkString( "sendPropProtectionSettings" )
util.AddNetworkString( "getOwner" )
util.AddNetworkString( "sendOwner" )

-- CLEANUP
util.AddNetworkString( "getCount" )
util.AddNetworkString( "sendCount" )

-- BUDDY
util.AddNetworkString( "PProtect_sendBuddy" )
util.AddNetworkString( "PProtect_sendOther" )

-- NOTIFICATIONS
util.AddNetworkString( "PProtect_InfoNotify" )
util.AddNetworkString( "PProtect_AdminNotify" )
util.AddNetworkString( "PProtect_Notify" )



--------------
--  TABLES  --
--------------

-- CONFIG
sv_PProtect.Config = {}

-- ANTI SPAM
sv_PProtect.Config.AntiSpam = {

	enabled = 1,
	admins = 0,
	toolprotection = 1,
	toolblock = 1,
	propblock = 1,
	cooldown = 0.5,
	spam = 10,
	spamaction = 1,
	bantime = 10.5,
	concommand = "Put your command here"

}

-- ANTISPAM TOOLS
sv_PProtect.Config.AntiSpamTools = {}

-- PROP PROTECTION
sv_PProtect.Config.PropProtection = {

	enabled = 1,
	admins = 0,
	useprotection = 1,
	creatorprotection = 1,
	gravgunprotection = 1,
	reloadprotection = 1,
	damageprotection = 1,
	propdriving = 0,
	propdelete = 1,
	adminprops = 0,
	delay = 120

}



------------------------
--  SEND INFORMATION  --
------------------------

function sendConfig( ply )
 
	net.Start( "sendAntiSpamSettings" )
		net.WriteTable( sv_PProtect.Config.AntiSpam )
	net.Send( ply )

	net.Start( "sendPropProtectionSettings" )
		net.WriteTable( sv_PProtect.Config.PropProtection )
	net.Send( ply )
 
end
hook.Add( "PlayerInitialSpawn", "sendConfig", sendConfig )
