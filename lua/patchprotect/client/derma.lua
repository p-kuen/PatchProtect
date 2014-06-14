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
	frm:ShowCloseButton( false )
	frm:SetBackgroundBlur( true )
	frm:MakePopup()
	
	function frm:Paint()

		draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 2, 22, frm:GetWide() - 4, frm:GetTall() - 24, Color( 220, 220, 220, 255 ) )

	end

	-- Close Button
	if close then

		local btn = vgui.Create( "DButton", frm )
		btn:Center()
		btn:SetPos( w - 42, 0 )
		btn:SetSize( 40, 18 )
		btn:SetText( "x" )
		btn:SetDark( false )
		btn:SetColor( Color( 255, 255, 255, 255 ) )
		btn:SetFont( "PatchProtectFont" )

		function btn:Paint()
			draw.RoundedBox( 0, 0, 0, 40, 18, Color( 200, 50, 0, 255 ) )
		end

		function btn:OnMousePressed()
			frm:Close()
		end

	end

	-- Category
	local list = vgui.Create( "DPanelList", frm )
	local ButtonSize = 0
	list:SetPos( 10, 30 )
	if btntext != nil then ButtonSize = 40 end
	list:SetSize( w - 20, h - 40 - ButtonSize )
	list:SetSpacing( 5 )
	list:EnableHorizontal( horizontal )
	list:EnableVerticalScrollbar( true )
	if btntext == nil then return list end

	-- Save Button
	local btn = vgui.Create( "DButton", frm )
	btn:Center()
	btn:SetPos( w - 110, h - 35 )
	btn:SetSize( 100, 25 )
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

		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 1, 1, btn:GetWide() - 2, btn:GetTall() - 2, Color( 255, 255, 255, 255 ) )

	end

	return list

end

function cl_PProtect.addframe2( w, h, title )

	local frm = vgui.Create( "DFrame" )

	frm:SetSize( w, h )
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( false )
	frm:ShowCloseButton( false )
	frm:MakePopup()

	function frm:Paint()

		draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 2, 22, frm:GetWide() - 4, frm:GetTall() - 24, Color( 220, 220, 220, 255 ) )

	end

	-- Save Button
	local btn = vgui.Create( "DButton", frm )
	btn:Center()
	btn:SetPos( w - 80, h - 30 )
	btn:SetSize( 70, 20 )
	btn:SetText( "Save" )
	btn:SetDark( true )
	btn:SetFont( "PatchProtectFont" )

	function btn:OnMousePressed()

		net.Start( "pprotect_save_sharedEntity" )
			net.WriteTable( cl_PProtect.sharedEnt )
		net.SendToServer()

		frm:Close()

	end

	function btn:Paint()

		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 1, 1, btn:GetWide() - 2, btn:GetTall() - 2, Color( 255, 255, 255, 255 ) )

	end

	return frm

end



-------------
--  LABEL  --
-------------

function cl_PProtect.addlbl( derma, text )

	local lbl = vgui.Create( "DLabel" )
	lbl:SetText( text )
	lbl:SetDark( true )
	lbl:SizeToContents()
	lbl:SetFont( "PatchProtectFont_small" )
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

function cl_PProtect.addchk2( derma, text, x, y, checked, mode )

	local chk = vgui.Create( "DCheckBoxLabel", derma )
	chk:SetPos( x, y )
	chk:SetText( text )
	chk:SetChecked( checked )
	chk:SetDark( true )
	
	function chk:OnChange()

		cl_PProtect.sharedEnt[ mode ] = chk:GetChecked()

	end

	function chk:PaintOver()

		draw.RoundedBox( 0, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 0, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 0, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 255, 150, 0, 255 ) )

	end

end



----------------
--   BUTTON   --
----------------

function cl_PProtect.addbtn( derma, text, nettext, args )

	local btn = vgui.Create( "DButton" )

	btn:Center()
	btn:SetText( text )
	btn:SetDark( true )
	btn:SetFont( "PatchProtectFont_small" )

	btn.DoClick = function()

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

		draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 255, 150, 0, 255 ) )
		draw.RoundedBox( 0, 1, 1, btn:GetWide() - 2, btn:GetTall() - 2, Color( 255, 255, 255, 255 ) )

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

	sld.ValueChanged = function( self, number )
		
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

end



----------------
--  COMBOBOX  --
----------------

function cl_PProtect.addcmb( derma, items, cmb_type, value )
	
	local cmb = vgui.Create( "DComboBox" )

	table.foreach( items, function( key, choice )
		cmb:AddChoice( choice )
	end )
	cmb:ChooseOptionID( value )

	cmb.OnSelect = function( panel, index, value, data )
		cl_PProtect.Settings.Antispam[ cmb_type ] = index
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
				lvw:AddLine( tostring( value[ "nick" ] ), value[ "permission" ], "testSID", value[ "uniqueid" ] )
			end )

		end

		function lvw:OnClickLine( line, selected )
			cl_PProtect.Buddy.BuddyToRemove[0] = tostring( line:GetValue(4) )
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
