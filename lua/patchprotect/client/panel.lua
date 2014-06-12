----------------------
--  ANTISPAM PANEL  --
----------------------

function cl_PProtect.ASMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE MENU
	if !cl_PProtect.ASCPanel then
		cl_PProtect.ASCPanel = Panel
	end

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- MAIN SETTINGS
	cl_PProtect.addlbl( Panel, "General Settings:" )
	cl_PProtect.addchk( Panel, "Enable AntiSpam", "antispam", "enabled" )

	if cl_PProtect.Settings.Antispam[ "enabled" ] == 1 then

		cl_PProtect.addchk( Panel, "Ignore Admins (no SuperAdmins)", "antispam", "admins" )

		cl_PProtect.addlbl( Panel, "\nEnable/Disable antispam features:" )
		cl_PProtect.addchk( Panel, "Tool-AntiSpam", "antispam", "toolprotection" )
		cl_PProtect.addchk( Panel, "Tool-Block", "antispam", "toolblock" )
		cl_PProtect.addchk( Panel, "Prop-Block", "antispam", "propblock" )

		--Tool Protection
		if cl_PProtect.Settings.Antispam[ "toolprotection" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set antispamed Tools", "pprotect_antispamtools" )
		end

		--Tool Block
		if cl_PProtect.Settings.Antispam[ "toolblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Tools", "pprotect_blockedtools" )
		end

		--Prop Block
		if cl_PProtect.Settings.Antispam[ "propblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Props", "pprotect_blockedprops" )
		end

		--Cooldown/Spamaction
		cl_PProtect.addlbl( Panel, "\nHow many seconds to wait, till the next prop-spawn/tool-fire:" )
		cl_PProtect.addsld( Panel, 0, 10, "Cooldown (Seconds)", "antispam", cl_PProtect.Settings.Antispam[ "cooldown" ], 1, "cooldown" )
		cl_PProtect.addlbl( Panel, "How many props, till admins and superadmins get informed:" )
		cl_PProtect.addsld( Panel, 0, 40, "Amount", "antispam", cl_PProtect.Settings.Antispam[ "spam" ], 0, "spam" )
		cl_PProtect.addlbl( Panel, "What should happen, if the player topped the spam-limit:" )
		cl_PProtect.addcmb( Panel, { "Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]] }, "spamaction", cl_PProtect.Settings.Antispam[ "spamaction" ] )

		if cl_PProtect.Settings.Antispam[ "spamaction" ] == 4 then
			cl_PProtect.addsld( Panel, 0, 60, "Ban (Minutes)", "antispam", cl_PProtect.Settings.Antispam[ "bantime" ], 0, "bantime" )
		elseif cl_PProtect.Settings.Antispam[ "spamaction" ] == 5 then
			cl_PProtect.addlbl( Panel, "This doesn't work yet, sorry!" )
			--cl_PProtect.addtext()
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "pprotect_save_antispam" )

end



--------------
--  FRAMES  --
--------------

-- ANTISPAMED TOOLS
net.Receive( "get_antispam_tool", function()

	cl_PProtect.Settings.Antispamtools = net.ReadTable()

	tsFrm = cl_PProtect.addframe( 250, 350, "Set antispamed Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Antispamtools, "pprotect_send_antispamed_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Antispamtools ) do

		cl_PProtect.addchk( tsFrm, key, "antispamtools", key )

	end

end )

-- BLOCKED PROPS
net.Receive( "get_blocked_prop", function()

	cl_PProtect.Settings.Blockedprops = net.ReadTable()

	psFrm = cl_PProtect.addframe( 800, 600, "Set blocked Props:", false, false, true, "Save Props", cl_PProtect.Settings.Blockedprops, "pprotect_send_blocked_props" )

	table.foreach( cl_PProtect.Settings.Blockedprops, function( key, value )

		local Icon = vgui.Create( "SpawnIcon", psFrm )
		Icon:SetModel( value )

		Icon.DoClick = function()

			local menu = DermaMenu()
			menu:AddOption( "Remove from blocked Props", function()
				table.RemoveByValue( cl_PProtect.Settings.Blockedprops, value )
				Icon:Remove()
				psFrm:InvalidateLayout()
			end )
			menu:Open()

		end

		function Icon:Paint()

			draw.RoundedBox( 4, 0, 0, Icon:GetWide(), Icon:GetTall(), Color( 200, 200, 200, 255 ) )
			draw.RoundedBox( 4, 3, 3, Icon:GetWide() - 6, Icon:GetTall() - 6, Color( 240, 240, 240, 255 ) )
			
		end

		psFrm:AddItem( Icon )

	end )

	if table.Count( cl_PProtect.Settings.Blockedprops ) == 0 then
		cl_PProtect.addlbl( psFrm, "Nothing here..." )
	end

end )

-- BLOCKED TOOLS
net.Receive( "get_blocked_tool", function()

	cl_PProtect.Settings.Blockedtools = net.ReadTable()

	tsFrm = cl_PProtect.addframe( 250, 350, "Set blocked Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.Blockedtools, "pprotect_send_blocked_tools" )

	for key, value in SortedPairs( cl_PProtect.Settings.Blockedtools ) do

		cl_PProtect.addchk( tsFrm, key, "blockedtools", key )

	end

end )



----------------------------
--  PROPPROTECTION PANEL  --
----------------------------

function cl_PProtect.PPMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE MENU
	if !cl_PProtect.PPCPanel then
		cl_PProtect.PPCPanel = Panel
	end

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- MAIN SETTINGS
	cl_PProtect.addlbl( Panel, "General Settings:" )
	cl_PProtect.addchk( Panel, "Enable PropProtection", "propprotection", "enabled" )
	
	if cl_PProtect.Settings.Propprotection[ "enabled" ] == 1 then

		cl_PProtect.addchk( Panel, "Ignore Admins (no SuperAdmins)", "propprotection", "admins" )
		cl_PProtect.addchk( Panel, "Allow Admins to use the Cleanup-Panel", "propprotection", "adminscleanup" )
		cl_PProtect.addchk( Panel, "FPP-Mode", "propprotection", "fppmode", "Owner will be shown under the crosshair" )

		cl_PProtect.addlbl( Panel, "\nProtection Settings:", "panel" )
		cl_PProtect.addchk( Panel, "Use-Protection", "propprotection", "useprotection" )
		cl_PProtect.addchk( Panel, "Reload-Protection", "propprotection", "reloadprotection" )
		cl_PProtect.addchk( Panel, "Damage-Protection", "propprotection", "damageprotection" )
		cl_PProtect.addchk( Panel, "GravGun-Protection", "propprotection", "gravgunprotection" )
		cl_PProtect.addchk( Panel, "PlayerPickup-Protection", "propprotection", "playerpickup" )
		cl_PProtect.addchk( Panel, "PropPickup-Protection", "propprotection", "proppickup", "Pick up props with 'use'-key" )

		cl_PProtect.addlbl( Panel, "\nSpecial User-Restrictions:", "panel" )
		cl_PProtect.addchk( Panel, "Allow Creator-Tool", "propprotection", "creatorprotection", "ie. Spawning weapons with the toolgun" )
		cl_PProtect.addchk( Panel, "Allow Prop-Driving", "propprotection", "propdriving", "Allow Users to drive props over the context menu (c-key)" )
		cl_PProtect.addchk( Panel, "Allow World Props", "propprotection", "worldprops", "Physgun, Toolgun, Use, ..." )
		cl_PProtect.addchk( Panel, "Allow World Buttons/Doors", "propprotection", "worldbutton", "Allow Users to press World-Buttons/Doors" )

		cl_PProtect.addlbl( Panel, "\nProp-Delete on Disconnect:", "panel" )
		cl_PProtect.addchk( Panel, "Use Prop-Delete", "propprotection", "propdelete" )

		--Prop Delete
		if cl_PProtect.Settings.Propprotection[ "propdelete" ] == 1 then
			cl_PProtect.addchk( Panel, "Keep Admin-Props", "propprotection", "adminprops" )
			cl_PProtect.addsld( Panel, 5, 300, "Delay (Seconds)", "propprotection", cl_PProtect.Settings.Propprotection[ "delay" ], 0, "delay" )
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "pprotect_save_propprotection" )

end



------------------
--  BUDDY MENU  --
------------------

function cl_PProtect.BMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE MENU
	if !cl_PProtect.BCPanel then
		cl_PProtect.BCPanel = Panel
	end
	
	-- BUDDY PERMISSIONS
	local buddy_permissions = {

		"Use",
		"PhysGun",
		"ToolGun",
		"Damage",
		"Property"
	
	}

	-- BUDDY CONTROLS
	cl_PProtect.addlbl( Panel, "Your Buddies:" )
	cl_PProtect.addlvw( Panel, { "Name", "Permission", "SteamID", "UniqueID" } , "my_buddies" )
	cl_PProtect.addbtn( Panel, "Delete selected buddy" , "", function() cl_PProtect.DeleteBuddy( LocalPlayer() ) end )
	
	cl_PProtect.addlbl( Panel, "\nAdd a new buddy:" )
	cl_PProtect.addlvw( Panel, { "Name", "ID" } , "all_players" )
	
	table.foreach( buddy_permissions, function( key, value )
		cl_PProtect.addchk( Panel, value, "buddy", string.lower( value ) )
	end )
	
	cl_PProtect.addbtn( Panel, "Add selected buddy" , "", function() cl_PProtect.AddBuddy( LocalPlayer() ) end )

	cl_PProtect.addlbl( Panel, "\nReset Buddies:" )
	cl_PProtect.addbtn( Panel, "Clear Buddy-List" , "", function() cl_PProtect.resetBuddySettings() end )

end



--------------------
--  CLEANUP MENU  --
--------------------

function cl_PProtect.CUMenu( Panel )

	-- DELETE CONTROLS
	RunConsoleCommand( "pprotect_request_newest_counts" )
	Panel:ClearControls()

	-- UPDATE MENU
	if !cl_PProtect.CUCPanel then
		cl_PProtect.CUCPanel = Panel
	end

	-- CHECK ADMIN
	if cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 1 then
		if !LocalPlayer():IsAdmin() and !LocalPlayer():IsSuperAdmin() then
			cl_PProtect.addlbl( Panel, "Sorry, you need to be an Admin to change the settings!" )
			return
		end
	elseif cl_PProtect.Settings.Propprotection[ "adminscleanup" ] == 0 then
		if !LocalPlayer():IsSuperAdmin() then
			cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
			return
		end
	end

	function pprotect_write_cleanup_menu( global, players )

		-- CLEANUP CONTROLS
		cl_PProtect.addlbl( Panel, "Cleanup everything: (Including World Props)" )
		cl_PProtect.addbtn( Panel, "Cleanup everything (" .. tostring( global ) .. " Props)", "pprotect_cleanup_map" )

		cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:" )
		cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "pprotect_cleanup_disconnected_player" )

		cl_PProtect.addlbl( Panel, "\nCleanup Player's props:", "panel" )
		table.foreach( players, function( p, c )
			cl_PProtect.addbtn( Panel, "Cleanup " .. p:Nick() .."  (" .. tostring( c ) .. " Props)", "pprotect_cleanup_player", { p:Nick(), tostring( c ) } )
		end )

	end

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- ANTISPAM
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", cl_PProtect.ASMenu )

	-- PROP PROTECTION
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", cl_PProtect.PPMenu )

	-- CLEANUP
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPClientCleanup", "Cleanup", "", "", cl_PProtect.CUMenu )
	
	-- BUDDY
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPBuddyManager", "Buddy", "", "", cl_PProtect.BMenu )

end
hook.Add( "PopulateToolMenu", "pprotect_make_menus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PProtect.UpdateMenus()
	
	-- ANTISPAM
	if cl_PProtect.ASCPanel then
		RunConsoleCommand( "pprotect_request_newest_settings", "antispam" )
	end
	
	-- PROP PROTECTION
	if cl_PProtect.PPCPanel then
		RunConsoleCommand( "pprotect_request_newest_settings", "propprotection" )
	end

	-- CLEANUP
	if cl_PProtect.CUCPanel then
		cl_PProtect.CUMenu( cl_PProtect.CUCPanel )
	end

	-- BUDDY
	if cl_PProtect.BCPanel then
		cl_PProtect.BMenu( cl_PProtect.BCPanel )
	end

end
hook.Add( "SpawnMenuOpen", "pprotect_update_menus", cl_PProtect.UpdateMenus )



------------------------
--  GET NEW SETTINGS  --
------------------------

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
