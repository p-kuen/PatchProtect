-------------
--  FRAME  --
-------------

function cl_PProtect.addframe( width, height, title, draggable, closeable, horizontal, btntext, btnarg, nettext )

	-- MAIN FRAME
	local frm = vgui.Create("DFrame")

	frm:SetPos( surface.ScreenWidth() / 2 - ( width / 2 ), surface.ScreenHeight() / 2 - ( height / 2 ) )
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

	-- FRAME CATEGORY
	local list = vgui.Create( "DPanelList", frm )

	list:SetPos( 10, 30 )
	local ButtonSize = 0
	
	if btntext != nil then ButtonSize = 50 end
	list:SetSize( width - 20, height - 40 - ButtonSize )
	list:SetSpacing( 5 )
	list:EnableHorizontal( horizontal )
	list:EnableVerticalScrollbar( true )

	if btntext != nil then

		local btn = vgui.Create( "DButton", frm )

		btn:Center()
		btn:SetText( btntext )
		btn:SetDark( true )
		btn:SetSize( 150, 30 )
		btn:SetPos( 20, height - 50 )

		btn.DoClick = function()
			if btnarg == nil then return end

			if type( btnarg ) == "table" then
				net.Start( nettext )
					net.WriteTable( btnarg )
				net.SendToServer()
			end
			frm:Close()
		end

	end

	return list
	
end



----------------
--  CATEGORY  --
----------------

function cl_PProtect.makeCategory( plist, name )

	local cat = vgui.Create( "DCollapsibleCategory" )
	cat:SetLabel( name )

	local pan = vgui.Create( "DListLayout" )
	cat:SetContents( pan )

	plist:AddItem( cat )

	return cat, pan

end



----------------
--  CHECKBOX  --
----------------

function cl_PProtect.addchk( plist, text, typ, var )

	local chk = vgui.Create("DCheckBoxLabel")
	chk:SetText( text )

	if typ == "general" then
		chk:SetConVar( "PProtect_AS_" .. var )
		chk:SetDark(true)

	elseif typ == "tools" then

		chk:SetConVar( "PProtect_AS_tools_" .. var )
		chk:SetDark( true )

	elseif typ == "propprotection" then

		chk:SetConVar( "PProtect_PP_" .. var )
		chk:SetDark( true )

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

	if var ~= "bantime" then plist:AddItem( sldr ) end

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

	btn = vgui.Create( "DButton" )

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
