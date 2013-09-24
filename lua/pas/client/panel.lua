PAS = PAS or {}

PAS.Settings = PAS.Settings or {}
PAS.AdminPanel = nil

cl_PP.checks_general = {}
cl_PP.checks_tools = {}

cl_PP.sliders = {}

cl_PP.texts = {}

cl_PP.combos = {}

local frm

cl_PP.sqlTools = {}
cl_PP.toolNames = {}

function PAS.AdminMenu(Panel)


	--Define Variables

	Panel:ClearControls()

	cl_PP.checks_general = {}
	cl_PP.checks_tools = {}

	cl_PP.sliders = {}

	cl_PP.texts = {}

	cl_PP.combos = {}


	--Set Panel

	if(!PAS.AdminCPanel) then
		PAS.AdminCPanel = Panel
	end


	--Check if superadmin, else show a error label

	if !LocalPlayer():IsAdmin() then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	

	--More Variable Definitions

	local combo_sa

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
		cl_PP.addlbl("Spam Action:", saCat)
		addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})
		combo_sa = idx
		if idx == 4 then
			cl_PP.addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")
		elseif idx == 5 then
			cl_PP.addtext(saCat, "concommand")
			cl_PP.addlbl("Use <player> for the Spammer", saCat)
		end
	end
	hook.Add("combo_spamaction", "showSA", showSpamAction)


	--More Variables

	local updating = false
	local sel = 0


	--Add a Combobox

	function addcombo(plist, var, choices)

		local combo = plist:Add("DComboBox")
		
		local convar = GetConVarNumber("_PAS_ANTISPAM_" .. var)

		table.insert(cl_PP.combos, combo)

		table.foreach(choices, function(key, value)
			combo:AddChoice(value)
		end)

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


	--Save Tools

	function saveTools()

		local saves = {}
		
		--Add tool checks
		if cl_PP.checks_tools[1] ~= nil then

			--[[
			table.foreach(clPP.checks_tools, function (key, value)
				table.insert(savevalues,  )
			end)
			]]

			table.foreach(cl_PP.toolNames, function(key, value)
				changeConVar("tools_" .. value, cl_PP.checks_tools[key]:GetChecked() and 1 or 0, true)
			end)

		end

	end
	hook.Add("btn_savetools", "SaveTlsFunction", saveTools)


	--Saving all Values by pressing the 'Save' Button

	local function saveValues(args)
		if combo_sa == nil then combo_sa = GetConVarNumber("_PAS_ANTISPAM_spamaction") end

		if cl_PP.texts[1] == nil then cl_PP.texts[1] = GetConVarNumber("_PAS_ANTISPAM_concommand") end

		savevalues = {
			combo_sa,
		}

		--Add Elements

		local function saves_value(key, value)
			table.insert(savevalues, value:GetValue())
		end

		local function saves_check(key, value)
			table.insert(savevalues, value:GetChecked() and 1 or 0 )
		end

		table.foreach(cl_PP.checks_general, saves_check(key, value))
		table.foreach(cl_PP.sliders, saves_value(key, value))
		table.foreach(cl_PP.texts, saves_value(key, value))

		if savevalues[table.KeyFromValue(args, "bantime")] == nil then
			savevalues[table.KeyFromValue(args, "bantime")] = GetConVarNumber("_PAS_ANTISPAM_bantime")
		end

		if savevalues[table.KeyFromValue(args, "concommand")] == nil or type(savevalues[table.KeyFromValue(args, "concommand")]) ~= "string" then
			savevalues[table.KeyFromValue(args, "concommand")] = GetConVarString("_PAS_ANTISPAM_concommand")
		end

		table.foreach(savevalues, function(key, value)
			changeConVar(args[i], value)
		end)

	end
	hook.Add("btn_save", "SaveBtnFunction", saveValues)


	--Set Tools

	local function setTools(args)

		tlsFrm = cl_PP.addframe(250, 350, "Set blocked Tools:", true, true, "savetools", "Save Tools")

		for a = 1, table.Count(cl_PP.toolNames) do

			timer.Simple(0.1, function()
				cl_PP.addchk(tlsFrm, cl_PP.toolNames[a], "toolConVar", "tools_" .. cl_PP.toolNames[a])
			end)

		end

	end
	hook.Add("btn_tools", "SetToolsFunction", setTools)


	--Build The Menu

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


	--Add Spam-Action Elements if selected

	local spamactionnumber = GetConVarNumber("_PAS_ANTISPAM_spamaction")

	if spamactionnumber == 4 then

		cl_PP.addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")

	elseif spamactionnumber == 5 then
		cl_PP.addlbl(saCat, "Write a command. Use <player> for the Spammer")

		cl_PP.addtext(saCat, GetConVarString("_PAS_ANTISPAM_concommand"))

	end

end


--Prop Protection Menu

function PAS.ProtectionMenu(Panel2)

	function addchkpp(text, cvar)
		local chk = vgui.Create("DCheckBoxLabel")
		chk:SetText(text)
		chk:SetDark(true)
		--chk:SetChecked(tobool(GetConVarNumber("_PatchProtect_PropProtection_" .. cvar)))
		--chk:SetConVar("_PatchProtect_PropProtection_" .. cvar)
		Panel2:AddItem(chk)
	end

	function addbtnpp(type, text)
		local btn = vgui.Create("DButton")
		if type == "save" then btn:SetSize(150,30) else btn:SetSize(150,20) end
		btn:Center()
		btn:SetText(text)
		btn:SetDark(true)

		function btn:OnMousePressed()
			print("test")
		end
		
		Panel2:AddItem(btn)
	end

	addchkpp("Use PropProtection", "UsePP")
	addchkpp("Allow Property to Non-Admins", "AllowProperty")
	addbtnpp("save", "Save Settings")
end

--Make the Menues

local function makeMenus()
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPAdmin", "AntiSpam", "", "", PAS.AdminMenu)
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", PAS.ProtectionMenu)
end
hook.Add("PopulateToolMenu", "PASmakeMenus", makeMenus)

--Update the Menues

local function UpdateMenus()
	
	--AntiSpam Menu
	if PAS.AdminCPanel then
		PAS.AdminMenu(PAS.AdminCPanel)
	end
	
	--PropProtection Menu
	if PAS.AdminCPanel2 then
		PAS.ProtectionMenu(PAS.AdminCPanel2)
	end
end
hook.Add("SpawnMenuOpen", "PASMenus", UpdateMenus)

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
