local pan = FindMetaTable( "Panel" )

-------------
--  FRAME  --
-------------

function cl_PProtect.addfrm( w, h, title, hor )

	-- Frame
	local t = SysTime()
	local frm = vgui.Create( "DPanel" )
	frm:SetPos( surface.ScreenWidth() / 2 - ( w / 2 ), surface.ScreenHeight() / 2 - ( h / 2 ) )
	frm:SetSize( w, h )
	frm:MakePopup()

	function frm:Paint( w, h )
		Derma_DrawBackgroundBlur( self, t )
		draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 127.5 ) )
		draw.RoundedBox( 4, 1, 1, w - 2, h - 2, Color( 255, 150, 30 ) )
		draw.RoundedBoxEx( 4, 1, 50, w - 2, h - 51, Color( 255, 255, 255 ), false, false, true, true )
	end

	-- Title
	frm.title = vgui.Create( "DLabel", frm )
	frm.title:SetText( title )
	frm.title:SetPos( 15, 12.5 )
	frm.title:SetFont( cl_PProtect.setFont( "roboto", 25, 750, true ) )
	frm.title:SetColor( Color( 0, 0, 0, 191.25 ) )
	frm.title:SizeToContents()

	-- Close-Button
	frm.close = vgui.Create( "DButton", frm )
	frm.close:SetPos( w - 40, 10 )
	frm.close:SetSize( 30, 30 )
	frm.close:SetText( "" )
	function frm.close.DoClick() frm:Remove() end

	function frm.close:Paint()

		if self.Depressed then draw.RoundedBox( 4, 0, 0, 30, 30, Color( 135, 50, 50 ) )
		elseif self.Hovered then draw.RoundedBox( 4, 0, 0, 30, 30, Color( 200, 60, 60 ) )
		else draw.RoundedBox( 4, 0, 0, 30, 30, Color( 200, 80, 80 ) )
		end
		draw.SimpleText( "r", cl_PProtect.setFont( "marlett", 14, 0, false, false, true ), 9, 8, Color( 255, 255, 255 ) )

	end

	frm.list = vgui.Create( "DPanelList", frm )
	frm.list:SetPos( 10, 60 )
	frm.list:SetSize( w - 20, h - 70 )
	frm.list:SetSpacing( 5 )
	frm.list:EnableHorizontal( hor )
	frm.list:EnableVerticalScrollbar( true )
	frm.list.VBar.btnUp:SetVisible( false )
	frm.list.VBar.btnDown:SetVisible( false )

	function frm.list.VBar:Paint()
		draw.RoundedBox( 0, 0, 0, 20, frm.list.VBar:GetTall(), Color( 255, 255, 255 ) )
	end

	function frm.list.VBar.btnGrip:Paint()
		draw.RoundedBox( 0, 8, 0, 5, frm.list.VBar.btnGrip:GetTall(), Color( 0, 0, 0, 150 ) )
	end

	return frm.list

end



-------------
--  LABEL  --
-------------

function pan:addlbl( text, header )

	if header then header = 750 else header = 0 end
	local lbl = vgui.Create( "DLabel" )
	lbl:SetText( text )
	lbl:SetDark( true )
	lbl:SetFont( cl_PProtect.setFont( "roboto", 14, header, true ) )
	lbl:SizeToContents()
	self:AddItem( lbl )

	return lbl

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
	chk.Label:SetFont( cl_PProtect.setFont( "roboto", 14, 500, true ) )

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
	btn:SetFont( cl_PProtect.setFont( "roboto", 14, 500, true ) )
	btn:SetColor( Color( 50, 50, 50 ) )

	function btn:DoClick()

		if btn:GetDisabled() then return end

		if type( args ) == "function" then

			args()

		else

			net.Start( nettext )
				if args != nil and cl_PProtect.Settings[ args[1] ] then
					net.WriteTable( { args[1], cl_PProtect.Settings[ args[1] ] } )
				else
					net.WriteTable( args or {} )
				end
			net.SendToServer()

		end

		if nettext == "pprotect_save" then cl_PProtect.UpdateMenus() end

	end

	function btn:Paint( w, h )
		if btn:GetDisabled() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 240, 240, 240 ) )
			btn:SetCursor( "arrow" )
		elseif btn.Depressed then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 250, 150, 0 ) )
		elseif btn.Hovered then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 220, 220, 220 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200 ) )
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
	sld.TextArea:SetFont( cl_PProtect.setFont( "roboto", 14, 500, true ) )
	sld.Label:SetFont( cl_PProtect.setFont( "roboto", 14, 500, true ) )
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
local pressed = {}
function pan:addplp( ply, bud, cb, cb2 )

	local plp = vgui.Create( "DPanel" )
	plp:SetHeight( 40 )
	plp:SetCursor( "hand" )

	plp.av = vgui.Create( "AvatarImage", plp )
	plp.av:SetSize( 32, 32 )
	plp.av:SetPlayer( ply, 32 )
	plp.av:SetPos( 4, 4 )

	plp.lbl = vgui.Create( "DLabel", plp )
	plp.lbl:SetText( ply:Nick() )
	plp.lbl:SetFont( cl_PProtect.setFont( "roboto", 25, 750, true ) )
	plp.lbl:SetPos( 40, 9 )
	plp.lbl:SetColor( Color( 50, 50, 50 ) )
	plp.lbl:SetWidth( 230 )

	plp.chk = vgui.Create( "DCheckBox", plp )
	plp.chk:SetPos( 270, 10 )
	plp.chk:SetSize( 20, 20 )
	plp.chk:SetChecked( bud )

	function plp:OnMousePressed() cb( ply ) pressed = { plp, ply } end
	function plp.chk:OnChange( c ) cb2( c ) end

	function plp:Paint( w, h )
		if pressed[1] == plp then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 150, 0 ) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color( 230, 230, 230 ) )
		end
	end

	function plp.chk:Paint( w, h )
		if !self:GetChecked() then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 50, 0 ) )
			draw.SimpleText( "r", cl_PProtect.setFont( "marlett", 16, 750, false, false, true ), 2, 3, Color( 255, 255, 255 ) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 200, 75 ) )
			draw.SimpleText( "b", cl_PProtect.setFont( "marlett", 22, 500, false, false, true ), 0, 0, Color( 255, 255, 255 ) )
		end
	end

	self:AddItem( plp )

	return plp

end



---------------
--  TEXTBOX  --
---------------

function pan:addtxt( text )

	local txt = vgui.Create( "DTextEntry" )
	txt:SetText( text )
	txt:SetFont( cl_PProtect.setFont( "roboto", 14, 500, true ) )
	self:AddItem( txt )

	function txt:OnTextChanged()
		cl_PProtect.Settings.Antispam[ "concommand" ] = txt:GetValue()
	end

end



------------
--  ICON  --
------------

function pan:addico( model, tip, cb )

	local ico = vgui.Create( "SpawnIcon", self )
	ico:SetModel( model )
	if tip then ico:SetTooltip( tip ) end

	ico.DoClick = function() cb( ico ) end

	function ico:Paint( w, h )
		if !self.Hovered then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200 ) )
		else
			draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 150, 0 ) )
		end
		if self.Depressed then draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 63.75 ) ) end
	end

	function ico:PaintOver() end

	self:AddItem( ico )

	return ico

end
