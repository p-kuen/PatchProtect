-----------------------
--  NETWORK STRINGS  --
-----------------------

-- SETTINGS
util.AddNetworkString( "pprotect_new_settings" )
util.AddNetworkString( "pprotect_save_antispam" )
util.AddNetworkString( "pprotect_save_propprotection" )

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

-- ANTISPAMED TOOLS, BLOCKED PROPS, BLOCKED TOOLS
util.AddNetworkString( "pprotect_antispamtools" )
util.AddNetworkString( "pprotect_blockedprops" )
util.AddNetworkString( "pprotect_blockedtools" )

util.AddNetworkString( "get_antispam_tool" )
util.AddNetworkString( "get_blocked_prop" )
util.AddNetworkString( "get_blocked_tool" )

util.AddNetworkString( "pprotect_send_antispamed_tools" )
util.AddNetworkString( "pprotect_send_blocked_props" )
util.AddNetworkString( "pprotect_send_blocked_props_cpanel" )
util.AddNetworkString( "pprotect_send_blocked_tools" )

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
	toolblock = true,
	propblock = true,
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
	adminssuperadmins = false,
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
