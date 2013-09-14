

PAS = PAS or {}
PAS.AdminPanel = nil

local combo_a_selected
function PAS.AdminMenu(Panel)
	Panel:ClearControls()
	
	
	
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

	local function addchkantispam()
		chk_as = vgui.Create("DCheckBoxLabel")
		chk_as:SetText("Use AntiSpam")
		chk_as:SetValue(tobool(GetConVarNumber("_PAS_ANTISPAM_use")))
		chk_as:SetDark(true)
		
		Panel:AddItem(chk_as)
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
	
	local function addchkantiadmin()
		chk_aa = vgui.Create("DCheckBoxLabel")
		chk_aa:SetText("No AntiSpam for Admins")
		chk_aa:SetValue(tobool(GetConVarNumber("_PAS_ANTISPAM_noantiadmin")))
		chk_aa:SetDark(true)
		
		Panel:AddItem(chk_aa)
	end

	local function addchktoolprotect()
		chk_tp = vgui.Create("DCheckBoxLabel")
		chk_tp:SetText("Tool Protection")
		chk_tp:SetValue(tobool(GetConVarNumber("_PAS_ANTISPAM_toolprotection")))
		chk_tp:SetDark(true)
		
		Panel:AddItem(chk_tp)
	end

	local function addbtn(saves, text, plist)
		btn = vgui.Create("DButton")
		btn:SetSize(150,30)
		btn:Center()
		btn:SetText(text)
		btn:SetDark(true)
		function btn:OnMousePressed()
			local as_checked = chk_as:GetChecked() and 1 or 0
			local aa_checked = chk_aa:GetChecked() and 1 or 0
			local tp_checked = chk_tp:GetChecked() and 1 or 0
			local sa_bantime = 0
			local sa_concommand = ""

			if combo_a_selected == nil and GetConVarNumber("_PAS_ANTISPAM_spamaction") != nil then
				combo_a_selected = GetConVarNumber("_PAS_ANTISPAM_spamaction")
			elseif combo_a_selected == nil then
				combo_a_selected = 1
			end

			if sldr_b != nil and sldr_b:IsValid() then sa_bantime = sldr_b:GetValue() else sa_bantime = GetConVarNumber("_PAS_ANTISPAM_bantime") end
			if tentry_c != nil and tentry_c:IsValid() then sa_concommand =  tentry_c:GetValue() else sa_concommand = GetConVarString("_PAS_ANTISPAM_concommand")end

			savevalues = {
				as_checked,
				sldr_c:GetValue(),
				aa_checked,
				sldr_s:GetValue(),
				combo_a_selected,
				sa_bantime,
				sa_concommand,
				tp_checked
			}

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
	addchkantispam()
	addsldrcooldown()
	addsldrspamcount()
	addchkantiadmin()
	addchktoolprotect()
	SpamActionCat, saCat = MakeCategory("Spam Action")
	addbtn({"use", "cooldown", "noantiadmin", "spamcount", "spamaction", "bantime", "concommand", "toolprotection"}, "Save Settings", Panel)
	

	
	addlbl("Spam Action:", saCat)
	addcomboaction(saCat, false)
	if GetConVarNumber("_PAS_ANTISPAM_spamaction") == 4 then addsldrban(saCat) end
	if GetConVarNumber("_PAS_ANTISPAM_spamaction") == 5 then
		addtextcommand(saCat)
		addlbl("Use <player> for the Spammer", saCat)
	end
end

local function makeMenus()
	spawnmenu.AddToolMenuOption("Utilities", "PAS", "PASAdmin", "Settings", "", "", PAS.AdminMenu)
end
hook.Add("PopulateToolMenu", "PASMenus", makeMenus)

local function UpdateMenus()
	
	if(PAS.AdminCPanel) then
		PAS.AdminMenu(PAS.AdminCPanel)
	end
end
hook.Add("SpawnMenuOpen", "PASMenus", UpdateMenus)