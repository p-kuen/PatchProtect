PAS = PAS or {}
PAS.AdminPanel = nil

local checks = {}
local sliders = {}
local combos = {}
local texts = {}

function PAS.AdminMenu(Panel)
	Panel:ClearControls()
	checks = {}
	sliders = {}
	combos = {}
	texts = {}
	
	
	if(!PAS.AdminCPanel) then
		PAS.AdminCPanel = Panel
	end
		
	--Check if superadmin, else show a error label
	if !LocalPlayer():IsAdmin() then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	
	local btn
	local SpamActionCat, saCat
	local combo_sa

	local function changeConVar(convar, value)
		if value != nil then
			RunConsoleCommand("PAS_ChangeConVar", convar, value)
		end
	end

	local function MakeCategory(Name)
		local cat = vgui.Create( "DCollapsibleCategory")
		cat:SetLabel(Name)

		local pan = vgui.Create("DListLayout")
		cat:SetContents(pan)

		Panel:AddItem(cat)
		return cat, pan
	end

	local function addchk(plist, text, typ, var)
		local chk = vgui.Create("DCheckBoxLabel")
		chk:SetText(text)

		if typ == "convar" then
			table.insert(checks, chk)
			chk:SetChecked(tobool(GetConVarNumber("_PAS_ANTISPAM_" .. var)))
			chk:SetDark(true)
		elseif typ == "toolConVar" then
			chk:SetConVar("_PAS_ANTISPAM_" .. var)
			chk:SetDark(true)
		end

		plist:AddItem(chk)
	end
	
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

	local updating = false
	local sel = 0
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

		--Create-functions
	function addlbl(text, plist)
		local lbl = plist:Add("DLabel")
		lbl:SetText(text)
		lbl:SetDark(true)
	end

	function addframe(width, height, text, draggable, closebutton, type, args)

		--Create frame
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
			draw.RoundedBox( 2, 3, 3, frm:GetWide() - 6, 22, Color( 88, 144, 222, 255 ) )
		end

		--Create Category
		list = vgui.Create( "DPanelList", frm )
		list:SetPos( 10, 30 )
		list:SetSize( width - 20, height - 40 )
		list:SetSpacing( 5 )
		list:EnableHorizontal( false )
		list:EnableVerticalScrollbar( true )
		
	end

	local function saveValues(args)
		if combo_sa == nil then combo_sa = GetConVarNumber("_PAS_ANTISPAM_spamaction") end

			if texts[1] == nil then texts[1] = GetConVarNumber("_PAS_ANTISPAM_concommand") end

			savevalues = {
				combo_sa,
			}

			--Add checks
			for i = 1, table.Count(checks) do
				table.insert(savevalues, checks[i]:GetChecked() and 1 or 0 )
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

			local tools = searchTools()
			local toolsarray = {}
			for i=1, table.Count(tools) do
				table.insert(toolsarray, GetConVarNumber("_PAS_ANTISPAM_tools_" .. tools[i]))
			end
			PrintTable(toolsarray)
	end
	hook.Add("btn_save", "SaveBtnFunction", saveValues)

	local function setTools(args)
		addframe(250, 250, "Set blocked Tools:", true, true, "tools")

		local ToolList = {}

		for _, wep in pairs( weapons.GetList() ) do
			if wep.ClassName == "gmod_tool" then 
				local t = wep.Tool
				for name, tool in pairs( t ) do
					t[ name ].ClassName = name
					table.insert(ToolList, tostring(name))
					CreateClientConVar("_PAS_ANTISPAM_tools_" .. name, 0, false, false)
				end
			end
		end

		for a = 1, table.Count(ToolList) do

			addchk(list, ToolList[a], "toolConVar", "tools_" .. ToolList[a])
			--addchk(list, tools[a], "tools", 1)

		end
	end
	hook.Add("btn_tools", "SetToolsFunction", setTools)

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

	function addtext(plist, var)
		local tentry = plist:Add( "DTextEntry")
		table.insert(texts, tentry)
		tentry:SetText(GetConVarString("_PAS_ANTISPAM_" .. var))
	end

	--Build the menu
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

local function makeMenus()
	spawnmenu.AddToolMenuOption("Utilities", "PAS", "PASAdmin", "Settings", "", "", PAS.AdminMenu)
end
hook.Add("PopulateToolMenu", "PASmakeMenus", makeMenus)

local function UpdateMenus()
	
	if(PAS.AdminCPanel) then
		PAS.AdminMenu(PAS.AdminCPanel)
	end
end
hook.Add("SpawnMenuOpen", "PASMenus", UpdateMenus)