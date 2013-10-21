local Owner
local IsWorld
local oldentity
local PProtect_Notes = {}



------------
--  FONT  --
------------

surface.CreateFont( "PatchProtectFont", {
	font 		= "DermaDefault",
	size 		= 15,
	weight 		= 750,
	blursize 	= 0,
	scanlines 	= 0,
	antialias 	= true,
	shadow 		= false
} )

surface.CreateFont( "PatchProtectFont_small", {
	font 		= "DefaultSmall",
	size 		= 13,
	weight 		= 750,
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
	if !LocalPlayer() or !LocalPlayer():IsValid() then return end

	-- Set Trace
	local entity = LocalPlayer():GetEyeTrace().Entity
	
	if oldentity != entity then
		
		net.Start( "getOwner" )
			net.WriteEntity( entity )
		net.SendToServer()

		oldentity = entity
		Owner = nil
		IsWorld = nil

	end
	
	if Owner == nil or IsWorld == nil or !entity:IsValid() then return end

	local ownerText
	if Owner:IsPlayer() and IsWorld == false then
		ownerText = "Owner: " .. Owner:GetName()
	elseif IsWorld == true then
		ownerText = "Owner: World Prop"
	elseif IsWorld == false and !Owner:IsPlayer() then
		ownerText = "Owner: Disconnected Player"
	else
		return
	end

	surface.SetFont( "PatchProtectFont_small" )
	local OW, OH = surface.GetTextSize( ownerText )
	OW = OW + 10
	OH = OH + 10

	draw.RoundedBox( 4, ScrW() - OW - 5, ScrH() / 2 - (OH / 2), OW, OH, Color( 88, 144, 222, 200 ) )
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

	Filter = function( self, ent, ply )

		if GetConVarNumber( "PProtect_AS_use" ) == 1 and GetConVarNumber( "PProtect_AS_propblock" ) == 1 then return true else return false end
		if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then return true end
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
	
	local text = value.text
	surface.SetFont( "PatchProtectFont" )
	local tsW, tsH = surface.GetTextSize( text )
	
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
	local coltext = Color( 0, 0, 0, 255 )
	
	draw.RoundedBox( 4, x, y, w, h, col )
	draw.SimpleText( text, "PatchProtectFont", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end



----------------
--  PAINTING  --
----------------

-- SHOW MESSAGES
local function Paint()

	if not PProtect_Notes then return end

	table.foreach( PProtect_Notes, function(key, value)

		if SysTime() < value.time + 4 then

			PProtect_DrawNote( self, key, value)

		else

			table.remove(PProtect_Notes, key)

		end

	end )

end
hook.Add("HUDPaint", "RoundedBoxHud", Paint)



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
