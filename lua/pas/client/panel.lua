PAS = PAS or {}
PAS.AdminPanel = nil

local combo_a_selected
local checks = {}
local sliders = {}
function PAS.AdminMenu(Panel)
	Panel:ClearControls()
	checks = {}
	sliders = {}
	
	
	if(!PAS.AdminCPanel) then
		PAS.AdminCPanel = Panel
	end
		
	--Check if superadmin, else show a error label
	if !LocalPlayer():IsAdmin() then
		Panel:AddControl("Label", {Text = "You are not an admin"})
		return
	end
	
	local sldr_c
	local sldr_s
	local sldr_b = nil
	local chk_aa
	local chk_as
	local chk_tp
	local combo_a
	local btn
	local tentry_c = nil
	local SpamActionCat, saCat

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
		local sldr = vgui.Create("DNumSlider")
		table.insert(sliders, sldr)
		sldr:SetMin(min)
		sldr:SetMax(max)
		decimals = decimals or 1
		sldr:SetDecimals(decimals)
		sldr:SetText(text)
		sldr:SetDark(true)
		sldr:SetValue(GetConVarNumber("_PAS_ANTISPAM_" .. var))

		plist:AddItem(sldr)
	end

		--Create-functions
	local function addlbl(text, plist)
		local lbl = plist:Add("DLabel")
		lbl:SetText(text)
		lbl:SetDark(true)
	end
	
	local function addsldrcooldown()
		sldr_c = vgui.Create("DNumSlider")
		sldr_c:SetMin(0)
		sldr_c:SetMax(10)
		sldr_c:SetDecimals(1)
		sldr_c:SetText("Cooldown (Seconds)")
		sldr_c:SetDark(true)
		sldr_c:SetValue(GetConVarNumber("_PAS_ANTISPAM_cooldown"))
		Panel:AddItem(sldr_c)
	end

	local function addsldrspamcount()
		sldr_s = vgui.Create("DNumSlider")
		sldr_s:SetMin(0)
		sldr_s:SetMax(40)
		sldr_s:SetDecimals(0)
		sldr_s:SetText("Props until Admin-Message")
		sldr_s:SetDark(true)
		sldr_s:SetValue(GetConVarNumber("_PAS_ANTISPAM_spamcount"))
		Panel:AddItem(sldr_s)
	end

	local function addbtn(saves, text, plist)
		btn = vgui.Create("DButton")
		btn:SetSize(150,30)
		btn:Center()
		btn:SetText(text)
		btn:SetDark(true)
		function btn:OnMousePressed()
			local sa_bantime = 0
			local sa_concommand = ""

			PrintTable(checks)

			if combo_a_selected == nil and GetConVarNumber("_PAS_ANTISPAM_spamaction") != nil then
				combo_a_selected = GetConVarNumber("_PAS_ANTISPAM_spamaction")
			elseif combo_a_selected == nil then
				combo_a_selected = 1
			end

			if sldr_b != nil and sldr_b:IsValid() then sa_bantime = sldr_b:GetValue() else sa_bantime = GetConVarNumber("_PAS_ANTISPAM_bantime") end
			if tentry_c != nil and tentry_c:IsValid() then sa_concommand =  tentry_c:GetValue() else sa_concommand = GetConVarString("_PAS_ANTISPAM_concommand")end

			savevalues = {
				combo_a_selected,
				sa_bantime,
				sa_concommand,
			}

			--Add checks
			for i = 1, table.Count(checks) do
				table.insert(savevalues, checks[i])
			end

			--Add sliders
			for i = 1, table.Count(sliders) do
				table.insert(savevalues, sliders[i])
			end
			
			for i=1, table.Count(savevalues) do
				changeConVar(saves[i], savevalues[i])
			end
			
		end
		plist:AddItem(btn)
	end

	local function showbanframe()
		frame = vgui.Create( "Frame" )
		frame:SetSize( ScrW()*0.25, ScrH()*0.25 )
		frame:Center()
		frame:SetVisible( true )
		frame:MakePopup()

	end

	local function addcomboaction(plist, updating)
		combo_a = plist:Add("DComboBox")
		combo_a:AddChoice("Nothing")
		combo_a:AddChoice("CleanUp")
		combo_a:AddChoice("Kick")
		combo_a:AddChoice("Ban")
		combo_a:AddChoice("Console Command")
		if GetConVarNumber("_PAS_ANTISPAM_spamaction") != 0 and updating == false then
			combo_a:ChooseOptionID(GetConVarNumber("_PAS_ANTISPAM_spamaction"))
		end
		if updating == true then
			combo_a:ChooseOptionID(combo_a_selected)
		end

		combo_a.OnSelect = function(panel, index, value, data)
			combo_a_selected = index
			saCat:Clear()
			addlbl("Spam Action:", saCat)
			addcomboaction(saCat, true)
			if index == 4 then
				addsldrban(saCat)
			elseif index == 5 then
				addtextcommand(saCat)
				addlbl("Use <player> for the Spammer", saCat)
			end
		end
	end

	function addsldrban(plist)
		sldr_b = plist:Add("DNumSlider")
		sldr_b:SetMin(0)
		sldr_b:SetMax(60)
		sldr_b:SetDecimals(0)
		sldr_b:SetText("Ban Time (minutes)")
		sldr_b:SetDark(true)
		sldr_b:SetValue(GetConVarNumber("_PAS_ANTISPAM_bantime"))
	end

	function addtextcommand(plist)
		tentry_c = plist:Add( "DTextEntry")
		tentry_c:SetText(GetConVarString("_PAS_ANTISPAM_concommand"))
	end
	
	--Build the menu
	addchk(Panel, "Use AntiSpam", "use")
	addchk(Panel, "Use Tool-Protection", "toolprotection")
	addsldr(Panel, 0, 10, "Cooldown (Seconds)", "cooldown")
	addsldr(Panel, 0, 40, "Props until Admin-Message", "spamcount")
	addchk(Panel, "No AntiSpam for Admins", "noantiadmin")
	
	SpamActionCat, saCat = MakeCategory("Spam Action")
	addbtn({"use", "cooldown", "noantiadmin", "spamcount", "spamaction", "bantime", "concommand", "toolprotection"}, "Save Settings", Panel)
	

	
	addlbl("Spam Action:", saCat)
	--addcomboaction(saCat, false)
	local spamactionnumber = GetConVarNumber("_PAS_ANTISPAM_spamaction")
	if spamactionnumber == 4 then
		addsldr(saCat, 0, 60, "Ban Time (minutes)", "bantime")
	elseif spamactionnumber == 5 then
		addtextcommand(saCat)
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
	print(checks[1])
end
hook.Add("SpawnMenuOpen", "PASMenus", UpdateMenus)