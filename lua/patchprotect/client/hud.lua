local Owner
local IsWorld
local stopsend
local PProtect_Notes = {}



------------
--  FONT  --
------------

surface.CreateFont( "PatchProtectFont", {
	font 		= "Roboto",
	size 		= 15,
	weight 		= 750,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "PatchProtectFont_small", {
	font 		= "Roboto",
	size 		= 14,
	weight 		= 500,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )



------------------
--  PROP OWNER  --
------------------

-- SHOW OWNER
function cl_PProtect.ShowOwner()
	
	if GetConVarNumber( "PProtect_PP_use" ) == 0 then return end

	-- Set Trace
	local entity = LocalPlayer():GetEyeTrace().Entity

	if entity:IsValid() and stopsend == false then

		net.Start( "getOwner" )
			net.WriteEntity( entity )
		net.SendToServer()

		stopsend = true

	elseif !entity:IsValid() then
		stopsend = false
	end
	
	if Owner == nil or IsWorld == nil or !entity:IsValid() then return end

	local ownerText
	if IsWorld then

		ownerText = "Owner: World Prop"

	else

		if Owner:IsPlayer() then
			ownerText = "Owner: " .. Owner:GetName()
		else
			ownerText = "Owner: Disconnected Player"
		end

	end

	surface.SetFont( "PatchProtectFont_small" )
	local OW, OH = surface.GetTextSize( ownerText )
	OW = OW + 10
	OH = OH + 10
	local col
	if Owner == LocalPlayer() or LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
		col = Color( 128, 255, 0, 200 )
	else
		col = Color( 176, 0, 0, 200 )
	end
	draw.RoundedBox( 4, ScrW() - OW - 5, ScrH() / 2 - (OH / 2), OW, OH, col )
	draw.RoundedBox( 4, ScrW() - OW - 3, ScrH() / 2 - (OH / 2) + 2, OW - 4, OH - 4, Color( 240, 240, 240, 200 ) )
	draw.SimpleText( ownerText, "PatchProtectFont_small", ScrW() - 10, ScrH() / 2 , Color( 0, 0, 0, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end
hook.Add( "HUDPaint", "ShowingOwner", cl_PProtect.ShowOwner )

-- SET DISABLED PHYSBEAM IF NOT ALLOWED TO PICKUP
function cl_PProtect.SetClientPhysBeam( ply, ent )
	return false
end
hook.Add( "PhysgunPickup", "SetClientPhysBeam", cl_PProtect.SetClientPhysBeam )



---------------------
--  PROPERTY MENU  --
---------------------

-- ADD TO BLOCKED PROPS
properties.Add( "addblockedprop", {

	MenuLabel = "Add to blocked Props",
	Order = 2002,
	MenuIcon = "icon16/page_white_edit.png",

	Filter = function( self, ent, ply )

		if GetConVarNumber( "PProtect_AS_use" ) == 0 or GetConVarNumber( "PProtect_AS_propblock" ) == 0 then return false end
		if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then return false end
		if !ent:IsValid() or ent:IsPlayer() then return false end
		return true

	end,

	Action = function( self, ent )

		net.Start( "sendBlockedProp" )
			net.WriteString( ent:GetModel() )
		net.SendToServer()
		
	end

} )



----------------
--  MESSAGES  --
----------------

-- CREATE INFO MESSAGE
local function PProtect_DrawNote( self, key, value )

	surface.SetFont( "PatchProtectFont" )
	local tsW, tsH = surface.GetTextSize( value.text )
	
	local w = tsW + 20
	local h = tsH + 15
	local x = ScrW() - w - 15
	local y = ScrH() - h - 35 * key

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
	
	draw.RoundedBox( 4, x, y, w, h, col )
	draw.RoundedBox( 4, x + 3, y + 3, w - 6, h - 6, Color( 240, 240, 240, 200 ) )
	draw.SimpleText( value.text, "PatchProtectFont", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end



----------------
--  PAINTING  --
----------------

-- SHOW MESSAGES
local function Paint()

	if not PProtect_Notes then return end
	table.foreach( PProtect_Notes, function( key, value )

		if SysTime() < value.time + 4 then
			PProtect_DrawNote( self, key, value )
		else
			table.remove( PProtect_Notes, key )
		end

	end )

end
hook.Add( "HUDPaint", "RoundedBoxHud", Paint )



------------------
--  NETWORKING  --
------------------

-- INFO NOTIFY
net.Receive( "PProtect_InfoNotify", function( len )
    
   	local curmsg = {}
	curmsg.text = net.ReadString()
	curmsg.time = SysTime()
	curmsg.mode = "info"

	table.insert( PProtect_Notes, curmsg )

	LocalPlayer():EmitSound("buttons/button9.wav", 100, 100)

end )

-- ADMIN NOTIFY
net.Receive( "PProtect_AdminNotify", function( len )

    if LocalPlayer():IsAdmin() then

		local curmsg = {}
		curmsg.text = net.ReadString()
		curmsg.time = SysTime()
		curmsg.mode = "admin"

		table.insert( PProtect_Notes, curmsg )

		LocalPlayer():EmitSound("ambient/alarms/klaxon1.wav", 100, 100)

	end

end )

-- NOTIFY
net.Receive( "PProtect_Notify", function( len )
    
	local curmsg = {}
	curmsg.text = net.ReadString()
	curmsg.time = SysTime()
	curmsg.mode = "normal"

	table.foreach( PProtect_Notes, function(key, value)

		if value.mode == "normal" then

			table.remove(PProtect_Notes, key)

		end

	end)

	table.insert( PProtect_Notes, curmsg )

end )

-- RECEIVE OWNER
net.Receive( "sendOwner", function( len )

	Owner = net.ReadEntity()
	if net.ReadString() != "" then IsWorld = true else IsWorld = false end

end )
