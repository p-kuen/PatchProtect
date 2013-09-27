-------------
--  FRAME  --
-------------

function cl_PP.addframe(width, height, title, draggable, closeable, var, btntext)

	btntext = btntext or "Save"

	--Main Frame
	local frm = vgui.Create("DFrame")

	frm:SetPos( surface.ScreenWidth() / 2 - (width / 2), surface.ScreenHeight() / 2 - (height / 2) )
	frm:SetSize( width, height )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( draggable )
	frm:ShowCloseButton( closeable )
	frm:SetBackgroundBlur( true )
	frm:MakePopup()

	frm.Paint = function()
		draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 88, 144, 222, 255 ) )
		draw.RoundedBox( 0, 3, 3, frm:GetWide() - 6, frm:GetTall() - 6, Color( 220, 220, 220, 255 ) )
		draw.RoundedBox( 0, 3, 3, frm:GetWide() - 6, 22, Color( 88, 144, 222, 255 ) )
	end

	--Frame-Category
	local list = vgui.Create( "DPanelList", frm )

	list:SetPos( 10, 30 )
	list:SetSize( width - 20, height - 40 - 40)
	list:SetSpacing( 5 )
	list:EnableHorizontal( false )
	list:EnableVerticalScrollbar( true )

	--Button
	local btn = vgui.Create("DButton", frm)

	btn:SetPos( width - 60 - 15, height  - 30 - 15)
	btn:SetSize(60, 30)
	btn:SetText(btntext)

	function btn:OnMousePressed()
		hook.Run("btn_" .. var)
	end

	return list
end



----------------
--  CATEGORY  --
----------------

function cl_PP.makeCategory(plist, name)

	local cat = vgui.Create( "DCollapsibleCategory")
	cat:SetLabel(name)

	local pan = vgui.Create("DListLayout")
	cat:SetContents(pan)

	plist:AddItem(cat)

	return cat, pan

end



----------------
--  CHECKBOX  --
----------------

function cl_PP.addchk(plist, text, typ, var)

	local chk = vgui.Create("DCheckBoxLabel")
	chk:SetText(text)

	if typ == "convar" then

		var_checks = "general"
		table.insert(cl_PP.checks_general, chk)
		chk:SetChecked(tobool(GetConVarNumber("_PAS_ANTISPAM_" .. var)))
		chk:SetDark(true)

	elseif typ == "table" then

		table.insert(cl_PP.checks_tools, chk)

		--chk:SetConVar("_PAS_ANTISPAM_" .. var)
		chk:SetChecked(tobool(tonumber(cl_PP.sqlTools[table.KeyFromValue(cl_PP.toolNames, string.sub(var, 7))])))
			
		chk:SetDark(true)

	elseif typ == "test" then

		chk:SetDark(true)

	end

	plist:AddItem(chk)

end



--------------
--  SLIDER  --
--------------

function cl_PP.addsldr(plist, min, max, text, var, decimals)

	local sldr

	if var ~= "bantime" then sldr = vgui.Create("DNumSlider") else sldr = plist:AddItem("DNumSlider") end

	table.insert(cl_PP.sliders, sldr)

	sldr:SetMin(min)
	sldr:SetMax(max)
	decimals = decimals or 1
	sldr:SetDecimals(decimals)
	sldr:SetText(text)
	sldr:SetDark(true)
	sldr:SetValue(GetConVarNumber("_PAS_ANTISPAM_" .. var))

	if var ~= "bantime" then plist:AddItem(sldr) end

end



-------------
--  LABEL  --
-------------

function cl_PP.addlbl(plist, text)

	local lbl = vgui.Create("DLabel")

	lbl:SetText(text)
	lbl:SetDark(true)

	plist:AddItem(lbl)
	
end



----------------
--  BUTTON  --
----------------

function cl_PP.addbtn(plist, text, typ, args)

	btn = vgui.Create("DButton")

	if typ == "save" then btn:SetSize(150,30) else btn:SetSize(150,20) end

	btn:Center()
	btn:SetText(text)
	btn:SetDark(true)

	function btn:OnMousePressed()
		hook.Run("btn_" .. typ, args)
	end

	plist:AddItem(btn)
end



----------------
--  TEXTBOX  --
----------------

function cl_PP.addtext(plist, text)
		local tentry = plist:Add( "DTextEntry")
		table.insert(cl_PP.texts, tentry)
		tentry:SetText(text)
	end