local Owner
local IsBuddy
local IsWorld
local stopsend

cl_PProtect.Notes = {}



-------------
--  FONTS  --
-------------

surface.CreateFont( "PatchProtectFont", {
	font 		= "Roboto",
	size 		= 15,
	weight 		= 750,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "PatchProtectFont_small", {
	font 		= "Roboto",
	size 		= 14,
	weight 		= 500,
	antialias 	= true,
	shadow 		= false
} )



------------------
--  PROP OWNER  --
------------------

-- SHOW OWNER
function cl_PProtect.showOwner()
	
	if cl_PProtect.Settings.Propprotection[ "enabled" ] == 0 then return end

	-- Check Entity
	local entity = LocalPlayer():GetEyeTrace().Entity
	if entity == nil or !entity:IsValid() or entity:IsPlayer() then return end
	
	if stopsend != entity:EntIndex() then

		net.Start( "pprotect_get_owner" )
			net.WriteEntity( entity )
		net.SendToServer()

		stopsend = entity:EntIndex()
		
	end

	-- Check Owner ( Owner is set at the bottom of the file! )
	if Owner == nil or IsWorld == nil or !entity:IsValid() then return end

	local ownerText
	if IsWorld then

		ownerText = "Owner: World"

	else

		if Owner:IsPlayer() and Owner:IsValid() then
			ownerText = "Owner: " .. Owner:Nick()
		elseif Owner:IsPlayer() then
			ownerText = "Owner: Disconnected Player"
		end

	end

	if ownerText == nil then return end

	-- Get textsize
	surface.SetFont( "PatchProtectFont_small" )
	local OW, OH = surface.GetTextSize( ownerText )
	OW = OW + 10
	OH = OH + 10

	-- Set color
	local col
	if Owner == LocalPlayer() or IsBuddy or LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() or IsWorld and cl_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then
		col = Color( 128, 255, 0, 200 )
	elseif cl_PProtect.Settings.Propprotection[ "worldbutton" ] == 1 then
		col = Color( 0, 161, 222, 200 )
	else
		col = Color( 176, 0, 0, 200 )
	end
	
	-- Check Draw-Mode ( FPP-Mode or not )
	if cl_PProtect.Settings.Propprotection[ "fppmode" ] == 0 then

		--Border
		draw.RoundedBox( 0, ScrW() - OW - 15, ScrH() / 2 - (OH / 2), 5, OH, col )
		--Textbox
		draw.RoundedBox( 0, ScrW() - OW - 10, ScrH() / 2 - (OH / 2), OW, OH, Color( 240, 240, 240, 200 ) )
		--Text
		draw.SimpleText( ownerText, "PatchProtectFont_small", ScrW() - 15, ScrH() / 2 , Color( 75, 75, 75, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	
	else

		ownerText = string.Replace( ownerText, "Owner: ", "" )
		local w, h = surface.GetTextSize( ownerText )

		--Textbox
		draw.RoundedBox( 2, ScrW() / 2 - ( w / 2 ) - 3, ScrH() / 2 + 19 - 2, w + 6, h + 4, Color( 0, 0, 0, 100 ) )
		--Text
		draw.SimpleText( ownerText, "PatchProtectFont_small", ScrW() / 2, ScrH() / 2 + 20, col, TEXT_ALIGN_CENTER, 0 )

	end

end
hook.Add( "HUDPaint", "ShowingOwner", cl_PProtect.showOwner )



------------------------
--  PHYSGUN BEAM FIX  --
------------------------

function cl_PProtect.SetClientBeam( ply, ent )
	return false
end
hook.Add( "PhysgunPickup", "SetClientPhysBeam", cl_PProtect.SetClientBeam )



------------------------
--  ADD BLOCKED PROP  --
------------------------

-- ADD TO BLOCKED PROPS
properties.Add( "addblockedprop", {

	MenuLabel = "Add to blocked Props",
	Order = 2002,
	MenuIcon = "icon16/page_white_edit.png",

	Filter = function( self, ent, ply )

		if cl_PProtect.Settings.Antispam[ "enabled" ] == 0 or cl_PProtect.Settings.Antispam[ "propblock" ] == 0 then return false end
		if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then return false end
		if !ent:IsValid() or ent:IsPlayer() then return false end
		return true

	end,

	Action = function( self, ent )

		net.Start( "pprotect_send_blocked_props_cpanel" )
			net.WriteString( ent:GetModel() )
		net.SendToServer()
		
	end

} )



---------------------
--  SHARED ENTITY  --
---------------------

cl_PProtect.shared = nil
cl_PProtect.sharedEnt = {
	phys = false,
	tool = false,
	use = false
}

properties.Add( "shareprops", {

	MenuLabel = "Share entity",
	Order = 2003,
	MenuIcon = "icon16/group.png",

	Filter = function( self, ent, ply )

		if !ent:IsValid() or cl_PProtect.Settings.Propprotection[ "enabled" ] == 0 or ent:IsPlayer() then return false end
		if LocalPlayer():IsSuperAdmin() or Owner == LocalPlayer() then return true else return false end

	end,

	Action = function( self, ent )

		net.Start( "pprotect_get_sharedEntity" )
			net.WriteEntity( ent )
		net.SendToServer()

		cl_PProtect.shared = ent
		
	end

} )

-- SHARE ENTITY PANEL
net.Receive( "pprotect_send_sharedEntity", function( len )

	-- Receive Table
	local entity = cl_PProtect.shared
	local info = net.ReadTable()
	local model = entity:GetModel()

	if table.Count( info ) != 0 then
		cl_PProtect.sharedEnt = info
	else
		cl_PProtect.sharedEnt = {
			phys = false,
			use = false,
			tool = false
		}
	end

	-- Frame
	local frame = cl_PProtect.addframe2( 150, 150, "Share Prop: " .. model )

	-- Checkboxes
	cl_PProtect.addchk2( frame, "Physgun", 10, 30, cl_PProtect.sharedEnt.phys, "phys" )
	cl_PProtect.addchk2( frame, "Toolgun", 10, 55, cl_PProtect.sharedEnt.tool, "tool" )
	cl_PProtect.addchk2( frame, "Use", 10, 80, cl_PProtect.sharedEnt.use, "use" )
	
end )



----------------
--  MESSAGES  --
----------------

-- CREATE INFO MESSAGE
function cl_PProtect.DrawNote( self, key, value )

	surface.SetFont( "PatchProtectFont" )
	local tsW, tsH = surface.GetTextSize( value.text )
	
	local w = tsW + 20
	local h = tsH + 15
	local x = ScrW() - w - 20
	local y = ScrH() - h - 40 * key + 20

	local col
	if value.mode == "normal" then
		col = Color( 88, 144, 222, 200 )
	elseif value.mode == "info" then
		col = Color( 128, 255, 0, 200 )
	elseif value.mode == "admin" then
		col = Color( 176, 0, 0, 200 )
	end
	
	local xtext = ( x + w - 10 )
	local ytext = ( y + ( h / 2 ) )
	local coltext = Color( 75, 75, 75, 255 )
	
	--Border
	draw.RoundedBox( 0, x - 5, y, 5, h, col )

	--Textbox
	draw.RoundedBox( 0, x, y, w, h, Color( 240, 240, 240, 200 ) )

	--Text
	draw.SimpleText( value.text, "PatchProtectFont", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end

-- PAINTING
local function Paint()

	if not cl_PProtect.Notes then return end
	table.foreach( cl_PProtect.Notes, function( key, value )

		if SysTime() < value.time + 4 then
			cl_PProtect.DrawNote( self, key, value )
		else
			table.remove( cl_PProtect.Notes, key )
		end

	end )

end
hook.Add( "HUDPaint", "RoundedBoxHud", Paint )

-- ADD MESSAGES
function cl_PProtect.Info( text, mode )
	
	local curmsg = {}
	curmsg.text = text
	curmsg.time = SysTime()
	curmsg.mode = mode

	table.insert( cl_PProtect.Notes, curmsg )

	LocalPlayer():EmitSound("buttons/button9.wav", 100, 100)
	
end



------------------
--  NETWORKING  --
------------------

-- INFO NOTIFY
net.Receive( "pprotect_notify_info", function( len )
	
	local curmsg = {}
	curmsg.text = net.ReadString()
	curmsg.time = SysTime()
	curmsg.mode = "info"

	table.insert( cl_PProtect.Notes, curmsg )

	LocalPlayer():EmitSound( "buttons/button9.wav", 100, 100 )

end )

-- ADMIN NOTIFY
net.Receive( "pprotect_notify_admin", function( len )

	if LocalPlayer():IsAdmin() then

		local curmsg = {}
		curmsg.text = net.ReadString()
		curmsg.time = SysTime()
		curmsg.mode = "admin"

		table.insert( cl_PProtect.Notes, curmsg )

		if cl_PProtect.Settings.Antispam[ "adminalertsound" ] == 0 then return end
		LocalPlayer():EmitSound( "ambient/alarms/klaxon1.wav", 100, 100 )

	end

end )

-- NOTIFY
net.Receive( "pprotect_notify_normal", function( len )

	local curmsg = {}
	curmsg.text = net.ReadString()
	curmsg.time = SysTime()
	curmsg.mode = "normal"

	table.foreach( cl_PProtect.Notes, function( key, value )

		if value.mode == "normal" then

			table.remove( cl_PProtect.Notes, key)

		end

	end )

	table.insert( cl_PProtect.Notes, curmsg )

end )

-- OWNER
net.Receive( "pprotect_send_owner", function( len )

	Owner = net.ReadEntity()
	local info = net.ReadString()
	if info == "buddy" then IsBuddy = true else IsBuddy = false end
	if info == "world" then IsWorld = true else IsWorld = false end
	
end )
