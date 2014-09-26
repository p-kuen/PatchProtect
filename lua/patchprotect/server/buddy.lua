-------------------
--  CHECK BUDDY  --
-------------------

function sv_PProtect.isBuddy( source, buddy, mode )

	if !source or !buddy then return false end

	local isBuddy = false
	if source.Buddies != nil then

		table.foreach( source.Buddies, function( k, b )
			
			if buddy:UniqueID() == b.uniqueid then
				if string.match( b.permission, mode ) then
					isBuddy = true
				end
			end

		end )

	end

	if isBuddy then return true else return false end

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
	sv_PProtect.Notify( player.GetByUniqueID( tostring( uid ) ), ply:Nick() .. " added you as a buddy!", "normal" )

end )
