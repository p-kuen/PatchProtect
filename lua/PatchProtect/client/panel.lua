PAS = PAS or {}

PAS.AdminPanel = nil
PAS.AdminPanel2 = nil
PAS.AdminPanel3 = nil


-- CREATE CLIENT CONVARS
CreateClientConVar("patchpp_usepp", 1, false, true)
CreateClientConVar("patchpp_usepd", 1, false, true)
CreateClientConVar("patchpp_pddelay", 120, false, true)
CreateClientConVar("patchpp_cdrive", 0, false, true)


-- SETTINGS
PAS.Settings = PAS.Settings or {}

-- CONTROLS
cl_PP.checks_general = {}
cl_PP.checks_tools = {}
cl_PP.sliders = {}
cl_PP.texts = {}
cl_PP.combos = {}

-- TOOLS
cl_PP.sqlTools = {}
cl_PP.toolNames = {}


--ANTISPAM MENU

function PAS.AdminMenu(Panel)

	--Delete Controls
	Panel:ClearControls()

	--Set/Reset Variables
	cl_PP.checks_general = {}
	cl_PP.checks_tools = {}
	cl_PP.sliders = {}
	cl_PP.texts = {}
	cl_PP.combos = {}

	local combo_sa
	local updating = false
	local sel = 0

	--Check Admin
	if !LocalPlayer():IsAdmin() then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	
	--Update Panel
	if(!PAS.AdminCPanel) then
		PAS.AdminCPanel = Panel
	end

	--Changed ConVar
	local function changeConVar(convar, value, onlysave)

		if value != nil then

			onlysave = onlysave or false

			local zahl = 0
			if onlysave == true then
				zahl = 1
			else
				zahl = 0
			end

			RunConsoleCommand("PAS_ChangeConVar", convar, value, zahl)

		end

	end

	--Show SpamAction DropDown-Menu
	local function showSpamAction(idx)

		saCat:Clear()

		cl_PP.addlbl(saCat, "Spam Action:")
		addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})

		combo_sa = idx

		if idx == 4 then
			cl_PP.addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")
		elseif idx == 5 then
			cl_PP.addtext(saCat, "concommand")
			cl_PP.addlbl(saCat, "Use <player> for the Spammer")
		end

	end
	hook.Add("combo_spamaction", "showSA", showSpamAction)

	--Add a Combobox
	function addcombo(plist, var, choices)

		local combo = plist:Add("DComboBox")
		local convar = GetConVarNumber("_PAS_ANTISPAM_" .. var)

		table.insert( cl_PP.combos, combo )

		table.foreach( choices, function( key, value )
			combo:AddChoice(value)
		end )

		if convar ~= 0 and updating == false then
			combo:ChooseOptionID(convar)
		elseif convar ~= 0 and updating == true then
			combo:ChooseOptionID(sel)
		end

		function combo:OnSelect(index, value, data)
			sel = index
			updating = true
			hook.Run("combo_" .. var, index)
		end

	end


	--SAVING

	--Tools
	function saveTools()

		local saves = {}
		
		--Add tool checks
		if cl_PP.checks_tools[1] ~= nil then

			table.foreach( cl_PP.toolNames, function( key, value )
				changeConVar("tools_" .. value, cl_PP.checks_tools[key]:GetChecked() and 1 or 0, true)
			end )

		end

	end
	hook.Add("btn_savetools", "SaveTlsFunction", saveTools)

	--Values
	local function saveValues(args)

		if combo_sa == nil then combo_sa = GetConVarNumber("_PAS_ANTISPAM_spamaction") end

		if cl_PP.texts[1] == nil then cl_PP.texts[1] = GetConVarNumber("_PAS_ANTISPAM_concommand") end

		savevalues = {
			combo_sa,
		}

		--Add Controls

		local function saves_value(key, value)
			table.insert(savevalues, value:GetValue())
		end

		local function saves_check(key, value)
			table.insert(savevalues, value:GetChecked() and 1 or 0 )
		end

		table.foreach( cl_PP.checks_general, saves_check(key, value) )
		table.foreach( cl_PP.sliders, saves_value(key, value) )
		table.foreach( cl_PP.texts, saves_value(key, value) )

		if savevalues[table.KeyFromValue(args, "bantime")] == nil then
			savevalues[table.KeyFromValue(args, "bantime")] = GetConVarNumber("_PAS_ANTISPAM_bantime")
		end

		if savevalues[table.KeyFromValue(args, "concommand")] == nil or type(savevalues[table.KeyFromValue(args, "concommand")]) ~= "string" then
			savevalues[table.KeyFromValue(args, "concommand")] = GetConVarString("_PAS_ANTISPAM_concommand")
		end

		table.foreach( savevalues, function(key, value)
			changeConVar(args[i], value)
		end )

	end
	hook.Add("btn_save", "SaveBtnFunction", saveValues)


	--Set Tools
	local function setTools(args)

		tlsFrm = cl_PP.addframe(250, 350, "Set blocked Tools:", true, true, "savetools", "Save Tools")

		table.foreach( cl_PP.toolNames, function()

			timer.Simple( 0.1, function()
				cl_PP.addchk(tlsFrm, cl_PP.toolNames[a], "table", "tools_" .. cl_PP.toolNames[a])
			end )

		end )

	end
	hook.Add("btn_tools", "SetToolsFunction", setTools)


	--[[
	Available Functions:

	'cl_PP.' + one of the functions below

	addchk(Parent, "Name", "type", "var")
	addsldr(Parent, min, max, "Name", "var")
	addbtn(Parent, "Name, "type", args(optional))
	CategoryName, ListName = makeCategory(Parent, "Name")
	addlbl(Parent, "Name")
	addcombo(Parent, "var", Array:Options)
	ListName = addframe(width, height, title, bool:draggable, bool:closeable, string:var, string:btntext(optional))
	]]

	--Set Content
	cl_PP.addchk(Panel, "Use AntiSpam", "convar", "use")
	cl_PP.addchk(Panel, "Use Tool-Protection", "convar", "toolprotection")
	cl_PP.addbtn(Panel, "Set Tools", "tools")
	cl_PP.addsldr(Panel, 0, 10, "Cooldown (Seconds)", "cooldown")
	cl_PP.addsldr(Panel, 0, 40, "Props until Admin-Message", "spamcount")
	cl_PP.addchk(Panel, "No AntiSpam for Admins", "convar", "noantiadmin")
	
	SpamActionCat, saCat = cl_PP.makeCategory(Panel, "Spam Action")
	cl_PP.addbtn(Panel, "Save Settings", "save", {"spamaction", "use", "toolprotection", "noantiadmin", "cooldown", "spamcount", "bantime", "concommand"})
	
	cl_PP.addlbl(saCat, "Spam Action:")
	addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})


	--Add Spam-Action Elements if needed
	local spamactionnumber = GetConVarNumber("_PAS_ANTISPAM_spamaction")

	if spamactionnumber == 4 then

		cl_PP.addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")

	elseif spamactionnumber == 5 then
		
		cl_PP.addlbl(saCat, "Write a command. Use <player> for the Spammer")
		cl_PP.addtext(saCat, GetConVarString("_PAS_ANTISPAM_concommand"))

	end

end


--PROP PROTECTION MENU

function PAS.ProtectionMenu(ProtectionPanel)

	--Delete Controls
	ProtectionPanel:ClearControls()

	--Check Admin
	if !LocalPlayer():IsAdmin() then
		ProtectionPanel:AddControl("Label", {Text = "You are not an admin!"})
		return
	end

	--Refresh Panels
	if(!PAS.AdminCPanel2) then
		PAS.AdminCPanel2 = ProtectionPanel
	end

	--Set Content
	ProtectionPanel:AddControl("Label", {Text = "Main Settings:"})
	ProtectionPanel:AddControl("CheckBox", {Label = "Use Prop Protection", Command = "patchpp_usepp"})

	ProtectionPanel:AddControl("Label", {Text = "Prop-Delete on Disconnect:"})
	ProtectionPanel:AddControl("CheckBox", {Label = "Use Prop-Delete", Command = "patchpp_usepd"})
	ProtectionPanel:AddControl("Slider", {Label = "Prop-Delete Delay (Sec.)", Command = "patchpp_pddelay", Type = "Integer", Min = "1", Max = "120"})
	ProtectionPanel:AddControl("CheckBox", {Label = "Allow C-Driving", Command = "patchpp_cdrive"})

	--Save Settings
	ProtectionPanel:AddControl("Button", {Text = "Apply Settings", Command = "patchpp_save"})

end


--CLEANUP MENU

function PAS.CleanupMenu(CleanupPanel)

	--Delete Controls
	CleanupPanel:ClearControls()

	--Check Admin
	if !LocalPlayer():IsAdmin() then
		CleanupPanel:AddControl( "Label", {Text = "You are not an Admin!"} )
		return
	end

	--Refresh Panels
	if(!PAS.AdminCPanel3) then
		PAS.AdminCPanel3 = CleanupPanel
	end

	--Set Content

	--Cleanup everything
	local count = 0
	for i = 1, table.Count( player.GetAll() ) do
		local plys = player.GetAll()[i]
		count = count + plys:GetCount( "props" )
	end
	CleanupPanel:AddControl( "Label", {Text = "Cleanup everything:"} )
	CleanupPanel:AddControl( "Button", {Text = "Cleanup everything  (" .. tostring(count) .. " Props)", Command = "patchpp_cleanup_everything"} )

	--Claenup Player's Props
	CleanupPanel:AddControl( "Label", {Text = "Cleanup Props from a special player:"} )
	for i = 1, table.Count( player.GetAll() ) do
		local plys = player.GetAll()[i]
		CleanupPanel:AddControl( "Button", {Text = "Cleanup " .. plys:GetName() .."  (" .. tostring(plys:GetCount( "props" )) .. " Props)", Command = "patchpp_clean " .. plys:GetName()} )
	end

end


--CREATE MENUS

local function CreateMenus()

	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPAdmin", "AntiSpam", "", "", PAS.AdminMenu)
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", PAS.ProtectionMenu)
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPClientCleanup", "Cleanup", "", "", PAS.CleanupMenu)

end
hook.Add("PopulateToolMenu", "PASmakeMenus", CreateMenus)


--UPDATE MENUS

local function UpdateMenus()
	
	--AntiSpam Menu
	if PAS.AdminCPanel then
		PAS.AdminMenu(PAS.AdminCPanel)
	end
	
	--PropProtection Menu
	if PAS.AdminCPanel2 then
		PAS.ProtectionMenu(PAS.AdminCPanel2)
	end

	--Cleanup Menu
	if PAS.AdminCPanel3 then
		PAS.CleanupMenu(PAS.AdminCPanel3)
	end

end
hook.Add("SpawnMenuOpen", "PASMenus", UpdateMenus)


--RECEIVE TOOL DATA

local function getToolTable()

	cl_PP.sqlTools = {}
	cl_PP.toolNames = {}

	local rowtable = net.ReadTable()

	cl_PP.sqlTools = table.ClearKeys(rowtable) -- Here, we read the string that was sent from the server

	table.foreach( rowtable, function( key, value )
 		table.insert(cl_PP.toolNames, key)
	end )

end
net.Receive( "toolTable", getToolTable )