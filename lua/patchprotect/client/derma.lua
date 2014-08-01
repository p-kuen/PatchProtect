-------------
--  FRAME  --
-------------

function cl_PProtect.addfrm( w, h, title, close, category, horizontal, btntext, btnarg, nettext )

	-- FRAME
	local frm = vgui.Create( "DFrame" )
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( drag )
	frm:ShowCloseButton( false )
	frm.lblTitle:SetColor( Color( 75, 75, 75 ) )
	frm.lblTitle:SetFont( "pprotect_roboto" )
	frm:MakePopup()
	
	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 200, 150, 30, 255 ) )
		draw.RoundedBox( 0, 1, 1, frm:GetWide() - 2, frm:GetTall() - 2, Color( 255, 175, 0, 255 ) )
		draw.RoundedBox( 0, 6, 24, frm:GetWide() - 12, frm:GetTall() - 30, Color( 255, 255, 255, 255 ) )
	end

	-- Close Button
	if close then

		local btn = vgui.Create( "DButton", frm )
		btn:Center()
		btn:SetPos( w - 51, 0 )
		btn:SetSize( 45, 20 )
		btn:SetText( "x" )
		btn:SetDark( false )
		btn:SetColor( Color( 255, 255, 255, 255 ) )
		btn:SetFont( "pprotect_roboto" )

		function btn:Paint()
			draw.RoundedBox( 0, 0, 0, 45, 20, Color( 199, 80, 80, 255 ) )
		end
		function btn:OnMousePressed()
			frm:Close()
		end

	end

	-- Save Button
	local btn = vgui.Create( "DButton", frm )
	btn:Center()
	btn:SetPos( w - 116, h - 41 )
	btn:SetSize( 100, 25 )
	btn:SetText( btntext )
	btn:SetDark( true )
	btn:SetFont( "pprotect_roboto_small" )
	btn:SetColor( Color( 50, 50, 50 ) )

	function btn:DoClick()

		if btnarg == nil or type( btnarg ) != "table" then return end
			
		if type( btnarg ) == "table" then
				
			net.Start( nettext )
				net.WriteTable( btnarg )
			net.SendToServer()

		end

		frm:Close()

	end

	function btn:Paint()
		if btn.Depressed then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 250, 150, 0, 255 ) )
		elseif btn.Hovered then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 220, 220, 220, 255 ) )
		else
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 200, 200, 200, 255 ) )
		end
	end

	-- Category
	if category then

		local list = vgui.Create( "DPanelList", frm )
		list:SetPos( 16, 34 )
		list:SetSize( w - 32, h - 34 - 51 )
		list:SetSpacing( 5 )
		list:EnableHorizontal( horizontal )
		list:EnableVerticalScrollbar( true )
		list.VBar.btnUp:SetVisible( false )
		list.VBar.btnDown:SetVisible( false )

		function list.VBar:Paint()
			draw.RoundedBox( 0, 0, 0, 20, list.VBar:GetTall(), Color( 255, 255, 255, 255 ) )
		end
		function list.VBar.btnGrip:Paint()
			draw.RoundedBox( 0, 8, 0, 5, list.VBar.btnGrip:GetTall(), Color( 0, 0, 0, 150 ) )
		end

		return list

	end

end



-------------
--  LABEL  --
-------------

function cl_PProtect.addlbl( derma, text )

	local lbl = vgui.Create( "DLabel" )
	lbl:SetText( text )
	lbl:SetDark( true )
	lbl:SizeToContents()
	lbl:SetFont( "pprotect_roboto_small" )
	derma:AddItem( lbl )

end



----------------
--  CHECKBOX  --
----------------

function cl_PProtect.addchk( derma, text, setting_type, setting, tooltip )

	local chk = vgui.Create( "DCheckBoxLabel" )
	chk:SetText( text )
	chk:SetDark( true )
	if isstring( tooltip ) then chk:SetTooltip( tooltip ) end
	chk.Label:SetFont( "pprotect_roboto_small" )

	if setting_type == "antispam" then
		chk:SetChecked( tobool( cl_PProtect.Settings.Antispam[ setting ] ) )
	elseif setting_type == "propprotection" then
		chk:SetChecked( tobool( cl_PProtect.Settings.Propprotection[ setting ] ) )
	elseif setting_type == "blockedtools" then
		chk:SetChecked( tobool( cl_PProtect.Settings.Blockedtools[ setting ] ) )
	elseif setting_type == "antispamtools" then
		chk:SetChecked( tobool( cl_PProtect.Settings.Antispamtools[ setting ] ) )
	elseif setting_type == "buddy" then
		chk:SetChecked( false )
	elseif setting_type == "share" then
		chk:SetChecked( cl_PProtect.sharedEnt[ setting ] )
	end

	function chk:OnChange()

		if setting_type == "antispam" then
			cl_PProtect.Settings.Antispam[ setting ] = chk:GetChecked() and 1 or 0
		elseif setting_type == "propprotection" then
			cl_PProtect.Settings.Propprotection[ setting ] = chk:GetChecked() and 1 or 0
		elseif setting_type == "blockedtools" then
			cl_PProtect.Settings.Blockedtools[ setting ] = chk:GetChecked() and true or false
		elseif setting_type == "antispamtools" then
			cl_PProtect.Settings.Antispamtools[ setting ] = chk:GetChecked() and true or false
		elseif setting_type == "buddy" then
			cl_PProtect.Buddy.RowType[ setting ] = chk:GetChecked() and "true" or "false"
		elseif setting_type == "share" then
			cl_PProtect.sharedEnt[ setting ] = chk:GetChecked()
		end

	end

	function chk:PaintOver()
		draw.RoundedBox( 0, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 0, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 0, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 255, 150, 0, 255 ) )
	end

	derma:AddItem( chk )

end



----------------
--   BUTTON   --
----------------

function cl_PProtect.addbtn( derma, text, nettext, args )

	local btn = vgui.Create( "DButton" )
	btn:Center()
	btn:SetTall( 25 )
	btn:SetText( text )
	btn:SetDark( true )
	btn:SetFont( "pprotect_roboto_small" )
	btn:SetColor( Color( 50, 50, 50 ) )

	function btn:DoClick()

		if type( args ) == "function" then

			args()

		else

			local savetable = {}
			
			net.Start( nettext )

				if string.find( nettext, "pprotect_save_" ) then
					local a, b = string.find( nettext, "pprotect_save_" )
					local tabletext = string.sub( nettext, b + 1, string.len( nettext ) )
					tabletext = string.upper( string.sub( tabletext, 1, 1) ) .. string.sub( tabletext, 2, string.len( tabletext ) )
					savetable = cl_PProtect.Settings[tabletext]
				else
					savetable = args
				end
					
				if savetable != nil then
					net.WriteTable( savetable )
				else
					net.WriteString( "noargs" )
				end

			net.SendToServer()

		end

		if string.find( nettext, "pprotect_save_" ) or string.find( nettext, "pprotect_cleanup_" ) then cl_PProtect.UpdateMenus() end

	end

	derma:AddItem( btn )

	function btn:Paint()
		if btn.Depressed then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 250, 150, 0, 255 ) )
		elseif btn.Hovered then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 220, 220, 220, 255 ) )
		else
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 200, 200, 200, 255 ) )
		end
	end

end



--------------
--  SLIDER  --
--------------

function cl_PProtect.addsld( derma, min, max, text, sld_type, value, decimals, sld_type2 )

	local sld = vgui.Create( "DNumSlider" )
	sld:SetMin( min )
	sld:SetMax( max )
	sld:SetDecimals( decimals )
	sld:SetText( text )
	sld:SetDark( true )
	sld:SetValue( value )
	sld.TextArea:SetFont( "pprotect_roboto_small" )
	sld.Label:SetFont( "pprotect_roboto_small" )
	sld.Scratch:SetVisible( false )

	function sld:OnValueChanged( self, number )
		
		if sld_type == "antispam" then
			if sld_type2 == "cooldown" then
				cl_PProtect.Settings.Antispam[ "cooldown" ] = math.Round( number, 1 )
			elseif sld_type2 == "spam" or "bantime" then
				cl_PProtect.Settings.Antispam[ sld_type2 ] = math.Round( number, 0 )
			end
		elseif sld_type == "propprotection" then
			if sld_type2 == "delay" then
				cl_PProtect.Settings.Propprotection[ "delay" ] = math.Round( number, 0 )
			end
		end

	end

	derma:AddItem( sld )

	function sld.Slider.Knob:Paint()
		draw.RoundedBox( 0, 0, sld.Slider.Knob:GetTall() * 0.1, sld.Slider.Knob:GetWide() * 0.75, sld.Slider.Knob:GetTall() * 0.75, Color( 255, 150, 0, 255 ) )
	end

	function sld.Slider:Paint()
		draw.RoundedBox( 0, sld.Slider.Knob:GetTall() * 0.25, sld.Slider:GetTall() / 2 - ( sld.Slider:GetTall() / 16 ), sld.Slider:GetWide() - sld.Slider.Knob:GetTall(), sld.Slider:GetTall() / 8, Color( 150, 150, 150, 255 ) )
	end

end



----------------
--  COMBOBOX  --
----------------

function cl_PProtect.addcmb( derma, items, setting, value )
	
	local cmb = vgui.Create( "DComboBox" )
	table.foreach( items, function( key, choice )
		cmb:AddChoice( choice )
	end )
	cmb:SetValue( value )
	
	function cmb:OnSelect( panel, index, value, data )
		cl_PProtect.Settings.Antispam[ setting ] = index
	end

	derma:AddItem( cmb )

end



----------------
--  LISTVIEW  --
----------------

function cl_PProtect.addlvw( derma, cols, filltype )

	local lvw = vgui.Create( "DListView" )
	lvw:SetMultiSelect( false )
	lvw:SetSize( 150, 200 )
	table.foreach( cols, function( key, value )
		lvw:AddColumn( value )
	end )
	
	if filltype == "my_buddies" then
	
		if cl_PProtect.Buddy.Buddies != nil then
			
			table.foreach( cl_PProtect.Buddy.Buddies, function( key, value )
				lvw:AddLine( tostring( value[ "nick" ] ), value[ "permission" ], value[ "uniqueid" ] )
			end )

		end

		function lvw:OnClickLine( line, selected )

			cl_PProtect.Buddy.BuddyToRemove[0] = tostring( line:GetValue(3) )
			cl_PProtect.Buddy.BuddyToRemove[1] = tostring( line:GetValue(1) )
			lvw:ClearSelection()
			line:SetSelected( true )
			
		end
		
	elseif filltype == "all_players" then
	
		table.foreach( player.GetAll(), function( key, value )

			if value != LocalPlayer() then

				if cl_PProtect.Buddy.Buddies != nil and table.Count( cl_PProtect.Buddy.Buddies ) > 0 then

					table.foreach( cl_PProtect.Buddy.Buddies, function( k, v )

						if value:UniqueID() != v[ "uniqueid" ] then
							lvw:AddLine( value:Nick(), value:UniqueID() )
						end

					end )
				else
					lvw:AddLine( value:Nick(), value:UniqueID() )
				end
				
			end
			
		end )
		
		function lvw:OnClickLine( line, selected )

			cl_PProtect.Buddy.CurrentBuddy[0] = tostring( line:GetValue(2) )
			cl_PProtect.Buddy.CurrentBuddy[1] = tostring( line:GetValue(1) )
			lvw:ClearSelection()
			line:SetSelected( true )

		end

	end
	
	derma:AddItem( lvw )

end

function cl_PProtect.addtxt( derma, text )

	local txt = vgui.Create( "DTextEntry" )
	txt:SetText( text )
	txt:SetFont( "pprotect_roboto_small" )
	derma:AddItem( txt )

	function txt:OnTextChanged()

		cl_PProtect.Settings.Antispam[ "concommand" ] = txt:GetValue()

	end

end
