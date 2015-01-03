---------------------
--  ANTISPAM MENU  --
---------------------

function cl_PProtect.as_menu( p )

	-- clear Panel
	p:ClearControls()

	-- update Panel
	if !cl_PProtect.as_panel then
		cl_PProtect.as_panel = p
	end

	-- check Admin
	if !LocalPlayer():IsSuperAdmin() then
		p:addlbl( "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- main Settings
	p:addlbl( "General Settings:", true )
	p:addchk( "Enable AntiSpam", nil, cl_PProtect.Settings.Antispam[ "enabled" ], function( c ) cl_PProtect.Settings.Antispam[ "enabled" ] = c end )

	if cl_PProtect.Settings.Antispam[ "enabled" ] then

		-- General
		p:addchk( "Ignore Admins", nil, cl_PProtect.Settings.Antispam[ "admins" ], function( c ) cl_PProtect.Settings.Antispam[ "admins" ] = c end )
		p:addchk( "Admin-Alert Sound", nil, cl_PProtect.Settings.Antispam[ "alert" ], function( c ) cl_PProtect.Settings.Antispam[ "alert" ] = c end )

		-- Anti-Spam features
		p:addlbl( "\nEnable/Disable antispam features:", true )
		p:addchk( "Tool-AntiSpam", nil, cl_PProtect.Settings.Antispam[ "toolprotection" ], function( c ) cl_PProtect.Settings.Antispam[ "toolprotection" ] = c end )
		p:addchk( "Tool-Block", nil, cl_PProtect.Settings.Antispam[ "toolblock" ], function( c ) cl_PProtect.Settings.Antispam[ "toolblock" ] = c end )
		p:addchk( "Prop-Block", nil, cl_PProtect.Settings.Antispam[ "propblock" ], function( c ) cl_PProtect.Settings.Antispam[ "propblock" ] = c end )
		p:addchk( "Prop-In-Prop", nil, cl_PProtect.Settings.Antispam[ "propinprop" ], function( c ) cl_PProtect.Settings.Antispam[ "propinprop" ] = c end )

		-- Tool Protection
		if cl_PProtect.Settings.Antispam[ "toolprotection" ] then
			p:addbtn( "Set antispamed Tools", "pprotect_antispamtools" )
		end

		-- Tool Block
		if cl_PProtect.Settings.Antispam[ "toolblock" ] then
			p:addbtn( "Set blocked Tools", "pprotect_blockedtools" )
		end

		-- Prop Block
		if cl_PProtect.Settings.Antispam[ "propblock" ] then
			p:addbtn( "Set blocked Props", "pprotect_blockedprops" )
		end

		-- Cooldown
		p:addlbl( "\nDuration till the next prop-spawn/tool-fire:", true )
		p:addsld( 0, 10, "Cooldown (Seconds)", cl_PProtect.Settings.Antispam[ "cooldown" ], "Antispam", "cooldown", 1 )
		p:addlbl( "Number of props till admins get warned:" )
		p:addsld( 0, 40, "Amount", cl_PProtect.Settings.Antispam[ "spam" ], "Antispam", "spam", 0 )
		p:addlbl( "Autotmatic action after spamming:" )
		p:addcmb( { "Nothing", "Cleanup", "Kick", "Ban", "Command" }, "spamaction", cl_PProtect.Settings.Antispam[ "spamaction" ] )

		-- Spamaction
		if cl_PProtect.Settings.Antispam[ "spamaction" ] == "Ban" then
			p:addsld( 0, 60, "Ban (Minutes)", cl_PProtect.Settings.Antispam[ "bantime" ], "Antispam", "bantime", 0 )
		elseif cl_PProtect.Settings.Antispam[ "spamaction" ] == "Command" then
			p:addlbl( "Use '<player>' to use the spamming player!" )
			p:addlbl( "Some commands need sv_cheats 1 to run,\nlike 'kill <player>'" )
			p:addtxt( cl_PProtect.Settings.Antispam[ "concommand" ] )
		end

	end

	-- save Settings
	p:addbtn( "Save Settings", "pprotect_save_antispam" )

end



--------------
--  FRAMES  --
--------------

-- ANTISPAMED TOOLS
net.Receive( "get_antispam_tool", function()

	cl_PProtect.Settings.Antispamtools = net.ReadTable()
	local frm = cl_PProtect.addfrm( 250, 350, "Set antispamed Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Antispamtools, "pprotect_send_antispamed_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Antispamtools ) do

		frm:addchk( key, nil, cl_PProtect.Settings.Antispamtools[ key ], function( c ) cl_PProtect.Settings.Antispamtools[ key ] = c end )

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
			draw.RoundedBox( 0, 0, 0, Icon:GetWide(), Icon:GetTall(), Color( 200, 200, 200 ) )
		end

		frm:AddItem( Icon )

	end )

end )

-- BLOCKED TOOLS
net.Receive( "get_blocked_tool", function()

	cl_PProtect.Settings.Blockedtools = net.ReadTable()
	local frm = cl_PProtect.addfrm( 250, 350, "Set blocked Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Blockedtools, "pprotect_send_blocked_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Blockedtools ) do

		frm:addchk( key, nil, cl_PProtect.Settings.Blockedtools[ key ], function( c ) cl_PProtect.Settings.Blockedtools[ key ] = c end )

	end

end )



---------------------------
--  PROPPROTECTION MENU  --
---------------------------

function cl_PProtect.pp_menu( p )

	-- clear Panel
	p:ClearControls()

	-- update Panel
	if !cl_PProtect.pp_panel then
		cl_PProtect.pp_panel = p
	end

	-- check Admin
	if !LocalPlayer():IsSuperAdmin() then
		p:addlbl( "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- main Setttings
	p:addlbl( "General Settings:", true )
	p:addchk( "Enable PropProtection", nil, cl_PProtect.Settings.Propprotection[ "enabled" ], function( c ) cl_PProtect.Settings.Propprotection[ "enabled" ] = c end )
	
	if cl_PProtect.Settings.Propprotection[ "enabled" ] then

		-- General
		p:addchk( "Ignore SuperAdmins", nil, cl_PProtect.Settings.Propprotection[ "superadmins" ], function( c ) cl_PProtect.Settings.Propprotection[ "superadmins" ] = c end )
		p:addchk( "Ignore Admins", nil, cl_PProtect.Settings.Propprotection[ "admins" ], function( c ) cl_PProtect.Settings.Propprotection[ "admins" ] = c end )
		if cl_PProtect.Settings.Propprotection[ "admins" ] then
			p:addchk( "Admins can use SuperAdmins'-Props", "Touch, Tool, Use, ...", cl_PProtect.Settings.Propprotection[ "adminssuperadmins" ], function( c ) cl_PProtect.Settings.Propprotection[ "adminssuperadmins" ] = c end )
		end
		p:addchk( "Admins can use Cleanup-Menu", nil, cl_PProtect.Settings.Propprotection[ "adminscleanup" ], function( c ) cl_PProtect.Settings.Propprotection[ "adminscleanup" ] = c end )

		-- Protections
		p:addlbl( "\nProtection Settings:", true )
		p:addchk( "Use-Protection", nil, cl_PProtect.Settings.Propprotection[ "useprotection" ], function( c ) cl_PProtect.Settings.Propprotection[ "useprotection" ] = c end )
		p:addchk( "Reload-Protection", nil, cl_PProtect.Settings.Propprotection[ "reloadprotection" ], function( c ) cl_PProtect.Settings.Propprotection[ "reloadprotection" ] = c end )
		p:addchk( "Damage-Protection", nil, cl_PProtect.Settings.Propprotection[ "damageprotection" ], function( c ) cl_PProtect.Settings.Propprotection[ "damageprotection" ] = c end )
		p:addchk( "GravGun-Protection", nil, cl_PProtect.Settings.Propprotection[ "gravgunprotection" ], function( c ) cl_PProtect.Settings.Propprotection[ "gravgunprotection" ] = c end )
		p:addchk( "PropPickup-Protection", "Pick up props with 'use'-key", cl_PProtect.Settings.Propprotection[ "proppickup" ], function( c ) cl_PProtect.Settings.Propprotection[ "proppickup" ] = c end )

		-- Restrictions
		p:addlbl( "\nSpecial User-Restrictions:", true )
		p:addchk( "Allow Creator-Tool", "ie. spawning weapons with the toolgun", cl_PProtect.Settings.Propprotection[ "creatorprotection" ], function( c ) cl_PProtect.Settings.Propprotection[ "creatorprotection" ] = c end )
		p:addchk( "Allow Prop-Driving", "Allow users to drive props over the context menu (c-key)", cl_PProtect.Settings.Propprotection[ "propdriving" ], function( c ) cl_PProtect.Settings.Propprotection[ "propdriving" ] = c end )
		p:addchk( "Allow World-Props", "Allow users to physgun, toolgun, use, ... world props", cl_PProtect.Settings.Propprotection[ "worldprops" ], function( c ) cl_PProtect.Settings.Propprotection[ "worldprops" ] = c end )
		p:addchk( "Allow World-Buttons/Doors", "Allow users to press World-Buttons/Doors", cl_PProtect.Settings.Propprotection[ "worldbutton" ], function( c ) cl_PProtect.Settings.Propprotection[ "worldbutton" ] = c end )

		p:addlbl( "\nProp-Delete on Disconnect:", true )
		p:addchk( "Use Prop-Delete", nil, cl_PProtect.Settings.Propprotection[ "propdelete" ], function( c ) cl_PProtect.Settings.Propprotection[ "propdelete" ] = c end )

		-- Prop-Delete
		if cl_PProtect.Settings.Propprotection[ "propdelete" ] then
			p:addchk( "Keep admin's props", nil, cl_PProtect.Settings.Propprotection[ "adminsprops" ], function( c ) cl_PProtect.Settings.Propprotection[ "adminsprops" ] = c end )
			p:addsld( 5, 300, "Delay (sec.)", cl_PProtect.Settings.Propprotection[ "delay" ], "Propprotection", "delay", 0 )
		end

	end

	-- save Settings
	p:addbtn( "Save Settings", "pprotect_save_propprotection" )

end



------------------
--  BUDDY MENU  --
------------------

function cl_PProtect.b_menu( p )

	-- clear Panel
	p:ClearControls()

	-- update Panel
	if !cl_PProtect.b_panel then
		cl_PProtect.b_panel = p
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

	p:addlbl( "Add a new buddy:", true )

	local list_allplayers = p:addlvw( { "Name" } , function( selectedLine )

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

	-- Buddy Permissions
	table.foreach( buddy_permissions, function( key, permission )

		p:addchk( permission, nil, false, function( c ) newBuddy.permissions[ string.lower( permission ) ] = c end )

	end )

	-- add Buddy
	btn_addbuddy = p:addbtn( "Add selected buddy" , "", function() cl_PProtect.AddBuddy( newBuddy ) end )
	btn_addbuddy:SetDisabled( true )

	-- Buddy List
	p:addlbl( "Your Buddies:", true )
	local list_mybuddies = p:addlvw( { "Name", "Permission" } , function( selectedLine )

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

	-- delete Buddy
	btn_deletebuddy = p:addbtn( "Delete selected buddy" , "", function() cl_PProtect.DeleteBuddy( selectedBuddy ) end )
	btn_deletebuddy:SetDisabled( true )

end



--------------------
--  CLEANUP MENU  --
--------------------

function cl_PProtect.cu_menu( p )

	-- clear Panel
	RunConsoleCommand( "pprotect_request_newest_counts" )
	p:ClearControls()

	-- update Panel
	if !cl_PProtect.cu_panel then
		cl_PProtect.cu_panel = p
	end

	-- check Admin
	if cl_PProtect.Settings.Propprotection[ "adminscleanup" ] and !LocalPlayer():IsAdmin() and !LocalPlayer():IsSuperAdmin() then
		p:addlbl( "Sorry, you need to be an Admin to access the Cleanup-Menu!" )
		return
	elseif !cl_PProtect.Settings.Propprotection[ "adminscleanup" ] and !LocalPlayer():IsSuperAdmin() then
		p:addlbl( "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	function pprotect_write_cleanup_menu( global, players )

		p:addlbl( "Cleanup everything: (Including World Props)", true )
		p:addbtn( "Cleanup everything (" .. tostring( global ) .. " Props)", "pprotect_cleanup_map" )

		p:addlbl( "\nCleanup props of disconnected Players:", true )
		p:addbtn( "Cleanup all Props from disc. Players", "pprotect_cleanup_disconnected_player" )

		p:addlbl( "\nCleanup Player's props:", true )
		table.foreach( players, function( pl, c )
			p:addbtn( "Cleanup " .. pl:Nick() .. " (" .. tostring( c ) .. " props)", "pprotect_cleanup_player", { pl, tostring( c ) } )
		end )

	end

end



----------------------------
--  CLIENT SETTINGS MENU  --
----------------------------

function cl_PProtect.cs_menu( p )

	-- clear Panel
	p:ClearControls()

	-- update Panel
	if !cl_PProtect.cs_panel then
		cl_PProtect.cs_panel = p
	end

	p:addlbl( "Enable/Disable features:", true )
	p:addchk( "Use Owner-HUD", "Allows you to see the owner of a prop.", cl_PProtect.Settings.CSettings[ "ownerhud" ], function( c ) cl_PProtect.update_csetting( "ownerhud", c ) end )
	p:addchk( "FPP-Mode (Owner HUD)", "Owner will be shown under the crosshair", cl_PProtect.Settings.CSettings[ "fppmode" ], function( c ) cl_PProtect.update_csetting( "fppmode", c ) end )
	p:addchk( "Use Notifications", "Allows you to see incoming notifications. (right-bottom).", cl_PProtect.Settings.CSettings[ "notes" ], function( c ) cl_PProtect.update_csetting( "notes", c ) end )

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- Anti-Spam
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", cl_PProtect.as_menu )

	-- Prop-Protection
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", cl_PProtect.pp_menu )

	-- Buddy
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPBuddy", "Buddy", "", "", cl_PProtect.b_menu )

	-- Cleanup
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPCleanup", "Cleanup", "", "", cl_PProtect.cu_menu )
	
	-- Client-Settings
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPClientSettings", "Client Settings", "", "", cl_PProtect.cs_menu )

end
hook.Add( "PopulateToolMenu", "pprotect_make_menus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PProtect.UpdateMenus()
	
	-- Anti-Spam
	if cl_PProtect.as_panel then
		RunConsoleCommand( "pprotect_request_newest_settings", "antispam" )
	end
	
	-- Prop-Protection
	if cl_PProtect.pp_panel then
		RunConsoleCommand( "pprotect_request_newest_settings", "propprotection" )
	end

	-- Buddy
	if cl_PProtect.b_panel then
		cl_PProtect.b_menu( cl_PProtect.b_panel )
	end

	-- Cleanup
	if cl_PProtect.cu_panel then
		cl_PProtect.cu_menu( cl_PProtect.cu_panel )
	end

	-- Client-Settings
	if cl_PProtect.cs_panel then
		cl_PProtect.cs_menu( cl_PProtect.cs_panel )
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
		cl_PProtect.as_menu( cl_PProtect.as_panel )
	elseif settings_type == "propprotection" then
		cl_PProtect.pp_menu( cl_PProtect.pp_panel )
	end

end )

-- RECEIVE NEW PROP-COUNTS
net.Receive( "pprotect_new_counts", function()

	-- check Permissions
	if cl_PProtect.Settings.Propprotection[ "adminscleanup" ] then
		if !LocalPlayer():IsAdmin() and !LocalPlayer():IsSuperAdmin() then return end
	elseif !cl_PProtect.Settings.Propprotection[ "adminscleanup" ] then
		if !LocalPlayer():IsSuperAdmin() then return end
	end

	local counts = net.ReadTable()

	pprotect_write_cleanup_menu( counts[ "global" ], counts[ "players" ] )

end )
