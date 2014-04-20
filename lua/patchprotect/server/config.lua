-----------------------
--  NETWORK STRINGS  --
-----------------------

util.AddNetworkString( "new_client_settings" )



----------------------
--  DEFAULT CONFIG  --
----------------------

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
