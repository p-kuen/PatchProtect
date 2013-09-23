PAS = PAS or {}

PAS.Settings = PAS.Settings or {}
PAS.AdminPanel = nil

cl_PPP.checks_general = {}
cl_PPP.checks_tools = {}

local sliders = {}
local combos = {}
local texts = {}
local frm

cl_PPP.sqlTools = {}
cl_PPP.toolNames = {}
function PAS.AdminMenu(Panel)


	--Define Variables

	Panel:ClearControls()

	cl_PPP.checks_general = {}
	cl_PPP.checks_tools = {}

	sliders = {}
	combos = {}
	texts = {}
	

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

	local btn
	local SpamActionCat, saCat
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


	--Create a Category

	local function MakeCategory(Name)
		local cat = vgui.Create( "DCollapsibleCategory")
		cat:SetLabel(Name)

		local pan = vgui.Create("DListLayout")
		cat:SetContents(pan)

		Panel:AddItem(cat)
		return cat, pan
	end


	--Add a Checkbox

	local function addchk(plist, text, typ, var)
		local chk = vgui.Create("DCheckBoxLabel")
		chk:SetText(text)

		if typ == "convar" then
			var_checks = "general"
			table.insert(cl_PPP.checks_general, chk)
			chk:SetChecked(tobool(GetConVarNumber("_PAS_ANTISPAM_" .. var)))
			chk:SetDark(true)

		elseif typ == "toolConVar" then
			table.insert(cl_PPP.checks_tools, chk)

			--chk:SetConVar("_PAS_ANTISPAM_" .. var)
			chk:SetChecked(tobool(tonumber(cl_PPP.sqlTools[table.KeyFromValue(cl_PPP.toolNames, string.sub(var, 7))])))
			
			chk:SetDark(true)

		end

		

		plist:AddItem(chk)
	end
	

	--Add a Slider

	local function addsldr(plist, min, max, text, var, decimals)
		local sldr
		if plist == Panel then
			sldr = vgui.Create("DNumSlider")
		else
			sldr = plist:Add("DNumSlider")
		end
		table.insert(sliders, sldr)
		sldr:SetMin(min)
		sldr:SetMax(max)
		decimals = decimals or 1
		sldr:SetDecimals(decimals)
		sldr:SetText(text)
		sldr:SetDark(true)
		sldr:SetValue(GetConVarNumber("_PAS_ANTISPAM_" .. var))

		if plist == Panel then plist:AddItem(sldr) end
	end


	--Show SpamAction DropDown-Menu

	local function showSpamAction(idx)
		saCat:Clear()
		addlbl("Spam Action:", saCat)
		addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})
		combo_sa = idx
		if idx == 4 then
			addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")
		elseif idx == 5 then
			addtext(saCat, "concommand")
			addlbl("Use <player> for the Spammer", saCat)
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
		table.insert(combos, combo)
		for i = 1, table.Count(choices) do
			combo:AddChoice(choices[i])
		end

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


	--Add a Label

	function addlbl(text, plist)
		local lbl = plist:Add("DLabel")
		lbl:SetText(text)
		lbl:SetDark(true)
	end

	function saveTools()
		local saves = {}

		--timer.Simple(0.1, function()
			print("checks:")
			PrintTable(cl_PPP.checks_tools)
		--end)
		
		
		--Add tool checks
		if cl_PPP.checks_tools[1] ~= nil then
			for i = 1, table.Count(cl_PPP.checks_tools) do
				--table.insert(savevalues,  )
			end

			for i = 1, table.Count(cl_PPP.toolNames) do
				changeConVar("tools_" .. cl_PPP.toolNames[i], cl_PPP.checks_tools[i]:GetChecked() and 1 or 0, true)
			end

		end
	end
	hook.Add("btn_savetools", "SaveTlsFunction", saveTools)

	--Add a Frame

	function addframe(width, height, text, draggable, closebutton, type, args)

		--Main Frame
		local frm = vgui.Create("DFrame")
		frm:SetPos( surface.ScreenWidth() / 2 - (width / 2), surface.ScreenHeight() / 2 - (height / 2) )
		frm:SetSize( width, height )
		frm:SetTitle( text )
		frm:SetVisible( true )
		frm:SetDraggable( draggable )
		frm:ShowCloseButton( closebutton )
		frm:SetBackgroundBlur( true )
		frm:MakePopup()
		frm.Paint = function()
			draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 88, 144, 222, 255 ) )
			draw.RoundedBox( 0, 3, 3, frm:GetWide() - 6, frm:GetTall() - 6, Color( 220, 220, 220, 255 ) )
			draw.RoundedBox( 0, 3, 3, frm:GetWide() - 6, 22, Color( 88, 144, 222, 255 ) )
		end

		--Frame-Category
		list = vgui.Create( "DPanelList", frm )
		list:SetPos( 10, 30 )
		list:SetSize( width - 20, height - 40 - 40)
		list:SetSpacing( 5 )
		list:EnableHorizontal( false )
		list:EnableVerticalScrollbar( true )

		--Button
		local btn = vgui.Create("DButton", frm)
		btn:SetPos( width - 60 - 15, height  - 30 - 15)
		btn:SetSize(60,30)
		btn:SetText("Save Tools")

		function btn:OnMousePressed()
			hook.Run("btn_savetools")
		end

	end

	--Saving all Values by pressing the 'Save' Button

	local function saveValues(args)
		if combo_sa == nil then combo_sa = GetConVarNumber("_PAS_ANTISPAM_spamaction") end

		if texts[1] == nil then texts[1] = GetConVarNumber("_PAS_ANTISPAM_concommand") end

		savevalues = {
			combo_sa,
		}

		--Add general checks
		for i = 1, table.Count(cl_PPP.checks_general) do
			table.insert(savevalues, cl_PPP.checks_general[i]:GetChecked() and 1 or 0 )
		end

		--Add sliders
		for i = 1, table.Count(sliders) do

			if sliders[i]:IsValid() then table.insert(savevalues, sliders[i]:GetValue()) end

		end

		if savevalues[table.KeyFromValue(args, "bantime")] == nil then
			savevalues[table.KeyFromValue(args, "bantime")] = GetConVarNumber("_PAS_ANTISPAM_bantime")
		end

		--Add texts
		for i = 1, table.Count(texts) do
			if table.Count(texts) >= 1 then
				if texts[i] ~= 0 then
					table.insert(savevalues, texts[i]:GetValue())
				end

			end

		end

		if savevalues[table.KeyFromValue(args, "concommand")] == nil or type(savevalues[table.KeyFromValue(args, "concommand")]) ~= "string" then
			savevalues[table.KeyFromValue(args, "concommand")] = GetConVarString("_PAS_ANTISPAM_concommand")
		end

		for i = 1, table.Count(savevalues) do
			changeConVar(args[i], savevalues[i])
		end

	end
	hook.Add("btn_save", "SaveBtnFunction", saveValues)

	local function setTools(args)

		addframe(250, 350, "Set blocked Tools:", true, true, "tools")

		for a = 1, table.Count(cl_PPP.toolNames) do

			--if cl_PPP.sqlTools[1] ~= nil then RunConsoleCommand("_PAS_ANTISPAM_tools_" .. cl_PPP.toolNames[a], cl_PPP.sqlTools[a]) end
			--RunConsoleCommand("_PAS_ANTISPAM_tools_" .. PAS.tool_list[a], "1")
			--print()
			
			--
			timer.Simple(0.1, function()
				addchk(list, cl_PPP.toolNames[a], "toolConVar", "tools_" .. cl_PPP.toolNames[a])
			end)
			
			--addchk(list, tools[a], "tools", 1)

		end

	end
	hook.Add("btn_tools", "SetToolsFunction", setTools)


	--Add a Button

	local function addbtn(plist, text, type, args)
		btn = vgui.Create("DButton")
		if type == "save" then btn:SetSize(150,30) else btn:SetSize(150,20) end
		btn:Center()
		btn:SetText(text)
		btn:SetDark(true)

		function btn:OnMousePressed()
			hook.Run("btn_" .. type, args)
		end

		plist:AddItem(btn)
	end


	--Add a Textbox

	function addtext(plist, var)
		local tentry = plist:Add( "DTextEntry")
		table.insert(texts, tentry)
		tentry:SetText(GetConVarString("_PAS_ANTISPAM_" .. var))
	end


	--Build the AntiSpam - Menu

	addchk(Panel, "Use AntiSpam", "convar", "use")
	addchk(Panel, "Use Tool-Protection", "convar", "toolprotection")
	addbtn(Panel, "Set Tools", "tools")
	addsldr(Panel, 0, 10, "Cooldown (Seconds)", "cooldown")
	addsldr(Panel, 0, 40, "Props until Admin-Message", "spamcount")
	addchk(Panel, "No AntiSpam for Admins", "convar", "noantiadmin")
	
	SpamActionCat, saCat = MakeCategory("Spam Action")
	addbtn(Panel, "Save Settings", "save", {"spamaction", "use", "toolprotection", "noantiadmin", "cooldown", "spamcount", "bantime", "concommand"})
	
	addlbl("Spam Action:", saCat)
	addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})


	--Add Spam-Action Elements if selected

	local spamactionnumber = GetConVarNumber("_PAS_ANTISPAM_spamaction")
	if spamactionnumber == 4 then
		addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")
	elseif spamactionnumber == 5 then
		addtext(saCat, "concommand")
		addlbl("Use <player> for the Spammer", saCat)
	end

end


--Make the Menues

local function makeMenus()
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPAdmin", "AntiSpam", "", "", PAS.AdminMenu)
	spawnmenu.AddToolMenuOption("Utilities", "PatchProtect", "PPPropProtection", "PropProtection", "", "", PAS.ProtectionMenu)
end
hook.Add("PopulateToolMenu", "PASmakeMenus", makeMenus)

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
	local rowtable = net.ReadTable()
	cl_PPP.sqlTools = table.ClearKeys(rowtable) -- Here, we read the string that was sent from the server
	toolList = table.foreach( rowtable, function( key, value )
 		table.insert(cl_PPP.toolNames, key)
	end )
	print("Saved Tools: ")
	PrintTable(cl_PPP.sqlTools)
end

net.Receive( "toolTable", getToolTable )
