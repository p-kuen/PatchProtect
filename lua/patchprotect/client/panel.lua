function cl_PProtect.ASMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if not LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "Sorry, you need to be a Super-Admin to change the settings!" )
		print("nosuperadmin!")
		return
	end

	-- UPDATE PANEL
	if !cl_PProtect.ASCPanel then
		cl_PProtect.ASCPanel = Panel
	end

	-- MAIN SETTINGS
	cl_PProtect.addchk( Panel, "Enable AntiSpam", "antispam", "enabled" )

	if tonumber( cl_PProtect.Settings.AntiSpam[ "enabled" ] ) == 1 then

		cl_PProtect.addchk( Panel, "Ignore Admins", "antispam", "admins" )
		cl_PProtect.addchk( Panel, "Tool-AntiSpam", "antispam", "toolprotection" )
		cl_PProtect.addchk( Panel, "Tool-Block", "antispam", "toolblock" )
		cl_PProtect.addchk( Panel, "Prop-Block", "antispam", "propblock" )

		--Tool Protection
		if tonumber( cl_PProtect.Settings.AntiSpam[ "toolprotection" ] ) == 1 then
			cl_PProtect.addbtn( Panel, "Set antispammed Tools", "tools" )
		end

		--Tool Block
		if tonumber( cl_PProtect.Settings.AntiSpam[ "toolblock" ] ) == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Tools", "btools" )
		end

		--Prop Block
		if tonumber( cl_PProtect.Settings.AntiSpam[ "propblock" ] ) == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Props", "bprops" )
		end

		--Cooldown/Spamaction
		cl_PProtect.addsld( Panel, 0, 10, "Cooldown (Seconds)", "antispam", tonumber( cl_PProtect.Settings.AntiSpam[ "cooldown" ] ), 1, "cooldown" )
		cl_PProtect.addsld( Panel, 0, 40, "Props until Admin-Message", "antispam", tonumber( cl_PProtect.Settings.AntiSpam[ "spam" ] ), 0, "spam" )
		--SpamActionCat, saCat = cl_PProtect.makeCategory( Panel, "Spam Action:" )

	end

	-- SAVE SETTINGS
	--cl_PProtect.addbtn( Panel, "Save Settings", "save_as" )

	-- SPAMACTION
	--if GetConVarNumber( "PProtect_AS_enabled" ) == 1 then
	--	cl_PProtect.addcombo( saCat, { "Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]] }, "spamaction" )
	--end

	--local function spamactionChanged( CVar, PreviousValue, NewValue )
		
	--	saCat:Clear()
		
	--	cl_PProtect.addcombo( saCat, { "Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]] }, "spamaction" )

	--	if tonumber( NewValue ) == 4 then
	--		cl_PProtect.addsldr( saCat, 0, 60, "Ban Time (minutes)","general", "bantime" )
	--	elseif tonumber( NewValue ) == 5 then
	--		cl_PProtect.addlbl( saCat, "Write a command. Use <player> for the Spammer", "category" )
	--		cl_PProtect.addtext( saCat, GetConVarString( "PProtect_AS_concommand" ) )
	--	end

	--end
	--cvars.AddChangeCallback( "PProtect_AS_spamaction", spamactionChanged )

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- ANTISPAM
	spawnmenu.AddToolMenuOption( "Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", cl_PProtect.ASMenu )

	-- PROP PROTECTION
	--spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", cl_PProtect.PPMenu)

	-- CLEANUP
	--spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPClientCleanup", "Cleanup", "", "", cl_PProtect.CUMenu)
	
	-- BUDDY
	--spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPBuddyManager", "Buddy", "", "", cl_PProtect.BMenu)

end
hook.Add( "PopulateToolMenu", "PProtectmakeMenus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

function cl_PProtect.UpdateMenus()
	
	-- ANTISPAM
	if cl_PProtect.ASCPanel then
		RunConsoleCommand( "request_newest_settings", LocalPlayer() )
		timer.Simple( 0.05, function()
			cl_PProtect.ASMenu( cl_PProtect.ASCPanel )
		end )
	end
	--[[
	-- PROP PROTECTION
	if cl_PProtect.PPCPanel then
		cl_PProtect.PPMenu(cl_PProtect.PPCPanel)
		RunConsoleCommand("sh_PProtect.reloadSettings", LocalPlayer())
	end

	-- CLEANUP
	if cl_PProtect.CUCPanel then
		cl_PProtect.CUMenu(cl_PProtect.CUCPanel)
		RunConsoleCommand("sh_PProtect.reloadSettings", LocalPlayer())
	end
	
	-- BUDDY
	if cl_PProtect.BCPanel then
		cl_PProtect.BMenu(cl_PProtect.BCPanel)
	end
]]
end
hook.Add( "SpawnMenuOpen", "PProtectMenus", cl_PProtect.UpdateMenus )



net.Receive( "new_client_settings", function()
	
	local received_settings = net.ReadTable()

	cl_PProtect.Settings.AntiSpam = received_settings["AntiSpam"]
	cl_PProtect.Settings.PropProtection = received_settings["PropProtection"]

end )