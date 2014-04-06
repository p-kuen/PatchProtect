-------------
--  FRAME  --
-------------

function cl_PProtect.addframe( w, h, title, drag, close, horizontal, btntext, btnarg, nettext )

	-- FRAME
	local frm = vgui.Create( "DFrame" )

	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( drag )
	frm:ShowCloseButton( close )
	frm:SetBackgroundBlur( true )
	frm:MakePopup()
	
	function frm:Paint()

		draw.RoundedBox( 4, 0, 0, frm:GetWide(), frm:GetTall(), Color( 88, 144, 222, 255 ) )
		draw.RoundedBox( 4, 2, 22, frm:GetWide() - 4, frm:GetTall() - 24, Color( 220, 220, 220, 255 ) )

	end

	function frm:PaintOver()

		if close == false then return end
		draw.RoundedBox( 4, w - 100, 0, 100, 22, Color( 88, 144, 222, 255 ) )
		draw.RoundedBox( 2, w - 35, 2, 30, 18, Color( 150, 0, 0, 255 ) )
		draw.RoundedBox( 2, w - 34, 3, 28, 16, Color( 220, 0, 0, 255 ) )
		draw.DrawText( "X", "PatchProtectFont", w - 24, 4, Color( 240, 240, 240, 255 ), TEXT_ALIGN_LEFT )

	end

	-- CATEGORY IN FRAME
	local list = vgui.Create( "DPanelList", frm )
	local ButtonSize = 0

	list:SetPos( 10, 30 )
	if btntext != nil then ButtonSize = 40 end
	list:SetSize( w - 20, h - 40 - ButtonSize )
	list:SetSpacing( 5 )
	list:EnableHorizontal( horizontal )
	list:EnableVerticalScrollbar( true )

	if btntext == nil then return list end

	-- BUTTON IN FRAME
	local btn = vgui.Create( "DButton", frm )

	btn:Center()
	btn:SetPos( w - 160, h - 40 )
	btn:SetSize( 150, 30 )
	btn:SetText( btntext )
	btn:SetDark( true )
	btn:SetFont( "PatchProtectFont" )

	function btn:OnMousePressed()

		if btnarg == nil or type( btnarg ) != "table" then return end
			
		if type( btnarg ) == "table" then
				
			net.Start( nettext )
				net.WriteTable( btnarg )
			net.SendToServer()

		end

		frm:Close()

	end

	function btn:Paint()

		draw.RoundedBox( 2, 0, 0, btn:GetWide(), btn:GetTall(), Color( 88, 144, 222, 255 ) )
		draw.RoundedBox( 2, 1, 1, btn:GetWide() - 2, btn:GetTall() - 2, Color( 200, 200, 200, 255 ) )

	end

	return list

end



----------------
--  CATEGORY  --
----------------

function cl_PProtect.makeCategory( plist, name )

	local cat = vgui.Create( "DCollapsibleCategory" )
	local pan = vgui.Create( "DListLayout" )
	
	cat:SetLabel( name )
	cat:SetContents( pan )

	plist:AddItem( cat )
	return cat, pan

end



----------------
--  CHECKBOX  --
----------------

function cl_PProtect.addchk( plist, text, typ, var, var2 )

	local chk = vgui.Create( "DCheckBoxLabel" )

	chk:SetText( text )
	chk:SetDark( true )

	if typ == "general" then
		chk:SetConVar( "PProtect_AS_" .. var )
	elseif typ == "tools" then
		chk:SetConVar( "PProtect_AS_tools_" .. var )
	elseif typ == "blockedtools" then
		chk:SetChecked( var2 )
		function chk:OnChange()
			ToolsTable[var] = chk:GetChecked()
		end
	elseif typ == "propprotection" then
		chk:SetConVar( "PProtect_PP_" .. var )
	elseif typ == "buddy" then
		chk:SetChecked( false )
		function chk:OnChange()
			cl_PProtect.Buddy.RowType[tostring(var)] = tostring(chk:GetChecked())
		end
	end

	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 2, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 88, 144, 222, 255 ) )

	end

	plist:AddItem( chk )

end



--------------
--  SLIDER  --
--------------

function cl_PProtect.addsldr( plist, min, max, text, typ, var, decimals )

	local sldr
	if var == "bantime" then sldr = plist:Add( "DNumSlider" ) else sldr = vgui.Create( "DNumSlider" ) end

	sldr:SetMin( min )
	sldr:SetMax( max )
	decimals = decimals or 1
	sldr:SetDecimals( decimals )
	sldr:SetText( text )
	sldr:SetDark( true )

	if typ == "general" then
		sldr:SetConVar( "PProtect_AS_" .. var )
	elseif typ == "propprotection" then
		sldr:SetConVar( "PProtect_PP_" .. var )
	else
		sldr:SetConVar( "PProtect_AS_" .. var )
	end

	if var != "bantime" then plist:AddItem( sldr ) end

end



-------------
--  LABEL  --
-------------

function cl_PProtect.addlbl( plist, text, typ )

	if typ == "category" then

		local lbl = plist:Add( "DLabel" )

		lbl:SetText( text )
		lbl:SetDark( true )

	elseif typ == "panel" then

		plist:AddControl( "Label", { Text = text } )

	end
	
end



----------------
--   BUTTON   --
----------------

function cl_PProtect.addbtn( plist, text, cmd, args )

	local btn = vgui.Create( "DButton" )

	btn:Center()
	btn:SetText( text )
	btn:SetDark( true )

	btn.DoClick = function()

		if args != nil then
			RunConsoleCommand( "btn_" .. cmd, args )
		else
			RunConsoleCommand( "btn_" .. cmd )
		end

		cl_PProtect.UpdateMenus()

	end

	plist:AddItem( btn )

end



----------------
--  COMBOBOX  --
----------------

function cl_PProtect.addcombo( plist, choices, var )
	
	local combo = plist:Add( "DComboBox" )

	table.foreach( choices, function( key, value )
		combo:AddChoice( value )
	end )
	combo:ChooseOptionID( GetConVarNumber( "PProtect_AS_" .. var ) )

	function combo:OnSelect( index, value, data )

		RunConsoleCommand( "PProtect_AS_" .. var, index )

	end

end



----------------
--  TEXTBOX  --
----------------

function cl_PProtect.addtext( plist, text )

	local tentry = plist:Add( "DTextEntry" )
	
	tentry:SetText( text )

end

----------------
--  LISTVIEW  --
----------------

function cl_PProtect.addlistview( plist, cols, filltype )

	local lview = vgui.Create( "DListView" )
	
	lview:SetMultiSelect( false )
	lview:SetSize(150, 200)
	
	table.foreach( cols, function( key, value )
		lview:AddColumn( value )
	end )
	
	if filltype == "my_buddies" then
	
		lview:AddLine("Buddy01", "TestPerm", "TestID")
		
	elseif filltype == "all_players" then
	
		table.foreach( player.GetAll(), function(key,value)
			lview:AddLine(value:Nick(), value:SteamID())
		end)
		
		function lview:OnClickLine( line, selected )
			cl_PProtect.Buddy.CurrentBuddy[0] = tostring(line:GetValue(2))
			lview:ClearSelection()
			line:SetSelected(true)
		end
		
	else
	
		lview:AddLine("Testname", "Testpermission", "TestID")
		
	end
	
	
	
	plist:AddItem( lview )

end
