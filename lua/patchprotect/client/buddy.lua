--------------------------
--  BUDDY SQL SETTINGS  --
--------------------------

function cl_PProtect.SetupBuddySettings()

	sql.Query( "DROP TABLE pprotect_buddies" )

	if !sql.TableExists( "pprotect_buddies" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies('uniqueid' TEXT, 'nick' TEXT, 'permission' TEXT);" )
		
		MsgC(
			Color(50, 240, 0),
			"[PatchProtect] Created new Buddy-Table\n"
		)

	end
	
end

cl_PProtect.SetupBuddySettings()

cl_PProtect.Buddy = {}
cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies")
cl_PProtect.Buddy.RowType =
{
	use = false,
	physgun = false,
	toolgun = false,
	damage = false
}
cl_PProtect.Buddy.CurrentBuddy = {}

function cl_PProtect.sendBuddies(buddytable)
	net.Start("buddySend")
        net.WriteTable(buddytable)
    net.SendToServer()
end

function cl_PProtect.Save_B( ply, cmd, args )

	ply.Buddies = ply.Buddies or {}
	sql.Query( "INSERT INTO pprotect_buddies('uniqueid', 'nick', 'permission' ) VALUES( '" .. cl_PProtect.Buddy.CurrentBuddy[0] .. "', '" .. cl_PProtect.Buddy.CurrentBuddy[1] .. "', '"..table.concat( table.KeysFromValue( cl_PProtect.Buddy.RowType, "true" ),", " ).."')" )
	
	cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies")

	cl_PProtect.sendBuddies(cl_PProtect.Buddy.Buddies)

	cl_PProtect.Info( "Added new buddy!" )
	cl_PProtect.UpdateMenus()
	

end
concommand.Add("btn_addbuddy", cl_PProtect.Save_B )