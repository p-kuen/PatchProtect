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

-- HUD
util.AddNetworkString( "pprotect_get_owner" )
util.AddNetworkString( "pprotect_send_owner" )

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
util.AddNetworkString( "pprotect_notify_info" )
util.AddNetworkString( "pprotect_notify_admin" )
util.AddNetworkString( "pprotect_notify_normal" )



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
	playerpickup = 1,
	useprotection = 1,
	creatorprotection = 1,
	gravgunprotection = 1,
	reloadprotection = 1,
	damageprotection = 1,
	propdriving = 0,
	propdelete = 1,
	adminprops = 0,
	delay = 120,
	worldprops = 0,
	fppmode = 0

}
