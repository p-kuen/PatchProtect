---------------------
--  ANTISPAM MENU  --
---------------------

function cl_PProtect.ASMenu( Panel )

	-- clear Panel
	Panel:ClearControls()

	-- update Panel
	if !cl_PProtect.ASCPanel then
		cl_PProtect.ASCPanel = Panel
	end

	-- check Admin
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- main Settings
	cl_PProtect.addlbl( Panel, "General Settings:", true )
	cl_PProtect.addchk( Panel, "Enable AntiSpam", "antispam", "enabled" )

	if cl_PProtect.Settings.Antispam[ "enabled" ] == 1 then

		-- General
		cl_PProtect.addchk( Panel, "Ignore Admins", "antispam", "admins" )
		cl_PProtect.addchk( Panel, "Admin-Alert Sound", "antispam", "adminalertsound" )

		-- Anti-Spam features
		cl_PProtect.addlbl( Panel, "\nEnable/Disable antispam features:", true )
		cl_PProtect.addchk( Panel, "Tool-AntiSpam", "antispam", "toolprotection" )
		cl_PProtect.addchk( Panel, "Tool-Block", "antispam", "toolblock" )
		cl_PProtect.addchk( Panel, "Prop-Block", "antispam", "propblock" )
		cl_PProtect.addchk( Panel, "Prop-In-Prop", "antispam", "propinprop" )

		-- Tool Protection
		if cl_PProtect.Settings.Antispam[ "toolprotection" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set antispamed Tools", "pprotect_antispamtools" )
		end

		-- Tool Block
		if cl_PProtect.Settings.Antispam[ "toolblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Tools", "pprotect_blockedtools" )
		end

		-- Prop Block
		if cl_PProtect.Settings.Antispam[ "propblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Props", "pprotect_blockedprops" )
		end

		-- Cooldown/Spamaction
		cl_PProtect.addlbl( Panel, "\nDuration till the next prop-spawn/tool-fire:", true )
		cl_PProtect.addsld( Panel, 0, 10, "Cooldown (Seconds)", "antispam", cl_PProtect.Settings.Antispam[ "cooldown" ], 1, "cooldown" )
		cl_PProtect.addlbl( Panel, "Number of props till admins get warned:" )
		cl_PProtect.addsld( Panel, 0, 40, "Amount", "antispam", cl_PProtect.Settings.Antispam[ "spam" ], 0, "spam" )
		cl_PProtect.addlbl( Panel, "Autotmatic action after spamming:" )
		cl_PProtect.addcmb( Panel, { "Nothing", "Cleanup", "Kick", "Ban", "Command" }, "spamaction", cl_PProtect.Settings.Antispam[ "spamaction" ] )

		if cl_PProtect.Settings.Antispam[ "spamaction" ] == "Ban" then
			cl_PProtect.addsld( Panel, 0, 60, "Ban (Minutes)", "antispam", cl_PProtect.Settings.Antispam[ "bantime" ], 0, "bantime" )
		elseif cl_PProtect.Settings.Antispam[ "spamaction" ] == "Command" then
			cl_PProtect.addlbl( Panel, "Use '<player>' to use the spamming player!" )
			cl_PProtect.addlbl( Panel, "Some commands need sv_cheats 1 to run,\nlike 'kill <player>'" )
			cl_PProtect.addtxt( Panel, cl_PProtect.Settings.Antispam[ "concommand" ] )
		end

	end

	-- save Settings
	cl_PProtect.addbtn( Panel, "Save Settings", "pprotect_save_antispam" )

end



--------------
--  FRAMES  --
--------------

-- ANTISPAMED TOOLS
net.Receive( "get_antispam_tool", function()

	cl_PProtect.Settings.Antispamtools = net.ReadTable()
	local frm = cl_PProtect.addfrm( 250, 350, "Set antispamed Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Antispamtools, "pprotect_send_antispamed_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Antispamtools ) do

		cl_PProtect.addchk( frm, key, "antispamtools", key )

	end

end )

-- BLOCKED PROPS
net.Receive( "get_blocked_prop", function()

	cl_PProtect.Settings.Blockedprops = net.ReadTable()
	local frm = cl_PProtect.addfrm( 800, 600, "Set blocked Props:", false, true, true, "Save Props", cl_PProtect.Settings.Blockedprops, "pprotect_send_blocked_props" )

	table.foreach( cl_PProtect.Settings.Blockedprops, function( key, value )

		local Icon = vgui.Create( "SpawnIcon", frm )
		Icon:SetModel( value )

		Icon.DoClick = function()

			local menu = DermaMenu()
			menu:AddOption( "Remove from blocked Props", function()
				table.RemoveByValue( cl_PProtect.Settings.Blockedprops, value )
				Icon:Remove()
				frm:InvalidateLayout()
			end )
			menu:Open()

		end

		function Icon:Paint()
			draw.RoundedBox( 0, 0, 0, Icon:GetWide(), Icon:GetTall(), Color( 200, 200, 200, 255 ) )
		end

		frm:AddItem( Icon )

	end )

end )

-- BLOCKED TOOLS
net.Receive( "get_blocked_tool", function()

	cl_PProtect.Settings.Blockedtools = net.ReadTable()
	local frm = cl_PProtect.addfrm( 250, 350, "Set blocked Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Blockedtools, "pprotect_send_blocked_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Blockedtools ) do

		cl_PProtect.addchk( frm, key, "blockedtools", key )

	end

end )



---------------------------
--  PROPPROTECTION MENU  --
---------------------------

function cl_PProtect.PPMenu( Panel )

	-- clear Panel
	Panel:ClearControls()

	-- update Panel
	if !cl_PProtect.PPCPanel then
		cl_PProtect.PPCPanel = Panel
	end

	-- check Admin
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- main Setttings
	cl_PProtect.addlbl( Panel, "General Settings:", true )
	cl_PProtect.addchk( Panel, "Enable PropProtection", "propprotection", "enabled" )
	
	if cl_PProtect.Settings.Propprotection[ "enabled" ] == 1 then

		-- General
		cl_PProtect.addchk( Panel, "Ignore SuperAdmins", "propprotection", "superadmins" )
		cl_PProtect.addchk( Panel, "Ignore Admins", "propprotection", "admins" )
		if cl_PProtect.Settings.Propprotection[ "admins" ] == 1 then
			cl_PProtect.addchk( Panel, "Admins can use SuperAdmins'-Props", "propprotection", "adminssuperadmins", "Touch, Tool, Use, ..." )
		end
		cl_PProtect.addchk( Panel, "Admins can use Cleanup-Menu", "propprotection", "adminscleanup" )
		cl_PProtect.addchk( Panel, "FPP-Mode (Owner HUD)", "propprotection", "fppmode", "Owner will be shown under the crosshair" )

		-- Protections
		cl_PProtect.addlbl( Panel, "\nProtection Settings:", true )
		cl_PProtect.addchk( Panel, "Use-Protection", "propprotection", "useprotection" )
		cl_PProtect.addchk( Panel, "Reload-Protection", "propprotection", "reloadprotection" )
		cl_PProtect.addchk( Panel, "Damage-Protection", "propprotection", "damageprotection" )
		cl_PProtect.addchk( Panel, "GravGun-Protection", "propprotection", "gravgunprotection" )
		cl_PProtect.addchk( Panel, "PropPickup-Protection", "propprotection", "proppickup", "Pick up props with 'use'-key" )

		-- Restrictions
		cl_PProtect.addlbl( Panel, "\nSpecial User-Restrictions:", true )
		cl_PProtect.addchk( Panel, "Allow Creator-Tool", "propprotection", "creatorprotection", "ie. spawning weapons with the toolgun" )
		cl_PProtect.addchk( Panel, "Allow Prop-Driving", "propprotection", "propdriving", "Allow users to drive props over the context menu (c-key)" )
		cl_PProtect.addchk( Panel, "Allow World-Props", "propprotection", "worldprops", "Allow users to physgun, toolgun, use, ... world props" )
		cl_PProtect.addchk( Panel, "Allow World-Buttons/Doors", "propprotection", "worldbutton", "Allow users to press World-Buttons/Doors" )

		cl_PProtect.addlbl( Panel, "\nProp-Delete on Disconnect:", true )
		cl_PProtect.addchk( Panel, "Use Prop-Delete", "propprotection", "propdelete" )

		-- Prop-Delete
		if cl_PProtect.Settings.Propprotection[ "propdelete" ] == 1 then
			cl_PProtect.addchk( Panel, "Keep admin's props", "propprotection", "adminprops" )
			cl_PProtect.addsld( Panel, 5, 300, "Delay (sec.)", "propprotection", cl_PProtect.Settings.Propprotection[ "delay" ], 0, "delay" )
		end

	end

	-- save Settings
	cl_PProtect.addbtn( Panel, "Save Settings", "pprotect_save_propprotection" )

end



------------------
--  BUDDY MENU  --
------------------

function cl_PProtect.BMenu( Panel )

	-- clear Panel
	Panel:ClearControls()

	-- update Panel
	if !cl_PProtect.BCPanel then
		cl_PProtect.BCPanel = Panel
	end
	
	-- Buddy-Permission-Table
	local buddy_permissions = {

		"Use",
		"PhysGun",
		"ToolGun",
		"Damage",
		"Property"
	
	}

	local newBuddy = {
		player = nil,
		permissions = {}
	}

	local selectedBuddy = {
		nick = nil,
		uniqueid = nil
	}

	local me = LocalPlayer()
	local btn_addbuddy
	local btn_deletebuddy

	cl_PProtect.addlbl( Panel, "Add a new buddy:", true )

	local list_allplayers = cl_PProtect.addlvw( Panel, { "Name" } , function( selectedLine )

		btn_addbuddy:SetDisabled( false )
		newBuddy.player = selectedLine.player

	end )

	table.foreach( player.GetAll(), function( key, ply )

		if ply == me then return end
		local new = true

		if me.Buddies != nil and table.Count( me.Buddies ) > 0 then

			table.foreach( me.Buddies, function( key, buddy )

				if ply:UniqueID() == buddy.uniqueid then new = false end

			end )

		end

		if !new then return end
		local newline = list_allplayers:AddLine( ply:Nick() )
		newline.player = ply
		
	end )

	-- BUDDY PERMISSIONS
	table.foreach( buddy_permissions, function( key, permission )

		cl_PProtect.addchk( Panel, permission, "", "", nil, function( checked )

			newBuddy.permissions[ string.lower( permission ) ] = checked

		end )

	end )

	-- ADD BUDDY
	btn_addbuddy = cl_PProtect.addbtn( Panel, "Add selected buddy" , "", function() cl_PProtect.AddBuddy( newBuddy ) end )
	btn_addbuddy:SetDisabled( true )

	-- BUDDY LIST
	cl_PProtect.addlbl( Panel, "Your Buddies:", true )
	local list_mybuddies = cl_PProtect.addlvw( Panel, { "Name", "Permission" } , function( selectedLine )

		btn_deletebuddy:SetDisabled( false )
		selectedBuddy.nick = selectedLine.nick
		selectedBuddy.uniqueid = selectedLine.uniqueid

	end )

	if me.Buddies != nil and table.Count( me.Buddies ) > 0 then

		table.foreach( me.Buddies, function( key, buddy )

			local line = list_mybuddies:AddLine( buddy.nick, buddy.permission )
			line.nick = buddy.nick
			line.uniqueid = buddy.uniqueid

		end )

	end

	-- DELETE BUDDY
	btn_deletebuddy = cl_PProtect.addbtn( Panel, "Delete selected buddy" , "", function() cl_PProtect.DeleteBuddy( selectedBuddy ) end )
	btn_deletebuddy:SetDisabled( true )

end



--------------------
--  CLEANUP MENU  --
--------------------

function cl_PProtect.CUMenu( Panel )

	-- clear Panel
	RunConsoleCommand( "pprotect_request_newest_counts" )
	Panel:ClearControls()

	-- update Panel
	if !cl_PProtect.CUCPanel then
		cl_PProtect.CUCPanel = Panel
	end

	-- check Admin
	if cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 and !LocalPlayer():IsAdmin() and !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be an Admin to access the Cleanup-Menu!" )
		return
	elseif cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 0 and !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	function pprotect_write_cleanup_menu( global, players )

		cl_PProtect.addlbl( Panel, "Cleanup everything: (Including World Props)", true )
		cl_PProtect.addbtn( Panel, "Cleanup everything (" .. tostring( global ) .. " Props)", "pprotect_cleanup_map" )

		cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:", true )
		cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "pprotect_cleanup_disconnected_player" )

		cl_PProtect.addlbl( Panel, "\nCleanup Player's props:", true )
		table.foreach( players, function( p, c )
			cl_PProtect.addbtn( Panel, "Cleanup " .. p:Nick() .. " (" .. tostring( c ) .. " props)", "pprotect_cleanup_player", { p, tostring( c ) } )
		end )

	end

end



----------------------------
--  CLIENT SETTINGS MENU  --
----------------------------

function cl_PProtect.CSMenu( Panel )

	-- clear Panel
	Panel:ClearControls()

	-- update Panel
	if !cl_PProtect.CSCPanel then
		cl_PProtect.CSCPanel = Panel
	end

	cl_PProtect.addlbl( Panel, "Enable/Disable features:", true )
	cl_PProtect.addchk( Panel, "Use Owner-HUD", "csetting", "OwnerHUD" )

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- Anti-Spam
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", cl_PProtect.ASMenu )

	-- Prop-Protection
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", cl_PProtect.PPMenu )

	-- Buddy
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPBuddy", "Buddy", "", "", cl_PProtect.BMenu )

	-- Cleanup
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPCleanup", "Cleanup", "", "", cl_PProtect.CUMenu )
	
	-- Client-Settings
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPClientSettings", "Client Settings", "", "", cl_PProtect.CSMenu )

end
hook.Add( "PopulateToolMenu", "pprotect_make_menus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PProtect.UpdateMenus()
	
	-- Anti-Spam
	if cl_PProtect.ASCPanel then
		RunConsoleCommand( "pprotect_request_newest_settings", "antispam" )
	end
	
	-- Prop-Protection
	if cl_PProtect.PPCPanel then
		RunConsoleCommand( "pprotect_request_newest_settings", "propprotection" )
	end

	-- Buddy
	if cl_PProtect.BCPanel then
		cl_PProtect.BMenu( cl_PProtect.BCPanel )
	end

	-- Cleanup
	if cl_PProtect.CUCPanel then
		cl_PProtect.CUMenu( cl_PProtect.CUCPanel )
	end

	-- Client-Settings
	if cl_PProtect.CSCPanel then
		cl_PProtect.CSMenu( cl_PProtect.CSCPanel )
	end

end
hook.Add( "SpawnMenuOpen", "pprotect_update_menus", cl_PProtect.UpdateMenus )



---------------
--  NETWORK  --
---------------

-- RECEIVE NEW SETTINGS
net.Receive( "pprotect_new_settings", function()
	
	local settings = net.ReadTable()
	local settings_type = net.ReadString()

	cl_PProtect.Settings.Antispam = settings[ "AntiSpam" ]
	cl_PProtect.Settings.Propprotection = settings[ "PropProtection" ]

	if settings_type == "antispam" then
		cl_PProtect.ASMenu( cl_PProtect.ASCPanel )
	elseif settings_type == "propprotection" then
		cl_PProtect.PPMenu( cl_PProtect.PPCPanel )
	end

end )

-- RECEIVE NEW PROP-COUNTS
net.Receive( "pprotect_new_counts", function()

	-- Check Permissions
	if cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 then
		if !LocalPlayer():IsAdmin() and !LocalPlayer():IsSuperAdmin() then return end
	elseif cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 0 then
		if !LocalPlayer():IsSuperAdmin() then return end
	end

	local counts = net.ReadTable()

	pprotect_write_cleanup_menu( counts[ "global" ], counts[ "players" ] )

end )
