----------------------
--  ANTISPAM PANEL  --
----------------------

function cl_PProtect.ASMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if not LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- UPDATE PANEL
	if !cl_PProtect.ASCPanel then
		cl_PProtect.ASCPanel = Panel
	end

	-- MAIN SETTINGS
	cl_PProtect.addlbl( Panel, "Main switch:" )
	cl_PProtect.addchk( Panel, "Enable AntiSpam", "antispam", "enabled" )

	if cl_PProtect.Settings.AntiSpam[ "enabled" ] == 1 then

		cl_PProtect.addlbl( Panel, "\nEnable/Disable antispam features:" )
		cl_PProtect.addchk( Panel, "Ignore Admins", "antispam", "admins" )
		cl_PProtect.addchk( Panel, "Tool-AntiSpam", "antispam", "toolprotection" )
		cl_PProtect.addchk( Panel, "Tool-Block", "antispam", "toolblock" )
		cl_PProtect.addchk( Panel, "Prop-Block", "antispam", "propblock" )

		--Tool Protection
		if cl_PProtect.Settings.AntiSpam[ "toolprotection" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set antispamed Tools", "open_antispam_tool" )
		end

		--Tool Block
		if cl_PProtect.Settings.AntiSpam[ "toolblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Tools", "open_blocked_tool" )
		end

		--Prop Block
		if cl_PProtect.Settings.AntiSpam[ "propblock" ] == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Props", "open_blocked_prop" )
		end

		--Cooldown/Spamaction
		cl_PProtect.addlbl( Panel, "\nHow many seconds to wait, till the next prop-spawn/tool-fire:" )
		cl_PProtect.addsld( Panel, 0, 10, "Cooldown (Seconds)", "antispam", cl_PProtect.Settings.AntiSpam[ "cooldown" ], 1, "cooldown" )
		cl_PProtect.addlbl( Panel, "How many props, till admins and superadmins get informed:" )
		cl_PProtect.addsld( Panel, 0, 40, "Amount", "antispam", cl_PProtect.Settings.AntiSpam[ "spam" ], 0, "spam" )
		cl_PProtect.addlbl( Panel, "What should happen, if the player topped the spam-limit:" )
		cl_PProtect.addcmb( Panel, { "Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]] }, "spamaction", cl_PProtect.Settings.AntiSpam[ "spamaction" ] )

		if cl_PProtect.Settings.AntiSpam[ "spamaction" ] == 4 then
			cl_PProtect.addsld( Panel, 0, 60, "Ban (Minutes)", "antispam", cl_PProtect.Settings.AntiSpam[ "bantime" ], 0, "bantime" )
		elseif cl_PProtect.Settings.AntiSpam[ "spamaction" ] == 5 then
			cl_PProtect.addlbl( Panel, "This doesn't work yet, sorry!" )
			--cl_PProtect.addtext( saCat, GetConVarString( "PProtect_AS_concommand" ) )
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "save_antispam_settings", cl_PProtect.Settings.AntiSpam )

end



--------------
--  FRAMES  --
--------------

-- ANTISPAMED TOOLS
net.Receive( "get_antispam_tool", function()

	cl_PProtect.Settings.AntiSpamTools = net.ReadTable()

	tsFrm = cl_PProtect.addframe( 250, 350, "Set antispamed Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.AntiSpamTools, "send_antispam_tool" )

	for key, value in SortedPairs( cl_PProtect.Settings.AntiSpamTools ) do

		cl_PProtect.addchk( tsFrm, key, "antispamtools", key )

	end

end )

-- BLOCKED PROPS
net.Receive( "get_blocked_prop", function()

	cl_PProtect.Settings.BlockedProps = net.ReadTable()

	psFrm = cl_PProtect.addframe( 800, 600, "Set blocked Props:", false, false, true, "Save Props", cl_PProtect.Settings.BlockedProps, "send_blocked_prop" )

	table.foreach( cl_PProtect.Settings.BlockedProps, function( key, value )

		local Icon = vgui.Create( "SpawnIcon", psFrm )
		Icon:SetModel( value )

		Icon.DoClick = function()

			local menu = DermaMenu()
			menu:AddOption( "Remove from blocked Props", function()
				table.RemoveByValue( cl_PProtect.Settings.BlockedProps, value )
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

	if table.Count( cl_PProtect.Settings.BlockedProps ) == 0 then
		cl_PProtect.addlbl( psFrm, "Nothing here..." )
	end

end )

-- BLOCKED TOOLS
net.Receive( "get_blocked_tool", function()

	cl_PProtect.Settings.BlockedTools = net.ReadTable()

	tsFrm = cl_PProtect.addframe( 250, 350, "Set blocked Tools:", false, true, false, "Save Tools", cl_PProtect.Settings.BlockedTools, "send_blocked_tool" )

	for key, value in SortedPairs( cl_PProtect.Settings.BlockedTools ) do

		cl_PProtect.addchk( tsFrm, key, "blockedtools", key )

	end

end )



----------------------------
--  PROPPROTECTION PANEL  --
----------------------------

function cl_PProtect.PPMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- UPDATE PANEL
	if not cl_PProtect.PPCPanel then
		cl_PProtect.PPCPanel = Panel
	end

	-- MAIN SETTINGS
	cl_PProtect.addlbl( Panel, "Main switch:" )
	cl_PProtect.addchk( Panel, "Enable PropProtection", "propprotection", "enabled" )

	if cl_PProtect.Settings.PropProtection[ "enabled" ] == 1 then

		cl_PProtect.addlbl( Panel, "\nProtection Settings:", "panel" )
		cl_PProtect.addchk( Panel, "Ignore Admins", "propprotection", "admins" )
		cl_PProtect.addchk( Panel, "Use-Protection", "propprotection", "useprotection" )
		cl_PProtect.addchk( Panel, "Reload-Protection", "propprotection", "reloadprotection" )
		cl_PProtect.addchk( Panel, "Damage-Protection", "propprotection", "damageprotection" )
		cl_PProtect.addchk( Panel, "GravGun-Protection", "propprotection", "gravgunprotection" )

		cl_PProtect.addlbl( Panel, "\nSpecial Restrictions:", "panel" )
		cl_PProtect.addchk( Panel, "Block 'Creator'-Tool (e.g.: Spawn Weapons with Toolgun)", "propprotection", "creatorprotection" )
		cl_PProtect.addchk( Panel, "Allow Prop-Driving for Non-Admins", "propprotection", "propdriving" )

		cl_PProtect.addlbl( Panel, "\nProp-Delete on Disconnect:", "panel" )
		cl_PProtect.addchk( Panel, "Use Prop-Delete", "propprotection", "propdelete" )

		--Prop Delete
		if cl_PProtect.Settings.PropProtection[ "propdelete" ] == 1 then
			cl_PProtect.addchk( Panel, "Keep Admin-Props", "propprotection", "adminprops" )
			cl_PProtect.addsld( Panel, 5, 300, "Delay (Seconds)", "propprotection", cl_PProtect.Settings.PropProtection[ "delay" ], 0, "delay" )
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "save_propprotection_settings", cl_PProtect.Settings.PropProtection )

end



------------------
--  BUDDY MENU  --
------------------

function cl_PProtect.BMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- UPDATE PANELS
	if not cl_PProtect.BCPanel then
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
	cl_PProtect.addbtn( Panel, "Delete selected buddy" , "delete_buddy" )
	
	cl_PProtect.addlbl( Panel, "\nAdd a new buddy:" )
	cl_PProtect.addlvw( Panel, { "Name", "ID" } , "all_players" )
	
	table.foreach( buddy_permissions, function( key, value )
		cl_PProtect.addchk( Panel, value, "buddy", string.lower( value ) )
	end )
	
	cl_PProtect.addbtn( Panel, "Add selected buddy" , "add_buddy" )

end



--------------------
--  CLEANUP MENU  --
--------------------

function cl_PProtect.CUMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		return
	end

	-- UPDATE PANELS
	if not cl_PProtect.CUCPanel then
		cl_PProtect.CUCPanel = Panel
	end

	local global_count = 0
	table.foreach( ents.GetAll(), function( key, value )
		if value:IsValid() and value:GetClass() == "prop_physics" then
			global_count = global_count + 1
		end
	end )

	-- CLEANUP CONTROLS
	cl_PProtect.addlbl( Panel, "Cleanup everything: (Including World Props)" )
	cl_PProtect.addbtn( Panel, "Cleanup everything (" .. tostring( global_count ) .. " Props)", "cleanup_map" )

	cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:" )
	cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "cleanup_disconnected_player" )

	cl_PProtect.addlbl( Panel, "\nCleanup Player's props:", "panel" )
		
	net.Start( "get_player_props_count" )
		net.WriteString( "value" )
	net.SendToServer()

	net.Receive( "send_player_props_count", function()

		local allents = net.ReadTable()

		table.foreach( allents, function( key, value )
			cl_PProtect.addbtn( Panel, "Cleanup " .. tostring( key ) .."  (" .. tostring( value ) .. " Props)", "cleanup_player", { tostring( key ), tostring( value ) } )
		end )
	
	end )

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
hook.Add( "PopulateToolMenu", "PProtectmakeMenus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PProtect.UpdateMenus()
	
	-- ANTISPAM
	if cl_PProtect.ASCPanel then
		RunConsoleCommand( "request_newest_settings", "antispam" )
	end
	
	-- PROP PROTECTION
	if cl_PProtect.PPCPanel then
		RunConsoleCommand( "request_newest_settings", "propprotection" )
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
hook.Add( "SpawnMenuOpen", "PProtectMenus", cl_PProtect.UpdateMenus )



net.Receive( "new_client_settings", function()
	
	local settings = net.ReadTable()
	local settings_type = net.ReadString()

	cl_PProtect.Settings.AntiSpam = settings[ "AntiSpam" ]
	cl_PProtect.Settings.PropProtection = settings[ "PropProtection" ]

	if settings_type == "antispam" then
		cl_PProtect.ASMenu( cl_PProtect.ASCPanel )
	elseif settings_type == "propprotection" then
		cl_PProtect.PPMenu( cl_PProtect.PPCPanel )
	end

end )