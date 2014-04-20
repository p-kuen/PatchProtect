-----------------------
--  NETWORK STRINGS  --
-----------------------

-- SETTINGS
util.AddNetworkString( "new_client_settings" )
util.AddNetworkString( "save_antispam_settings" )
util.AddNetworkString( "save_propprotection_settings" )

-- CLEANUP
util.AddNetworkString( "cleanup_map" )
util.AddNetworkString( "cleanup_disconnected_player" )
util.AddNetworkString( "cleanup_player" )

util.AddNetworkString( "get_player_props_count" )
util.AddNetworkString( "send_player_props_count" )

-- BUDDY
util.AddNetworkString( "add_buddy" )
util.AddNetworkString( "delete_buddy" )
util.AddNetworkString( "send_buddy" )
util.AddNetworkString( "send_other_buddy" )

-- HUD
util.AddNetworkString( "get_owner" )
util.AddNetworkString( "send_owner" )

-- ANTISPAMED TOOLS, BLOCKED PROPS, BLOCKED TOOLS
util.AddNetworkString( "open_antispam_tool" )
util.AddNetworkString( "open_blocked_prop" )
util.AddNetworkString( "open_blocked_tool" )

util.AddNetworkString( "send_antispam_tool" )
util.AddNetworkString( "send_blocked_prop" )
util.AddNetworkString( "send_blocked_prop_cpanel" )
util.AddNetworkString( "send_blocked_tool" )

util.AddNetworkString( "get_antispam_tool" )
util.AddNetworkString( "get_blocked_prop" )
util.AddNetworkString( "get_blocked_tool" )

-- NOTIFICATIONS
util.AddNetworkString( "PProtect_InfoNotify" )
util.AddNetworkString( "PProtect_AdminNotify" )
util.AddNetworkString( "PProtect_Notify" )



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
