-------------
--  LABEL  --
-------------

function cl_PProtect.addlbl( derma, text, typ )

	if typ == "category" then

		local lbl = derma:Add( "DLabel" )

		lbl:SetText( text )
		lbl:SetDark( true )

	elseif typ == nil then

		derma:AddControl( "Label", { Text = text } )

	end
	
end



----------------
--  CHECKBOX  --
----------------

function cl_PProtect.addchk( derma, text, setting_type, setting )

	local chk = vgui.Create( "DCheckBoxLabel" )

	chk:SetText( text )
	chk:SetDark( true )

	if setting_type == "antispam" then
		chk:SetChecked( tobool( cl_PProtect.Settings.AntiSpam[setting] ) )
	end

	function chk:OnChange()

		if setting_type == "antispam" then
			cl_PProtect.Settings.AntiSpam[setting] = chk:GetChecked() and "1" or "0"
		end

	end

	function chk:PaintOver()

		draw.RoundedBox( 2, 0, 0, chk:GetTall(), chk:GetTall(), Color( 150, 150, 150, 255 ) )
		draw.RoundedBox( 2, 1, 1, chk:GetTall() - 2, chk:GetTall() - 2, Color( 240, 240, 240, 255 ) )
		if chk:GetChecked() == false then return end
		draw.RoundedBox( 2, 2, 2, chk:GetTall() - 4, chk:GetTall() - 4, Color( 88, 144, 222, 255 ) )

	end

	derma:AddItem( chk )

end



----------------
--   BUTTON   --
----------------

function cl_PProtect.addbtn( derma, text, nettext, args )

	local btn = vgui.Create( "DButton" )

	btn:Center()
	btn:SetText( text )
	btn:SetDark( true )

	btn.DoClick = function()

		net.Start( nettext )
			net.WriteTable( args )
		net.SendToServer()

		cl_PProtect.UpdateMenus()

	end

	derma:AddItem( btn )

end



--------------
--  SLIDER  --
--------------

function cl_PProtect.addsld( derma, min, max, text, sld_type, value, decimals, sld_type2 )

	local sld = vgui.Create( "DNumSlider" )

	sld:SetMin( min )
	sld:SetMax( max )
	decimals = decimals or 0
	sld:SetDecimals( decimals )
	sld:SetText( text )
	sld:SetDark( true )
	sld:SetValue( value )

	sld.ValueChanged = function( self, number )
		
		if sld_type == "antispam" then
			if sld_type2 == "cooldown" then
				cl_PProtect.Settings.AntiSpam[ "cooldown" ] = math.Round( number, 1 )
			else
				cl_PProtect.Settings.AntiSpam[ "spam" ] = math.Round( number, 0 )
			end
		end

	end

	derma:AddItem( sld )

end