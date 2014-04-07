function sv_PProtect.isBuddy (source, buddy)
	local isBuddy = false
	if source.Buddies != nil then
		print("checking started...")
		table.foreach( source.Buddies, function(k,v)
			print("comparing ".. buddy:UniqueID().. " with " .. v["uniqueid"])
			if buddy:UniqueID() == v["uniqueid"] then
				print("BUDDY!")
				isBuddy = true;
			end

		end)
		print("checking finished!")
	end
	print("nothing found!")
	if isBuddy then
		return true
	else
		return false
	end
end

net.Receive("buddySend", function(len, ply)

	ply.Buddies = net.ReadTable() or {}

end)