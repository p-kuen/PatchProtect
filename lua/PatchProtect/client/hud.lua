local Owner
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

function cl_PProtect.ShowOwner()
	
	-- Check, PatchPP
	if GetConVarNumber( "PProtect_PP_use" ) == 0 then return end

	-- No Valid Player or Valid Entity
	if !LocalPlayer() or !LocalPlayer():IsValid() then return end

	-- Set Trace
	local PlyTrace = LocalPlayer():GetEyeTrace()
	

	if PlyTrace.HitNonWorld then

		if PlyTrace.Entity:IsValid() and !PlyTrace.Entity:IsPlayer() and !LocalPlayer():InVehicle() then

			if Owner == nil then

				local traceent = PlyTrace.Entity
				if !traceent:IsValid() then return end

				net.Start("getOwner")
					net.WriteEntity( traceent )
				net.SendToServer()
				
			end

			local ownerText
			if type(Owner) == "Player" then
				ownerText = "Owner: " .. Owner:GetName()
			else
				ownerText = "Owner: Disc. or World"
			end

			surface.SetFont("PatchProtectFont_small")

			local OW, OH = surface.GetTextSize(ownerText)
			OW = OW + 10
			OH = OH + 10

			if type(Owner) ~= "nil" then
				draw.RoundedBox(3, ScrW() - OW - 5, ScrH() / 2 - (OH / 2), OW, OH, Color(88, 144, 222, 200))
				draw.SimpleText(ownerText, "PatchProtectFont_small", ScrW() - 10, ScrH() / 2 , Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end

		else

			if Owner ~= nil then Owner = nil end --Because of the server performance, it just sets it to nil once

		end

	else
		
		if Owner ~= nil then Owner = nil end --Because of the server performance, it just sets it to nil once
		
	end

end
hook.Add("HUDPaint", "ShowingOwner", cl_PProtect.ShowOwner)

--Set PhysBeam to a kind of "disabled" Beam, if the player is not allowed to pick the prop up
function cl_PProtect.SetClientPhysBeam( ply, ent )

	return false

end
hook.Add("PhysgunPickup", "SetClientPhysBeam", cl_PProtect.SetClientPhysBeam)



---------------------
--  PROPERTY MENU  --
---------------------

-- SET OTHER OWNER OVER C-MENU
properties.Add( "setpropertyowner", {

	MenuLabel = "Set Owner...",

	Order = 2001,

	Filter = function( self, ent, ply )

		if !ent:IsValid() or ent:IsPlayer() or ply != Owner then return false end
		return true

	end,

	MenuOpen = function( self, menu, ent, trace )

		local submenu = menu:AddSubMenu()
		for _, ply in ipairs( player.GetAll() ) do

			submenu:AddOption( ply:Nick(), function()

				local sendInformation = {}
				table.insert(sendInformation, ent)
				table.insert(sendInformation, ply)

				net.Start( "SetOwnerOverProperty" )
					net.WriteTable( sendInformation )
				net.SendToServer()

			end )

		end

	end,

} )

-- ADD TO BLOCKED PROPS
properties.Add("addblockedprop", {

	MenuLabel = "Add to blocked Props",
	Order = 2002,

	Filter = function(self, ent, ply)

		if !ent:IsValid() or ent:IsPlayer() then return false end
		if !ply:IsSuperAdmin() then return false end
		return true

	end,

	Action = function(self, ent)
		--Here goes function to block a prop
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

local function Paint()

	-- SHOW MESSAGES
	if not PProtect_Notes then return end

	local count = 0
	table.foreach( PProtect_Notes, function(key, value)

		if value.mode == "normal" then
			count = count + 1
		end

		if SysTime() < value.time + 4 then

			if count > 1 then

				table.remove(PProtect_Notes, key - 1)
				count = count - 1
			end

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

	table.insert( PProtect_Notes, curmsg )

end )

-- OWNER
net.Receive( "sendOwner", function( len )
    
	Owner = net.ReadEntity()

end )