-----------------------
--  NETWORK STRINGS  --
-----------------------

-- SETTINGS
util.AddNetworkString( "pprotect_new_settings" )
util.AddNetworkString( "pprotect_save" )

-- CLEANUP
util.AddNetworkString( "pprotect_cleanup" )
util.AddNetworkString( "pprotect_new_counts" )

-- BUDDY
util.AddNetworkString( "pprotect_buddy" )
util.AddNetworkString( "pprotect_info_buddy" )
util.AddNetworkString( "pprotect_send_buddies" )

-- BLOCKED PROPS/ENTS
util.AddNetworkString( "pprotect_request_ents" )
util.AddNetworkString( "pprotect_send_ents" )
util.AddNetworkString( "pprotect_save_ents" )
util.AddNetworkString( "pprotect_save_cent" )

-- ANTISPAMED/BLOCKED TOOLS
util.AddNetworkString( "pprotect_request_tools" )
util.AddNetworkString( "pprotect_send_tools" )
util.AddNetworkString( "pprotect_save_tools" )

-- NOTIFICATIONS
util.AddNetworkString( "pprotect_notify" )



----------------------
--  DEFAULT CONFIG  --
----------------------

sv_PProtect.Config = {}

-- ANTI SPAM
sv_PProtect.Config.Antispam = {

	enabled = true,
	admins = false,
	alert = true,

	tool = true,
	toolblock = true,
	propblock = true,
	entblock = true,
	propinprop = true,

	cooldown = 0.3,
	spam = 2,
	spamaction = "Nothing",
	bantime = 10,
	concommand = "Put your command here"

}

-- PROP PROTECTION
sv_PProtect.Config.Propprotection = {

	enabled = true,
	superadmins = true,
	admins = false,
	adminscleanup = false,

	use = true,
	reload = true,
	damage = true,
	damageinvehicle = true,
	gravgun = true,
	proppickup = true,

	creator = false,
	propdriving = false,
	worldpick = false,
	worlduse = true,
	worldtool = false,
	worldgrav = true,

	propdelete = true,
	adminprops = false,
	delay = 120

}
