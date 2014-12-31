local pan = FindMetaTable( "Panel" )

-------------
--  FRAME  --
-------------

function cl_PProtect.addfrm( w, h, title, close, category, horizontal, btntext, btnarg, nettext )

	-- Frame
	local frm = vgui.Create( "DFrame" )
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:SetTitle( title )
	frm:SetVisible( true )
	frm:SetDraggable( false )
	frm:ShowCloseButton( false )
	frm.lblTitle:SetColor( Color( 75, 75, 75 ) )
	frm.lblTitle:SetFont( "pprotect_roboto" )
	frm:MakePopup()
	
	function frm:Paint()
		draw.RoundedBox( 0, 0, 0, frm:GetWide(), frm:GetTall(), Color( 200, 150, 30 ) )
		draw.RoundedBox( 0, 1, 1, frm:GetWide() - 2, frm:GetTall() - 2, Color( 255, 175, 0 ) )
		draw.RoundedBox( 0, 6, 24, frm:GetWide() - 12, frm:GetTall() - 30, Color( 255, 255, 255 ) )
	end

	-- Close-Button
	if close then

		local btn = vgui.Create( "DButton", frm )
		btn:Center()
		btn:SetPos( w - 51, 0 )
		btn:SetSize( 45, 20 )
		btn:SetText( "x" )
		btn:SetDark( false )
		btn:SetColor( Color( 255, 255, 255 ) )
		btn:SetFont( "pprotect_roboto" )

		function btn:Paint()
			draw.RoundedBox( 0, 0, 0, 45, 20, Color( 200, 80, 80 ) )
		end

		function btn:OnMousePressed()
			frm:Close()
		end

	end

	-- Save-Button
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
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 250, 150, 0 ) )
		elseif btn.Hovered then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 220, 220, 220 ) )
		else
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 200, 200, 200 ) )
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
			draw.RoundedBox( 0, 0, 0, 20, list.VBar:GetTall(), Color( 255, 255, 255 ) )
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

function pan:addlbl( text, header )

	local lbl = vgui.Create( "DLabel" )
	lbl:SetText( text )
	lbl:SetDark( true )
	if !header then lbl:SetFont( "pprotect_roboto_small" ) else lbl:SetFont( "pprotect_roboto_small_bold" ) end
	lbl:SizeToContents()
	self:AddItem( lbl )

end



----------------
--  CHECKBOX  --
----------------

function pan:addchk( text, tip, check, cb )

	local chk = vgui.Create( "DCheckBoxLabel" )
	chk:SetText( text )
	chk:SetDark( true )
	chk:SetChecked( check )
	if tip then chk:SetTooltip( tip ) end
	chk.Label:SetFont( "pprotect_roboto_small" )

	function chk:OnChange() cb( chk:GetChecked() ) end

	function chk:PerformLayout()
		local x = self.m_iIndent or 0
		self:SetHeight( 20 )
		self.Button:SetSize( 36, 20 )
		self.Button:SetPos( x, 0 )
		if self.Label then
			self.Label:SizeToContents()
			self.Label:SetPos( x + 35 + 10, self.Button:GetTall() / 2 - 7 )
		end
	end

	local curx = 0
	if !chk:GetChecked() then curx = 2 else curx = 18 end
	local function smooth( goal )
		local speed = math.abs( goal - curx ) / 3
		if curx > goal then curx = curx - speed
		elseif curx < goal then curx = curx + speed
		end
		return curx
	end

	function chk:PaintOver()
		draw.RoundedBox( 0, 0, 0, 36, 20, Color( 255, 255, 255 ) )
		if !chk:GetChecked() then
			draw.RoundedBox( 8, 0, 0, 36, 20, Color( 100, 100, 100 ) )
			draw.RoundedBox( 8, smooth( 2 ), 2, 16, 16, Color( 255, 255, 255 ) )
		else
			draw.RoundedBox( 8, 0, 0, 36, 20, Color( 255, 150, 0 ) )
			draw.RoundedBox( 8, smooth( 18 ), 2, 16, 16, Color( 255, 255, 255 ) )
		end
	end

	self:AddItem( chk )

	return chk

end



----------------
--   BUTTON   --
----------------

function pan:addbtn( text, nettext, args )

	local btn = vgui.Create( "DButton" )
	btn:Center()
	btn:SetTall( 25 )
	btn:SetText( text )
	btn:SetDark( true )
	btn:SetFont( "pprotect_roboto_small" )
	btn:SetColor( Color( 50, 50, 50 ) )

	function btn:DoClick()

		if btn:GetDisabled() then return end

		if type( args ) == "function" then

			args()

		else

			local savetable = {}
			
			net.Start( nettext )

				if string.find( nettext, "pprotect_save_" ) then
					local tabletext = string.Replace( nettext, "pprotect_save_", "" )
					tabletext = string.upper( string.sub( tabletext, 1, 1) ) .. string.sub( tabletext, 2, string.len( tabletext ) )
					savetable = cl_PProtect.Settings[ tabletext ]
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

	function btn:Paint()
		if btn:GetDisabled() then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 240, 240, 240 ) )
			btn:SetCursor("arrow")
		elseif btn.Depressed then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 250, 150, 0 ) )
		elseif btn.Hovered then
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 220, 220, 220 ) )
		else
			draw.RoundedBox( 0, 0, 0, btn:GetWide(), btn:GetTall(), Color( 200, 200, 200 ) )
		end
	end

	self:AddItem( btn )

	return btn

end



--------------
--  SLIDER  --
--------------
local sldnum = 0
function pan:addsld( min, max, text, value, t1, t2, decimals )

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

	sld.OnValueChanged = function( self, number )

		if sldnum != math.Round( number, decimals ) then sldnum = math.Round( number, decimals ) end
		cl_PProtect.Settings[ t1 ][ t2 ] = sldnum

	end

	function sld.Slider.Knob:Paint() draw.RoundedBox( 6, 2, 2, 12, 12, Color( 255, 150, 0 ) ) end

	function sld.Slider:Paint() draw.RoundedBox( 2, 8, 15, 115, 2, Color( 200, 200, 200 ) ) end

	self:AddItem( sld )

end



----------------
--  COMBOBOX  --
----------------

function pan:addcmb( items, setting, value )
	
	local cmb = vgui.Create( "DComboBox" )
	table.foreach( items, function( key, choice ) cmb:AddChoice( choice ) end )
	cmb:SetValue( value )
	
	function cmb:OnSelect( panel, index, value, data )
		cl_PProtect.Settings.Antispam[ setting ] = index
	end

	self:AddItem( cmb )

end



----------------
--  LISTVIEW  --
----------------

function pan:addlvw( cols, cb )

	local lvw = vgui.Create( "DListView" )
	lvw:SetMultiSelect( false )
	lvw:SetSize( 150, 200 )
	table.foreach( cols, function( key, value ) lvw:AddColumn( value ) end )

	function lvw:OnClickLine( line, selected )

		cb( line )
		lvw:ClearSelection()
		line:SetSelected( true )
		
	end
	
	self:AddItem( lvw )

	return lvw

end



---------------
--  TEXTBOX  --
---------------

function pan:addtxt( text )

	local txt = vgui.Create( "DTextEntry" )
	txt:SetText( text )
	txt:SetFont( "pprotect_roboto_small" )
	self:AddItem( txt )

	function txt:OnTextChanged()
		cl_PProtect.Settings.Antispam[ "concommand" ] = txt:GetValue()
	end

end
