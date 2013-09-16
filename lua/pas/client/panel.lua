PAS = PAS or {}
PAS.AdminPanel = nil

ToolList = {}

local checks = {}
local sliders = {}
local combos = {}
local texts = {}

function searchTools()

	for _, wep in pairs( weapons.GetList() ) do
		if wep.ClassName == "gmod_tool" then 
			local t = wep.Tool
			for name, tool in pairs( t ) do
				t[ name ].ClassName = name
				table.insert(BlockedTools, tostring(name))
				print(name)
			end
		end
	end

end

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

	local function addchk(plist, text, var)
		local chk = vgui.Create("DCheckBoxLabel")
		table.insert(checks, chk)
		chk:SetText(text)
		chk:SetChecked(tobool(GetConVarNumber("_PAS_ANTISPAM_" .. var)))
		chk:SetDark(true)

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

	local function savethevalues()

	end
	local function addbtn(plist, text, args)
		btn = vgui.Create("DButton")
		btn:SetSize(150,30)
		btn:Center()
		btn:SetText(text)
		btn:SetDark(true)
		function btn:OnMousePressed()
			local sa_bantime = 0
			local sa_concommand = ""

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
					--print(i)
					--PrintTable(texts)
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
		plist:AddItem(btn)
	end

	function addtext(plist, var)
		local tentry = plist:Add( "DTextEntry")
		table.insert(texts, tentry)
		tentry:SetText(GetConVarString("_PAS_ANTISPAM_" .. var))
	end
	
	function addframe(width, height, text, dragable, closebutton)
		local pframe = vgui.Create("DFrame")
		pframe:SetPos( surface.ScreenWidth() / 2 - (width / 2), surface.ScreenHeight() / 2 - (height / 2) )
		pframe:SetSize( width, height )
		pframe:SetTitle( text )
		pframe:SetVisible( true )
		pframe:SetDraggable( dragable )
		pframe:ShowCloseButton( closebutton )
		pframe:SetBackgroundBlur( true )
		pframe:MakePopup()
	end

	function addchkframe(width, height, text)
		local chkframe = vgui.Create( "DCheckBoxLabel", pframe)
		chkframe:SetPos( width, height )
		chkframe:SetText(text)
		chkframe:SetDark(true)
		chkframe:SizeToContents()
	end

	--Build the menu
	addchk(Panel, "Use AntiSpam", "use")
	addchk(Panel, "Use Tool-Protection", "toolprotection")
	addsldr(Panel, 0, 10, "Cooldown (Seconds)", "cooldown")
	addsldr(Panel, 0, 40, "Props until Admin-Message", "spamcount")
	addchk(Panel, "No AntiSpam for Admins", "noantiadmin")
	
	SpamActionCat, saCat = MakeCategory("Spam Action")
	addbtn(Panel, "Save Settings", {"spamaction", "use", "toolprotection", "noantiadmin", "cooldown", "spamcount", "bantime", "concommand"})
	

	
	addlbl("Spam Action:", saCat)
	addcombo(saCat, "spamaction", {"Nothing", "CleanUp", "Kick", "Ban", "Console Command"})
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