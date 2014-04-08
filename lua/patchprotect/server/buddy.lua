function sv_PProtect.isBuddy( source, buddy, type )

	if source == nil or buddy == nil then return false end
	local isBuddy = false
	if source.Buddies != nil then
		table.foreach( source.Buddies, function( k, v )
			if buddy:UniqueID() == v["uniqueid"] then
				if string.match(v["permission"], type) then

					isBuddy = true;
				end
			end

		end)
	end
	if isBuddy then
		return true
	else
		return false
	end
end

net.Receive("PProtect_sendBuddy", function(len, ply)

	ply.Buddies = net.ReadTable() or {}

end)

net.Receive("PProtect_sendOther", function(len, ply)

	local text = net.ReadString()

	net.Start("PProtect_Notify")
		net.WriteString(ply:Nick() .. " added you as a buddy!")
	net.Send(player.GetByUniqueID( tostring(text) ))

end)
