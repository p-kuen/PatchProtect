-------------------
--  CHECK BUDDY  --
-------------------

function sv_PProtect.IsBuddy( ply, bud, mode )

	if !ply or !ply.Buddies or !ply.Buddies[ bud:SteamID() ] or !ply.Buddies[ bud:SteamID() ].bud then return false end
	if !mode and ply.Buddies[ bud:SteamID() ].bud == true then return true end
	if ply.Buddies[ bud:SteamID() ].bud == true and ply.Buddies[ bud:SteamID() ].perm[ mode ] == true then return true else return false end

end



--------------------
--  SEND BUDDIES  --
--------------------

-- SEND BUDDY
net.Receive( "pprotect_buddy", function( len, ply )

	ply.Buddies = net.ReadTable()

end )

-- NOTIFICATION
net.Receive( "pprotect_info_buddy", function( len, ply )

	local bud = net.ReadEntity()
	sv_PProtect.Notify( bud, ply:Nick() .. " added you as a buddy!", "normal" )

end )
