----------------
--  SETTINGS  --
----------------

cl_PProtect.ConVars = {}
cl_PProtect.ConVars.PProtect_AS = {}
cl_PProtect.ConVars.PProtect_AS_tools = {}
cl_PProtect.ConVars.PProtect_PP = {}

local function createCCV()

	for p, cvar in pairs( cl_PProtect.ConVars ) do

		for k, v in pairs( cvar ) do

			if type( k ) == "number" then
				CreateClientConVar( p .. "_" .. v, 0, false, true )
			else
				CreateClientConVar( p .. "_" .. k, v, false, true )
			end

		end

	end

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

	-- SET CONTENT

	--Main Settings
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

-- PROTECTED TOOLS
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

		psFrm:AddItem( Icon )

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

	-- SET CONTENT

	--Main Switch
	cl_PProtect.addchk( Panel, "Use PropProtection", "propprotection", "use" )

	if GetConVarNumber( "PProtect_PP_use" ) == 1 then

		--Protection Settings
		cl_PProtect.addlbl( Panel, "\nProtection Settings:", "panel" )
		cl_PProtect.addchk( Panel, "No PropProtection for Admins", "propprotection", "noantiadmin" )
		cl_PProtect.addchk( Panel, "Block 'Creator'-Tool (e.g.: Spawn Weapons with Toolgun)", "propprotection", "blockcreatortool" )
		cl_PProtect.addchk( Panel, "Use GravGun-Protection", "propprotection", "gravgunprotection" )
		cl_PProtect.addchk( Panel, "Use Reload-Protection", "propprotection", "reloadprotection" )
		cl_PProtect.addchk( Panel, "Use Damage-Protection", "propprotection", "damageprotection" )
		cl_PProtect.addchk( Panel, "Allow Toolgun on Map", "propprotection", "tool_world" )
		cl_PProtect.addchk( Panel, "Allow Prop-Driving for Non-Admins", "propprotection", "cdrive" )
		
		--Prop Delete Settings
		cl_PProtect.addlbl( Panel, "\nProp-Delete on Disconnect:", "panel" )
		cl_PProtect.addchk( Panel, "Use Prop-Delete on Disconnect", "propprotection", "use_propdelete" )

		if GetConVarNumber( "PProtect_PP_use_propdelete" ) == 1 then
			cl_PProtect.addsldr( Panel, 1, 120, "Prop-Delete Delay (sec)", "propprotection", "propdelete_delay" )
		end

	end

	-- SAVE SETTINGS
	cl_PProtect.addbtn( Panel, "Save Settings", "save_pp" )

end



--------------------
--  CLEANUP MENU  --
--------------------

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

	-- SET CONTENT

	--Cleanup everything
	cl_PProtect.addlbl( Panel, "Cleanup everything:", "panel" )
	local count = 0
	table.foreach( player.GetAll(), function( key, value )
		count = count + value:GetCount( "props" )
	end )
	cl_PProtect.addbtn( Panel, "Cleanup everything (" .. tostring(count) .. " Props)", "cleanup" )

	--Cleanup Disconnected Player's Props
	cl_PProtect.addlbl( Panel, "\nCleanup props of disconnected Players:", "panel" )
	cl_PProtect.addbtn( Panel, "Cleanup all Props from disc. Players", "cleandiscprops" )

	--Claenup Player's Props
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

	for _, wep in pairs( weapons.GetList() ) do
		if wep.Tool ~= nil then 
			for name, tool in pairs( wep.Tool ) do
				table.insert( cl_PProtect.ConVars.PProtect_AS_tools, name )
			end
		end
	end
	table.sort( cl_PProtect.ConVars.PProtect_AS_tools )

end )

-- PROP PROTECTION
net.Receive( "propProtectionSettings", function( len )
     
	cl_PProtect.ConVars.PProtect_PP = net.ReadTable()

	createCCV()
	
end )
