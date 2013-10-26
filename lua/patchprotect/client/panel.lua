----------------
--  SETTINGS  --
----------------

cl_PProtect.ConVars = {}
cl_PProtect.ConVars.PProtect_AS = {}
cl_PProtect.ConVars.PProtect_AS_tools = {}
cl_PProtect.ConVars.PProtect_PP = {}

local function createCCV()

	table.foreach( cl_PProtect.ConVars, function( p, cvar )

		table.foreach( cvar, function ( k, v )

			if type( k ) == "number" then
				CreateClientConVar( p .. "_" .. v, 0, false, true )
			else
				CreateClientConVar( p .. "_" .. k, v, false, true )
			end

		end )

	end )

end



---------------------
--  ANTISPAM MENU  --
---------------------

function cl_PProtect.ASMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if not LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "You are not an admin!", "panel" )
		return
	end

	-- UPDATE PANEL
	if not cl_PProtect.ASCPanel then
		cl_PProtect.ASCPanel = Panel
	end

	-- MAIN SETTINGS
	cl_PProtect.addchk( Panel, "Use AntiSpam", "general", "use" )

	if GetConVarNumber( "PProtect_AS_use" ) == 1 then

		cl_PProtect.addchk( Panel, "No AntiSpam for Admins", "general", "noantiadmin" )
		cl_PProtect.addchk( Panel, "Use Tool-AntiSpam (Affected by AntiSpam)", "general", "toolprotection" )
		cl_PProtect.addchk( Panel, "Use Tool-Block", "general", "toolblock" )
		cl_PProtect.addchk( Panel, "Use Prop-Block", "general", "propblock" )

		--Tool Protection
		if GetConVarNumber( "PProtect_AS_toolprotection" ) == 1 then
			cl_PProtect.addbtn( Panel, "Set antispammed Tools", "tools" )
		end

		--Tool Block
		if GetConVarNumber( "PProtect_AS_toolblock" ) == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Tools", "btools" )
		end

		--Prop Block
		if GetConVarNumber( "PProtect_AS_propblock" ) == 1 then
			cl_PProtect.addbtn( Panel, "Set blocked Props", "bprops" )
		end

		--Cooldown/Spamaction
		cl_PProtect.addsldr( Panel, 0, 10, "Cooldown (Seconds)","general", "cooldown" )
		cl_PProtect.addsldr( Panel, 0, 40, "Props until Admin-Message","general", "spamcount", 0 )
		SpamActionCat, saCat = cl_PProtect.makeCategory( Panel, "Spam Action:" )

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "save" )

	-- SPAMACTION
	if GetConVarNumber( "PProtect_AS_use" ) == 1 then
		cl_PProtect.addcombo( saCat, {"Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]]}, "spamaction")
	end

	local function spamactionChanged( CVar, PreviousValue, NewValue )
		
		saCat:Clear()
		
		cl_PProtect.addcombo(saCat, {"Nothing", "CleanUp", "Kick", "Ban"--[[, "Console Command"]]}, "spamaction")

		if tonumber( NewValue ) == 4 then
			cl_PProtect.addsldr(saCat, 0, 60, "Ban Time (minutes)","general", "bantime")
		elseif tonumber( NewValue ) == 5 then
			cl_PProtect.addlbl( saCat, "Write a command. Use <player> for the Spammer", "category" )
			cl_PProtect.addtext( saCat, GetConVarString( "PProtect_AS_concommand" ) )
		end

	end
	cvars.AddChangeCallback( "PProtect_AS_spamaction", spamactionChanged )

end




--------------
--  FRAMES  --
--------------

-- ANTISPAMED TOOLS
function cl_PProtect.ShowToolsFrame( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
	tlsFrm = cl_PProtect.addframe( 250, 350, "Set antispammed Tools:", true, true, false )

	table.foreach( cl_PProtect.ConVars.PProtect_AS_tools, function( key, value )

		cl_PProtect.addchk( tlsFrm, value, "tools", value )

	end )

end
concommand.Add( "btn_tools", cl_PProtect.ShowToolsFrame )

-- BLOCKED PROPS
net.Receive( "getBlockedPropData", function()

	local PropsTable = net.ReadTable()

	psFrm = cl_PProtect.addframe( 800, 600, "Set blocked Props:", false, false, true, "Save Props", PropsTable, "sendNewBlockedPropTable" )

	table.foreach( PropsTable, function( key, value )

		local Icon = vgui.Create( "SpawnIcon", psFrm )
		Icon:SetModel( value )

		Icon.DoClick = function()

			local menu = DermaMenu()
			menu:AddOption( "Remove from blocked Props", function()
				table.RemoveByValue( PropsTable, value )
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

end )

-- BLOCKED TOOLS
net.Receive( "getBlockedToolData", function()

	ToolsTable = net.ReadTable()

	tsFrm = cl_PProtect.addframe( 250, 350, "Set blocked Tools:", false, false, false, "Save Tools", ToolsTable, "sendNewBlockedToolTable" )

	table.foreach( ToolsTable, function( key, value )

		cl_PProtect.addchk( tsFrm, key, "blockedtools", key, value )

	end )

end )



----------------------------
--  PROP PROTECTION MENU  --
----------------------------

function cl_PProtect.PPMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "You are not an admin!", "panel" )
		return
	end

	-- UPDATE PANEL
	if not cl_PProtect.PPCPanel then
		cl_PProtect.PPCPanel = Panel
	end

	-- MAIN SETTINGS
	cl_PProtect.addchk( Panel, "Use PropProtection", "propprotection", "use" )

	if GetConVarNumber( "PProtect_PP_use" ) == 1 then

		cl_PProtect.addlbl( Panel, "\nProtection Settings:", "panel" )
		cl_PProtect.addchk( Panel, "No PropProtection for Admins", "propprotection", "noantiadmin" )
		cl_PProtect.addchk( Panel, "Block 'Creator'-Tool (e.g.: Spawn Weapons with Toolgun)", "propprotection", "blockcreatortool" )
		cl_PProtect.addchk( Panel, "Use GravGun-Protection", "propprotection", "gravgunprotection" )
		cl_PProtect.addchk( Panel, "Use Reload-Protection", "propprotection", "reloadprotection" )
		cl_PProtect.addchk( Panel, "Use Damage-Protection", "propprotection", "damageprotection" )
		cl_PProtect.addchk( Panel, "Allow Toolgun on Map", "propprotection", "tool_world" )
		cl_PProtect.addchk( Panel, "Allow Prop-Driving for Non-Admins", "propprotection", "cdrive" )

		cl_PProtect.addlbl( Panel, "\nProp-Delete on Disconnect:", "panel" )
		cl_PProtect.addchk( Panel, "Use Prop-Delete on Disconnect", "propprotection", "use_propdelete" )

		--Prop Delete
		if GetConVarNumber( "PProtect_PP_use_propdelete" ) == 1 then
			cl_PProtect.addchk( Panel, "Keep Admin-Props on Disconnect", "propprotection", "keepadminsprops" )
			cl_PProtect.addsldr( Panel, 1, 120, "Prop-Delete Delay (sec)", "propprotection", "propdelete_delay" )
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "save_pp" )

end



--------------------
--  CLEANUP MENU  --
--------------------

function cl_PProtect.GetCount()

	local count = 0
	
	table.foreach( ents.GetAll(), function( key, value )
		if value:IsValid() and value:GetClass() == "prop_physics" then
			count = count + 1
		end
		
	end )

	return count

end

function cl_PProtect.CUMenu( Panel )

	-- DELETE CONTROLS
	Panel:ClearControls()

	-- CHECK ADMIN
	if !LocalPlayer():IsSuperAdmin() then
		cl_PProtect.addlbl( Panel, "You are not an admin!", "panel" )
		return
	end

	-- UPDATE PANELS
	if not cl_PProtect.CUCPanel then
		cl_PProtect.CUCPanel = Panel
	end

	-- CLEANUP CONTROLS
	cl_PProtect.addlbl( Panel, "Cleanup everything: (Including World Props)", "panel" )
	cl_PProtect.addbtn( Panel, "Cleanup everything (" .. tostring( cl_PProtect.GetCount() ) .. " Props)", "cleanup" )

	cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:", "panel" )
	cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "cleandiscprops" )

	cl_PProtect.addlbl( Panel, "\nCleanup Player's props:", "panel" )
	table.foreach( player.GetAll(), function( key, value )

		net.Start( "getCount" )
			net.WriteEntity( value )
		net.SendToServer()

		net.Receive( "sendCount", function()
			local counter = net.ReadString()
			cl_PProtect.addbtn( Panel, "Cleanup " .. value:GetName() .."  (" .. counter .. " Props)", "cleanup_player", value:GetName() )
		end )

	end )

end



--------------------
--  CREATE MENUS  --
--------------------

local function CreateMenus()

	-- ANTISPAM
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPAntiSpam", "AntiSpam", "", "", cl_PProtect.ASMenu)

	-- PROP PROTECTION
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", cl_PProtect.PPMenu)

	-- CLEANUP
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPClientCleanup", "Cleanup", "", "", cl_PProtect.CUMenu)

end
hook.Add( "PopulateToolMenu", "PProtectmakeMenus", CreateMenus )



--------------------
--  UPDATE MENUS  --
--------------------

local function UpdateMenus()
	
	-- ANTISPAM
	if cl_PProtect.ASCPanel then
		cl_PProtect.ASMenu(cl_PProtect.ASCPanel)
		RunConsoleCommand("sh_PProtect.reloadSettings", LocalPlayer())
	end
	
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

end
hook.Add( "SpawnMenuOpen", "PProtectMenus", UpdateMenus )

------------------
--  NETWORKING  --
------------------

-- ANTISPAM
net.Receive( "generalSettings", function( len )
     
	cl_PProtect.ConVars.PProtect_AS = net.ReadTable()

	table.foreach( weapons.GetList(), function( _, wep )

		if wep.Tool != nil then

			table.foreach( wep.Tool, function( name, tool )
				table.insert( cl_PProtect.ConVars.PProtect_AS_tools, name )
			end )

		end

	end )
	table.sort( cl_PProtect.ConVars.PProtect_AS_tools )

end )

-- PROP PROTECTION
net.Receive( "propProtectionSettings", function( len )
     
	cl_PProtect.ConVars.PProtect_PP = net.ReadTable()
	createCCV()
	
end )
