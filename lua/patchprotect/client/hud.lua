local Owner
local IsBuddy
local IsWorld
local IsDisc
local LastID
local Note = { msg = "", typ = "", time = 0, alpha = 0 }
local scr_w, scr_h = ScrW(), ScrH()


------------------
--  PROP OWNER  --
------------------

function cl_PProtect.showOwner()

	if !cl_PProtect.Settings.Propprotection[ "enabled" ] or !cl_PProtect.Settings.CSettings[ "ownerhud" ] or !LocalPlayer():Alive() then return end

	-- Check Entity
	local ent = LocalPlayer():GetEyeTrace().Entity
	if !ent or ent:IsPlayer() then return end

	if LastID != ent:EntIndex() and ent:IsValid() then

		net.Start( "pprotect_get_owner" )
			net.WriteEntity( ent )
		net.SendToServer()

		LastID = ent:EntIndex()
		
	end

	-- Check Owner ( Owner is set at the bottom of the file! )
	if !Owner or IsWorld == nil or !ent:IsValid() then return end

	local txt = nil
	if IsWorld then txt = "World"
	elseif Owner:IsPlayer() and Owner:IsValid() then txt = Owner:Nick()
	elseif IsDisc then txt = IsDisc .. " (disconnected)"
	else return end

	-- Set Variables
	surface.SetFont( "pprotect_roboto_small" )
	local w = surface.GetTextSize( txt )
	w = w + 10
	local l = scr_w - w - 20
	local t = scr_h * 0.5

	-- Set color
	local col
	if Owner == LocalPlayer() or IsBuddy or LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() or IsWorld and cl_PProtect.Settings.Propprotection[ "worldprops" ] then
		col = Color( 128, 255, 0, 200 )
	elseif cl_PProtect.Settings.Propprotection[ "worldbutton" ] and IsWorld then
		col = Color( 0, 161, 222, 200 )
	else
		col = Color( 176, 0, 0, 200 )
	end

	-- Check Draw-Mode ( FPP-Mode or not )
	if !cl_PProtect.Settings.CSettings[ "fppmode" ] then

		-- Border
		draw.RoundedBoxEx( 4, l - 5, t - 12, 5, 24, col, true, false, true, false )
		-- Textbox
		draw.RoundedBoxEx( 4, l, t - 12, w, 24, Color( 240, 240, 240, 200 ), false, true, false, true )
		-- Text
		draw.SimpleText( txt, "pprotect_roboto_small", l + 5, t - 7, Color( 75, 75, 75 ) )

	else

		-- Textbox
		draw.RoundedBox( 4, scr_w * 0.5 - ( w * 0.5 ) - 3, t + 16, w + 6, 20, Color( 0, 0, 0, 150 ) )
		-- Text
		draw.SimpleText( txt, "pprotect_roboto_small", scr_w * 0.5, t + 20, col, TEXT_ALIGN_CENTER, 0 )

	end

end
hook.Add( "HUDPaint", "pprotect_owner", cl_PProtect.showOwner )



------------------------
--  PHYSGUN BEAM FIX  --
------------------------

local function PhysBeam( ply, ent )
	return false
end
hook.Add( "PhysgunPickup", "pprotect_physbeam", PhysBeam )



------------------------
--  ADD BLOCKED PROP  --
------------------------

properties.Add( "addblockedprop", {

	MenuLabel = "Add to blocked Props",
	Order = 2002,
	MenuIcon = "icon16/page_white_edit.png",

	Filter = function( self, ent, ply )

		if !cl_PProtect.Settings.Antispam[ "enabled" ] or !cl_PProtect.Settings.Antispam[ "propblock" ] or !LocalPlayer():IsSuperAdmin() then return false end
		if !ent:IsValid() or ent:IsPlayer() or ent:GetClass() != "prop_physics" then return false end
		return true

	end,

	Action = function( self, ent )

		net.Start( "pprotect_send_blocked_props_cpanel" )
			net.WriteString( ent:GetModel() )
		net.SendToServer()

	end

} )



-----------------------
--  ADD BLOCKED ENT  --
-----------------------

properties.Add( "addblockedent", {

	MenuLabel = "Add to blocked Entities",
	Order = 2002,
	MenuIcon = "icon16/page_white_edit.png",

	Filter = function( self, ent, ply )

		if !cl_PProtect.Settings.Antispam[ "enabled" ] or !cl_PProtect.Settings.Antispam[ "entblock" ] or !LocalPlayer():IsSuperAdmin() then return false end
		if !ent:IsValid() or ent:IsPlayer() or ent:GetClass() == "prop_physics" then return false end
		return true

	end,

	Action = function( self, ent )

		net.Start( "pprotect_send_blocked_ents_cpanel" )
			net.WriteTable( { name = ent:GetClass(), model = ent:GetModel() } )
		net.SendToServer()

	end

} )



---------------------
--  SHARED ENTITY  --
---------------------

local shared_ent = nil
local shared_info = { phys = false, tool = false, use = false, dmg = false }

properties.Add( "shareentity", {

	MenuLabel = "Share entity",
	Order = 2003,
	MenuIcon = "icon16/group.png",

	Filter = function( self, ent, ply )

		if !ent:IsValid() or !cl_PProtect.Settings.Propprotection[ "enabled" ] or ent:IsPlayer() then return false end
		if LocalPlayer():IsSuperAdmin() or Owner == LocalPlayer() then return true else return false end

	end,

	Action = function( self, ent )

		net.Start( "pprotect_get_sharedEntity" )
			net.WriteEntity( ent )
		net.SendToServer()

		shared_ent = ent

	end

} )

-- SHARE ENTITY PANEL
net.Receive( "pprotect_send_sharedEntity", function( len )

	-- Receive Table
	local mdl = shared_ent:GetModel()
	local info = net.ReadTable()

	if table.Count( info ) != 0 then
		shared_info = info
	else
		shared_info = { phys = false, use = false, tool = false, dmg = false }
	end

	-- Frame
	local frm = cl_PProtect.addfrm( 180, 180, "Share Prop: " .. mdl, false, true, false, "Save", shared_info, "pprotect_save_sharedEntity" )

	-- Checkboxes
	frm:addchk( "Physgun", nil, shared_info[ "phys" ], function( c ) shared_info[ "phys" ] = c end )
	frm:addchk( "Toolgun", nil, shared_info[ "tool" ], function( c ) shared_info[ "tool" ] = c end )
	frm:addchk( "Use", nil, shared_info[ "use" ], function( c ) shared_info[ "use" ] = c end )
	frm:addchk( "Damage", nil, shared_info[ "dmg" ], function( c ) shared_info[ "dmg" ] = c end )
	
end )



----------------
--  MESSAGES  --
----------------

-- DRAW NOTE
local function DrawNote()

	-- Check Note
	if Note.msg == "" or Note.time + 5 < SysTime() then return end

	-- Animation
	if Note.time + 0.5 > SysTime() then
		Note.alpha = math.Clamp( Note.alpha + 10, 0, 255 )
	elseif SysTime() > Note.time + 4.5 then
		Note.alpha = math.Clamp( Note.alpha - 10, 0, 255 )
	end

	surface.SetFont( "pprotect_note" )
	local tw, th = surface.GetTextSize( Note.msg )
	local w = tw + 20
	local h = th + 20
	local x = ScrW() - w - 20
	local y = ScrH() - h - 20
	local alpha = Note.alpha
	local bcol = Color( 88, 144, 222, alpha )

	-- Textbox
	if Note.typ == "info" then
		bcol = Color( 128, 255, 0, alpha )
	elseif Note.typ == "admin" then
		bcol = Color( 176, 0, 0, alpha )
	end
	draw.RoundedBox( 0, x - h, y, h, h, bcol )
	draw.RoundedBox( 0, x, y, w, h, Color( 240, 240, 240, alpha ) )
	draw.SimpleText( "i", "pprotect_note_big", x - 23, y + 2, Color( 255, 255, 255, alpha ) )

	local tri = { { x = x, y = y + ( h * 0.5 ) - 6 }, { x = x + 5, y = y + ( h * 0.5 ) }, { x = x, y = y + ( h * 0.5 ) + 6 } }
	surface.SetDrawColor( bcol )
	draw.NoTexture()
	surface.DrawPoly( tri )

	-- Text
	draw.SimpleText( Note.msg, "pprotect_note", x + 10, y + 10, Color( 75, 75, 75, alpha ) )

end
hook.Add( "HUDPaint", "pprotect_drawnote", DrawNote )

function cl_PProtect.ClientNote( msg, typ )

	if !cl_PProtect.Settings.CSettings[ "notes" ] then return end

	local al = 0
	if Note.alpha > 0 then al = 255 end
	Note = { msg = msg, typ = typ, time = SysTime(), alpha = al }

	if Note.typ == "info" then
		LocalPlayer():EmitSound( "buttons/button9.wav", 100, 100 )
	elseif Note.typ == "admin" and cl_PProtect.Settings.Antispam[ "alert" ] then
		LocalPlayer():EmitSound( "ambient/alarms/klaxon1.wav", 100, 100 )
	end

end



---------------
--  NETWORK  --
---------------

-- NOTIFY
net.Receive( "pprotect_notify", function( len )

	local note = net.ReadTable()
	if note[2] == "admin" and !LocalPlayer():IsAdmin() then return end

	cl_PProtect.ClientNote( note[1], note[2] )

end )

-- OWNER
net.Receive( "pprotect_send_owner", function( len )

	Owner = net.ReadEntity()
	local info = net.ReadString()
	if info == "buddy" then IsBuddy = true else IsBuddy = false end
	if info == "world" then IsWorld = true else IsWorld = false end
	if info != "" and info != "buddy" and info != "world" then IsDisc = info else IsDisc = nil end

end )
