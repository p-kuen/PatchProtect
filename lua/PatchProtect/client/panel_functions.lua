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
 
		surface.SetDrawColor( 220, 220, 220, 255 )
		self:DrawFilledRect()
		draw.RoundedBox( 0, 0, 0, frm:GetWide(), 24, Color( 88, 144, 222, 255 ) )
 
	end

	function frm:PaintOver()

		surface.SetDrawColor( 88, 144, 222, 255 )
		self:DrawOutlinedRect()

	end

	-- CATEGORY IN FRAME
	local list = vgui.Create( "DPanelList", frm )
	local ButtonSize = 0

	list:SetPos( 10, 30 )
	if btntext != nil then ButtonSize = 50 end
	list:SetSize( w - 20, h - 40 - ButtonSize )
	list:SetSpacing( 5 )
	list:EnableHorizontal( horizontal )
	list:EnableVerticalScrollbar( true )

	if btntext == nil then return list end

	-- BUTTON IN FRAME
	local btn = vgui.Create( "DButton", frm )

	btn:SetPos( 20, h - 50 )
	btn:SetSize( 150, 30 )
	btn:SetText( btntext )
	btn:SetDark( true )
	btn:Center()
	btn:SetFont( "DermaDefaultBold" )

	function btn:DoClick()

		if btnarg == nil then

			if type( btnarg ) == "table" then
				net.Start( nettext )
					net.WriteTable( btnarg )
				net.SendToServer()
			end

		end

		frm:Close()

	end

	function btn:Paint()

		draw.RoundedBox( 2, 1, 1, btn:GetWide() - 3, btn:GetTall() - 3, Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 2, 2, 2, btn:GetWide() - 5, btn:GetTall() - 5, Color( 200, 200, 200, 255 ) )

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

function cl_PProtect.addchk( plist, text, typ, var )

	local chk = vgui.Create( "DCheckBoxLabel" )

	chk:SetText( text )
	chk:SetDark( true )

	if typ == "general" then
		chk:SetConVar( "PProtect_AS_" .. var )
	elseif typ == "tools" then
		chk:SetConVar( "PProtect_AS_tools_" .. var )
	elseif typ == "propprotection" then
		chk:SetConVar( "PProtect_PP_" .. var )
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

	if args ~= nil then
		btn:SetConsoleCommand( "btn_" .. cmd, args )
	else
		btn:SetConsoleCommand( "btn_" .. cmd )
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
