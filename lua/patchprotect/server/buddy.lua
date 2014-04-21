-------------------
--  CHECK BUDDY  --
-------------------

function sv_PProtect.isBuddy( source, buddy, mode )

	if source == nil or buddy == nil then return false end

	local isBuddy = false
	if source.Buddies != nil then

		table.foreach( source.Buddies, function( k, v )
			
			if buddy:UniqueID() == v["uniqueid"] then
				if string.match( v["permission"], mode ) then
					isBuddy = true;
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
net.Receive( "send_buddy", function( len, ply )

	ply.Buddies = net.ReadTable() or {}

end )

-- NOTIFICATION
net.Receive( "send_other_buddy", function( len, ply )

	local text = net.ReadString()

	net.Start( "PProtect_Notify" )
		net.WriteString( ply:Nick() .. " added you as a buddy!" )
	net.Send( player.GetByUniqueID( tostring(text) ) )

end )
