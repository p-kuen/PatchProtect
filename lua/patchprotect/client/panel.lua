---------------------
--  ANTISPAM MENU  --
---------------------

function cl_PProtect.as_menu( p )

	-- clear Panel
	p:ClearControls()

	-- Main Settings
	p:addlbl( "General Settings:", true )
	p:addchk( "Enable AntiSpam", nil, cl_PProtect.Settings.Antispam[ "enabled" ], function( c ) cl_PProtect.Settings.Antispam[ "enabled" ] = c end )

	if cl_PProtect.Settings.Antispam[ "enabled" ] then

		-- General
		p:addchk( "Ignore Admins", nil, cl_PProtect.Settings.Antispam[ "admins" ], function( c ) cl_PProtect.Settings.Antispam[ "admins" ] = c end )
		p:addchk( "Admin-Alert Sound", nil, cl_PProtect.Settings.Antispam[ "alert" ], function( c ) cl_PProtect.Settings.Antispam[ "alert" ] = c end )

		-- Anti-Spam features
		p:addlbl( "\nEnable/Disable antispam features:", true )
		p:addchk( "Tool-AntiSpam", nil, cl_PProtect.Settings.Antispam[ "tool" ], function( c ) cl_PProtect.Settings.Antispam[ "tool" ] = c end )
		p:addchk( "Tool-Block", nil, cl_PProtect.Settings.Antispam[ "toolblock" ], function( c ) cl_PProtect.Settings.Antispam[ "toolblock" ] = c end )
		p:addchk( "Prop-Block", nil, cl_PProtect.Settings.Antispam[ "propblock" ], function( c ) cl_PProtect.Settings.Antispam[ "propblock" ] = c end )
		p:addchk( "Entity-Block", nil, cl_PProtect.Settings.Antispam[ "entblock" ], function( c ) cl_PProtect.Settings.Antispam[ "entblock" ] = c end )
		p:addchk( "Prop-In-Prop", nil, cl_PProtect.Settings.Antispam[ "propinprop" ], function( c ) cl_PProtect.Settings.Antispam[ "propinprop" ] = c end )

		-- Tool Protection
		if cl_PProtect.Settings.Antispam[ "tool" ] then
			p:addbtn( "Set antispamed Tools", "pprotect_request_tools", { "antispam" } )
		end

		-- Tool Block
		if cl_PProtect.Settings.Antispam[ "toolblock" ] then
			p:addbtn( "Set blocked Tools", "pprotect_request_tools", { "blocked" } )
		end

		-- Prop Block
		if cl_PProtect.Settings.Antispam[ "propblock" ] then
			p:addbtn( "Set blocked Props", "pprotect_request_ents", { "props" } )
		end

		-- Ent Block
		if cl_PProtect.Settings.Antispam[ "entblock" ] then
			p:addbtn( "Set blocked Entities", "pprotect_request_ents", { "ents" } )
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
	p:addbtn( "Save Settings", "pprotect_save", { "Antispam" } )

end



--------------
--  FRAMES  --
--------------

cl_PProtect.Blocked = { props = {}, ents = {}, atools = {}, btools = {} }

-- ANTISPAMED/BLOCKED TOOLS
net.Receive( "pprotect_send_tools", function()

	local t = net.ReadString()
	local typ = "antispamed"
	if t == "btools" then typ = "blocked" end
	cl_PProtect.Blocked[ t ] = net.ReadTable()
	local frm = cl_PProtect.addfrm( 250, 350, "Set " .. typ .. " Tools:", false, true, false, "Save Tools", { t, cl_PProtect.Blocked[ t ] }, "pprotect_save_tools" )

	for key, value in SortedPairs( cl_PProtect.Blocked[ t ] ) do
		frm:addchk( key, nil, cl_PProtect.Blocked[ t ][ key ], function( c ) cl_PProtect.Blocked[ t ][ key ] = c end )
	end

end )

-- BLOCKED PROPS/ENTS
net.Receive( "pprotect_send_ents", function()

	local typ = net.ReadString()
	cl_PProtect.Blocked[ typ ] = net.ReadTable()
	local frm = cl_PProtect.addfrm( 800, 600, "Set blocked " .. typ .. ":", false, true, true, "Save " .. typ, { typ, cl_PProtect.Blocked[ typ ] }, "pprotect_save_ents" )

	table.foreach( cl_PProtect.Blocked[ typ ], function( name, model )

		frm:addico( model, name, function( icon )
			local menu = DermaMenu()
			menu:AddOption( "Remove from Blocked-List", function() cl_PProtect.Blocked[ typ ][ name ] = nil icon:Remove() frm:InvalidateLayout() end )
			menu:Open()
		end )

	end )

end )



---------------------------
--  PROPPROTECTION MENU  --
---------------------------

function cl_PProtect.pp_menu( p )

	-- clear Panel
	p:ClearControls()

	-- Main Settings
	p:addlbl( "General Settings:", true )
	p:addchk( "Enable PropProtection", nil, cl_PProtect.Settings.Propprotection[ "enabled" ], function( c ) cl_PProtect.Settings.Propprotection[ "enabled" ] = c end )
	
	if cl_PProtect.Settings.Propprotection[ "enabled" ] then

		-- General
		p:addchk( "Ignore SuperAdmins", nil, cl_PProtect.Settings.Propprotection[ "superadmins" ], function( c ) cl_PProtect.Settings.Propprotection[ "superadmins" ] = c end )
		p:addchk( "Ignore Admins", nil, cl_PProtect.Settings.Propprotection[ "admins" ], function( c ) cl_PProtect.Settings.Propprotection[ "admins" ] = c end )
		p:addchk( "Admins can use Cleanup-Menu", nil, cl_PProtect.Settings.Propprotection[ "adminscleanup" ], function( c ) cl_PProtect.Settings.Propprotection[ "adminscleanup" ] = c end )

		-- Protections
		p:addlbl( "\nProtection Settings:", true )
		p:addchk( "Use-Protection", nil, cl_PProtect.Settings.Propprotection[ "use" ], function( c ) cl_PProtect.Settings.Propprotection[ "use" ] = c end )
		p:addchk( "Reload-Protection", nil, cl_PProtect.Settings.Propprotection[ "reload" ], function( c ) cl_PProtect.Settings.Propprotection[ "reload" ] = c end )
		p:addchk( "Damage-Protection", nil, cl_PProtect.Settings.Propprotection[ "damage" ], function( c ) cl_PProtect.Settings.Propprotection[ "damage" ] = c end )

		-- Special damage protection
		if cl_PProtect.Settings.Propprotection[ "damage" ] then
			p:addchk( "In-Vehicle-Damage-Protection", "Restrict players to kill other players, while sitting in a vehicle", cl_PProtect.Settings.Propprotection[ "damageinvehicle" ], function( c ) cl_PProtect.Settings.Propprotection[ "damageinvehicle" ] = c end )
		end

		p:addchk( "GravGun-Protection", nil, cl_PProtect.Settings.Propprotection[ "gravgun" ], function( c ) cl_PProtect.Settings.Propprotection[ "gravgun" ] = c end )
		p:addchk( "PropPickup-Protection", "Pick up props with 'use'-key", cl_PProtect.Settings.Propprotection[ "proppickup" ], function( c ) cl_PProtect.Settings.Propprotection[ "proppickup" ] = c end )

		-- Restrictions
		p:addlbl( "\nSpecial User-Restrictions:", true )
		p:addchk( "Allow Creator-Tool", "ie. spawning weapons with the toolgun", cl_PProtect.Settings.Propprotection[ "creator" ], function( c ) cl_PProtect.Settings.Propprotection[ "creator" ] = c end )
		p:addchk( "Allow Prop-Driving", "Allow users to drive props over the context menu (c-key)", cl_PProtect.Settings.Propprotection[ "propdriving" ], function( c ) cl_PProtect.Settings.Propprotection[ "propdriving" ] = c end )
		p:addchk( "Allow World-Props", "Allow users to physgun, toolgun, use, ... world props", cl_PProtect.Settings.Propprotection[ "worldprops" ], function( c ) cl_PProtect.Settings.Propprotection[ "worldprops" ] = c end )
		p:addchk( "Allow World-Buttons/Doors", "Allow users to press World-Buttons/Doors", cl_PProtect.Settings.Propprotection[ "worldbutton" ], function( c ) cl_PProtect.Settings.Propprotection[ "worldbutton" ] = c end )
		p:addchk( "Allow No-Owner-Props", "Allow users to use/pickup/gravgun props with no owner", cl_PProtect.Settings.Propprotection[ "noowner" ], function( c ) cl_PProtect.Settings.Propprotection[ "noowner" ] = c end )

		p:addlbl( "\nProp-Delete on Disconnect:", true )
		p:addchk( "Use Prop-Delete", nil, cl_PProtect.Settings.Propprotection[ "propdelete" ], function( c ) cl_PProtect.Settings.Propprotection[ "propdelete" ] = c end )

		-- Prop-Delete
		if cl_PProtect.Settings.Propprotection[ "propdelete" ] then
			p:addchk( "Keep admin's props", nil, cl_PProtect.Settings.Propprotection[ "adminsprops" ], function( c ) cl_PProtect.Settings.Propprotection[ "adminsprops" ] = c end )
			p:addsld( 5, 300, "Delay (sec.)", cl_PProtect.Settings.Propprotection[ "delay" ], "Propprotection", "delay", 0 )
		end

	end

	-- save Settings
	p:addbtn( "Save Settings", "pprotect_save", { "Propprotection" } )

end



------------------
--  BUDDY MENU  --
------------------

function cl_PProtect.b_menu( p )

	-- clear Panel
	p:ClearControls()
	
	-- Variables and Tables
	local buddy_permissions, newBuddy = { "Use", "PhysGun", "ToolGun", "Damage", "Property" }, { player = nil, permissions = {} }
	local selectedBuddy, me, btn_addbuddy, btn_deletebuddy = { nick = nil, uniqueid = nil }, LocalPlayer()

	p:addlbl( "Add a new buddy:", true )

	local list_allplayers = p:addlvw( { "Name" } , function( line )
		btn_addbuddy:SetDisabled( false )
		newBuddy.player = line.player
	end )

	table.foreach( player.GetAll(), function( key, ply )

		if ply == me or !cl_PProtect.Buddies then return end

		local new = true
		table.foreach( cl_PProtect.Buddies, function( key, buddy )
			if ply:UniqueID() == buddy.uniqueid then new = false end
		end )
		if !new then return end

		local newline = list_allplayers:AddLine( ply:Nick() )
		newline.player = ply

	end )

	-- Buddy Permissions
	table.foreach( buddy_permissions, function( key, permission )
		p:addchk( permission, nil, false, function( c ) newBuddy.permissions[ string.lower( permission ) ] = c end )
	end )

	-- add Buddy
	btn_addbuddy = p:addbtn( "Add selected buddy" , "", function() cl_PProtect.addBuddy( newBuddy ) end )
	btn_addbuddy:SetDisabled( true )

	-- Buddy List
	p:addlbl( "Your Buddies:", true )
	local list_mybuddies = p:addlvw( { "Name", "Permission" } , function( selectedLine )
		btn_deletebuddy:SetDisabled( false )
		selectedBuddy.nick = selectedLine.nick
		selectedBuddy.uniqueid = selectedLine.uniqueid
	end )

	if cl_PProtect.Buddies then

		table.foreach( cl_PProtect.Buddies, function( key, buddy )

			local line = list_mybuddies:AddLine( buddy.nick, buddy.permission )
			line.nick = buddy.nick
			line.uniqueid = buddy.uniqueid

		end )

	end

	-- delete Buddy
	btn_deletebuddy = p:addbtn( "Delete selected buddy" , "", function() cl_PProtect.deleteBuddy( selectedBuddy ) end )
	btn_deletebuddy:SetDisabled( true )

end



--------------------
--  CLEANUP MENU  --
--------------------

local o_global, o_players = 0, {}
function cl_PProtect.cu_menu( p )

	-- clear Panel
	p:ClearControls()

	p:addlbl( "Cleanup everything:", true )
	p:addbtn( "Cleanup everything (" .. tostring( o_global ) .. " Props)", "pprotect_cleanup_map" )

	p:addlbl( "\nCleanup props from disconnected players:", true )
	p:addbtn( "Cleanup all Props from disc. Players", "pprotect_cleanup_disconnected_player" )

	if o_global == 0 then return end
	p:addlbl( "\nCleanup player's props:", true )
	table.foreach( o_players, function( pl, c )
		p:addbtn( "Cleanup " .. pl:Nick() .. " (" .. tostring( c ) .. " props)", "pprotect_cleanup_player", { pl, tostring( c ) } )
	end )

end



----------------------------
--  CLIENT SETTINGS MENU  --
----------------------------

function cl_PProtect.cs_menu( p )

	-- clear Panel
	p:ClearControls()

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
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", function( p ) cl_PProtect.UpdateMenus( "as", p ) end )

	-- Prop-Protection
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", function( p ) cl_PProtect.UpdateMenus( "pp", p ) end )

	-- Buddy
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPBuddy", "Buddy", "", "", function( p ) cl_PProtect.UpdateMenus( "b", p ) end )

	-- Cleanup
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPCleanup", "Cleanup", "", "", function( p ) cl_PProtect.UpdateMenus( "cu", p ) end )
	
	-- Client-Settings
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPClientSettings", "Client Settings", "", "", function( p ) cl_PProtect.UpdateMenus( "cs", p ) end )

end
hook.Add( "PopulateToolMenu", "pprotect_make_menus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

local function showErrorMessage( p, msg )
	p:ClearControls()
	p:addlbl( msg )
end

local pans = {}
function cl_PProtect.UpdateMenus( p_type, panel )

	-- add Panel
	if p_type and !pans[ p_type ] then pans[ p_type ] = panel end

	-- load Panel
	table.foreach( pans, function( t, p )

		if t == "as" or t == "pp" then
			if LocalPlayer():IsSuperAdmin() then RunConsoleCommand( "pprotect_request_new_settings", t ) else showErrorMessage( pans[ t ], "Sorry, you need to be a Super-Admin to change\nthe settings!" ) end
		elseif t == "cu" then
			if LocalPlayer():IsSuperAdmin() then RunConsoleCommand( "pprotect_request_new_counts" )
			elseif LocalPlayer():IsAdmin() and cl_PProtect.Settings.Propprotection[ "adminscleanup" ] then RunConsoleCommand( "pprotect_request_new_counts" )
			else showErrorMessage( pans[ t ], "Sorry, you need to be a Admin/SuperAdmin to change\nthe settings!" ) end
		else
			cl_PProtect[ t .. "_menu" ]( pans[ t ] )
		end

	end )

end
hook.Add( "SpawnMenuOpen", "pprotect_update_menus", cl_PProtect.UpdateMenus )



---------------
--  NETWORK  --
---------------

-- RECEIVE NEW SETTINGS
net.Receive( "pprotect_new_settings", function()
	
	local settings = net.ReadTable()
	local typ = net.ReadString()

	cl_PProtect.Settings.Antispam = settings.AntiSpam
	cl_PProtect.Settings.Propprotection = settings.PropProtection

	if typ != "as" and typ != "pp" then return end
	cl_PProtect[ typ .. "_menu" ]( pans[ typ ] )

end )

-- RECEIVE NEW PROP-COUNTS
net.Receive( "pprotect_new_counts", function()

	local counts = net.ReadTable()

	-- set new Count-Data
	o_global = counts.global
	o_players = counts.players

	-- create new Cleanup-Panel
	cl_PProtect.cu_menu( pans.cu )

end )
