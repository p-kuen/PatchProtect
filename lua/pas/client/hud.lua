PAS = PAS or {}

local HUDInfoNote_c = 0
local HUDInfoNotes = {}

local HUDAdminNote_c = 0
local HUDAdminNotes = {}

local HUDNote_c = 0
local HUDNotes = {}


--Info Messages:

function PAS.AddInfoNotify( str )

	local tab = {}
	tab.text 	= str
	tab.recv 	= SysTime()

	table.insert( HUDInfoNotes, tab )
	HUDInfoNote_c = HUDInfoNote_c + 1

	LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 10, 100)

end
usermessage.Hook("PAS_InfoNotify", function(u) PAS.AddInfoNotify(u:ReadString()) end)


--Admin Messages:

function PAS.AddAdminNotify( str )

	local tab = {}
	tab.text 	= str
	tab.recv 	= SysTime()

	if (LocalPlayer():IsAdmin()) then

		table.insert( HUDAdminNotes, tab )
		HUDAdminNote_c = HUDAdminNote_c + 1

	end

	LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 10, 100)

end
usermessage.Hook("PAS_AdminNotify", function(u) PAS.AddAdminNotify(u:ReadString()) end)


--Default Messages:

function PAS.AddNotify( str )

	local tab = {}
	tab.text 	= str
	tab.recv 	= SysTime()

	table.insert( HUDNotes, tab )
	HUDNote_c = HUDNote_c + 1

	LocalPlayer():EmitSound("npc/turret_floor/click1.wav", 10, 100)

end
usermessage.Hook("PAS_Notify", function(u) PAS.AddNotify(u:ReadString()) end)


--Create Info Message:

local function DrawInfoNotice( self, k, v, i )

	local text = v.text
	surface.SetFont("DermaDefaultBold")
	local tsW, tsH = surface.GetTextSize(text)
	
	local w = tsW+20
	local h = tsH+15
	local x = ScrW()-w-15
	local y = ScrH()-h-85
	local col = Color(128, 255, 0, 200)
	
	local xtext = (x+w-10)
	local ytext = (y+(h/2))
	local coltext = Color(0, 0, 0, 255)
	
	draw.RoundedBox( 4, x, y, w, h, col )
	draw.SimpleText( text, "DermaDefaultBold", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end


--Create Admin Message:

local function DrawAdminNotice( self, k, v, i )

	local text = v.text
	surface.SetFont("DermaDefaultBold")
	local tsW, tsH = surface.GetTextSize(text)
	
	local w = tsW+20
	local h = tsH+15
	local x = ScrW()-w-15
	local y = ScrH()-h-50
	local col = Color(176, 0, 0, 200)
	
	local xtext = (x+w-10)
	local ytext = (y+(h/2))
	local coltext = Color(0, 0, 0, 255)
	
	draw.RoundedBox( 4, x, y, w, h, col )
	draw.SimpleText( text, "DermaDefaultBold", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end


--Create Default Message:

local function DrawNotice( self, k, v, i )

	local text = v.text
	surface.SetFont("DermaDefaultBold")
	local tsW, tsH = surface.GetTextSize(text)

	local w = tsW+20
	local h = tsH+15
	local x = ScrW()-w-15
	local y = ScrH()-h-15
	local col = Color(88, 144, 222, 200)
	
	local xtext = (x+w-10)
	local ytext = (y+(h/2))
	local coltext = Color(0, 0, 0, 255)
	
	draw.RoundedBox( 4, x, y, w, h, col )
	draw.SimpleText( text, "DermaDefaultBold", xtext, ytext, coltext, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

end

local function Paint()

	--Set Player
	local player = LocalPlayer()

	--Show normal Messages
	if not HUDNotes then return end

	local i = 0

	for k, v in pairs(HUDNotes) do

		if v ~= 0 then

			i = i + 1
			DrawNotice( self, k, v, i)

		end

	end


	--Delete normal Messages

	for k, v in pairs(HUDNotes) do

		local ShowNotify

		if v ~= 0 and v.recv + 6 < SysTime() then
			ShowNotify = true
		else
			ShowNotify = false
		end

		if ShowNotify then

			HUDNotes[ k ] = 0

			if HUDNote_c > 0 then

				HUDNote_c = HUDNote_c - 1

			end

			if (HUDNote_c < 1) then HUDNotes = {} end

		end

		if HUDNote_c > 1 then

			HUDNotes[ 1 ] = 0
			table.remove(HUDNotes, 1)
			HUDNote_c = 1

		end

	end


	--Show Info Messages

	if not HUDInfoNotes then return end

	local a_i = 0

	for k, v in pairs(HUDInfoNotes) do

		if v ~= 0 then

			a_i = a_i + 1
			DrawInfoNotice( self, k, v, i)

		end

	end


	--Delete Info Messages

	for k, v in pairs(HUDInfoNotes) do

		local ShowInfoNotify

		if v ~= 0 and v.recv + 6 < SysTime() then
			ShowInfoNotify = true
		else
			ShowInfoNotify = false
		end

		if ShowInfoNotify then

			HUDInfoNotes[ k ] = 0

			if HUDInfoNote_c > 0 then

				HUDInfoNote_c = HUDInfoNote_c - 1

			end

			if (HUDInfoNote_c < 1) then HUDInfoNotes = {} end

		end

		if HUDInfoNote_c > 1 then

			HUDInfoNotes[ 1 ] = 0
			table.remove(HUDInfoNotes, 1)
			HUDInfoNote_c = 1

		end

	end


	--Show Admin Messages

	if not HUDAdminNotes then return end

	local a_i = 0

	for k, v in pairs(HUDAdminNotes) do

		if v ~= 0 then

			a_i = a_i + 1
			DrawAdminNotice( self, k, v, i)

		end

	end


	--Delete Admin Messages

	for k, v in pairs(HUDAdminNotes) do

		local ShowAdminNotify

		if v ~= 0 and v.recv + 6 < SysTime() then
			ShowAdminNotify = true
		else
			ShowAdminNotify = false
		end

		if ShowAdminNotify then

			HUDAdminNotes[ k ] = 0

			if HUDAdminNote_c > 0 then

				HUDAdminNote_c = HUDAdminNote_c - 1

			end

			if (HUDAdminNote_c < 1) then HUDAdminNotes = {} end

		end

		if HUDAdminNote_c > 1 then

			HUDAdminNotes[ 1 ] = 0
			table.remove(HUDAdminNotes, 1)
			HUDAdminNote_c = 1

		end
	end

end
hook.Add("HUDPaint", "RoundedBoxHud", Paint)