-------------------
--  CHECK BUDDY  --
-------------------

function sv_PProtect.isBuddy( source, buddy, mode )

	if !source or !buddy then return false end
	if source.Buddies == nil then return end
	local isBuddy = false

	table.foreach( source.Buddies, function( k, b )

		if buddy:UniqueID() == b.uniqueid and string.match( b.permission, mode ) then isBuddy = true end

	end )

	return isBuddy

end



--------------------
--  SEND BUDDIES  --
--------------------

-- SEND BUDDY
net.Receive( "pprotect_send_buddy", function( len, ply )

	ply.Buddies = net.ReadTable() or {}

end )

-- NOTIFICATION
net.Receive( "pprotect_send_other_buddy", function( len, ply )

	local uid = net.ReadString()
	sv_PProtect.Notify( player.GetByUniqueID( uid ), ply:Nick() .. " added you as a buddy!", "normal" )

end )
