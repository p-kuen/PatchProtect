--------------------------
--  BUDDY SQL SETTINGS  --
--------------------------

function cl_PProtect.SetupBuddySettings()

	sql.Query( "DROP TABLE pprotect_buddies" )

	if !sql.TableExists( "pprotect_buddies" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies('steamid' TEXT, 'nick' TEXT, 'option' TEXT);" )
		
		MsgC(
			Color(50, 240, 0),
			"[PatchProtect] Created new Buddy-Table\n"
		)

	end
	
end

cl_PProtect.SetupBuddySettings()

cl_PProtect.Buddies = sql.Query("SELECT * FROM pprotect_buddies")

cl_PProtect.Buddy = {}
cl_PProtect.Buddy.RowType = {}
cl_PProtect.Buddy.CurrentBuddy = {}

function cl_PProtect.Save_B( ply, cmd, args )

	
	print("current buddy:")
	PrintTable(cl_PProtect.Buddy.CurrentBuddy)
	print("current permissions:")
	PrintTable(cl_PProtect.Buddy.RowType)
	print("SAVED BUDDY!")
	

end
concommand.Add("btn_addbuddy", cl_PProtect.Save_B )

function cl_PProtect.buddy_manager( ply, cmd, args )

	print("OPENING!")

end
concommand.Add("btn_buddy", cl_PProtect.buddy_manager )