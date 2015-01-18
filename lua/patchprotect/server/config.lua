-----------------------
--  NETWORK STRINGS  --
-----------------------

-- SETTINGS
util.AddNetworkString( "pprotect_new_settings" )
util.AddNetworkString( "pprotect_save" )

-- CLEANUP
util.AddNetworkString( "pprotect_cleanup_map" )
util.AddNetworkString( "pprotect_cleanup_disconnected_player" )
util.AddNetworkString( "pprotect_cleanup_player" )
util.AddNetworkString( "pprotect_new_counts" )

-- BUDDY
util.AddNetworkString( "pprotect_send_buddy" )
util.AddNetworkString( "pprotect_send_other_buddy" )

-- OWNER
util.AddNetworkString( "pprotect_get_owner" )
util.AddNetworkString( "pprotect_send_owner" )

-- SHARED ENTITY
util.AddNetworkString( "pprotect_get_sharedEntity" )
util.AddNetworkString( "pprotect_send_sharedEntity" )
util.AddNetworkString( "pprotect_save_sharedEntity" )

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

	toolprotection = true,
	propblock = true,
	entblock = true,
	toolblock = true,
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

	useprotection = true,
	reloadprotection = true,
	damageprotection = true,
	gravgunprotection = true,
	proppickup = true,

	creatorprotection = false,
	propdriving = false,
	worldprops = false,
	worldbutton = false,

	propdelete = true,
	adminprops = false,
	delay = 120

}
