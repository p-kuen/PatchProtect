function sv_PProtect.isBuddy (source, buddy)

	if source.Buddies != nil then
		print("checking started...")
		table.foreach( source.Buddies, function(k,v)
			print("checking" .. v["uniqueid"])
			if buddy:UniqueID() == v["uniqueid"] then
				return true
			end

		end)
		print("checking finished!")
	end
	print("nothing found!")
	return false
end