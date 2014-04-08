--------------------------
--  BUDDY SQL SETTINGS  --
--------------------------

function cl_PProtect.SetupBuddySettings()

	--For debug
	--sql.Query( "DROP TABLE pprotect_buddies" )

	if !sql.TableExists( "pprotect_buddies" ) then

		sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies('uniqueid' TEXT, 'nick' TEXT, 'permission' TEXT);" )
		
		MsgC(
			Color(50, 240, 0),
			"[PatchProtect] Created new Buddy-Table\n"
		)

	end
	
end

function cl_PProtect.resetBuddyVariables(type)

	if type == "add" then
		cl_PProtect.Buddy.RowType =
		{
			use = false,
			physgun = false,
			toolgun = false,
			damage = false
		}
		
		if cl_PProtect.Buddy.CurrentBuddy == nil then
			cl_PProtect.Buddy.CurrentBuddy = {}
		else
			table.Empty(cl_PProtect.Buddy.CurrentBuddy)
		end
	elseif type == "delete" then

		if cl_PProtect.Buddy.BuddyToRemove == nil then
			cl_PProtect.Buddy.BuddyToRemove = {}
		else
			table.Empty(cl_PProtect.Buddy.BuddyToRemove)
		end
		
	end

end

function cl_PProtect.sendBuddies(buddytable)
	
	net.Start("PProtect_sendBuddy")
        net.WriteTable(buddytable)
    net.SendToServer()
	
end

cl_PProtect.SetupBuddySettings()

cl_PProtect.Buddy = {}
cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies") or {}

cl_PProtect.resetBuddyVariables("add")
cl_PProtect.resetBuddyVariables("delete")


function cl_PProtect.Save_B( ply, cmd, args )

	ply.Buddies = ply.Buddies or {}
	sql.Query( "INSERT INTO pprotect_buddies('uniqueid', 'nick', 'permission' ) VALUES( '" .. cl_PProtect.Buddy.CurrentBuddy[0] .. "', '" .. cl_PProtect.Buddy.CurrentBuddy[1] .. "', '"..table.concat( table.KeysFromValue( cl_PProtect.Buddy.RowType, "true" ),", " ).."')" )
	
	cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies")

	cl_PProtect.sendBuddies(cl_PProtect.Buddy.Buddies)

	cl_PProtect.Info( "Added new buddy!" )

	net.Start("PProtect_sendOther")
		net.WriteString(tostring(cl_PProtect.Buddy.CurrentBuddy[0]))
	net.SendToServer()
	
	cl_PProtect.UpdateMenus()
	cl_PProtect.resetBuddyVariables("add")
	

end
concommand.Add("btn_addbuddy", cl_PProtect.Save_B )

function cl_PProtect.Delete_B( ply, cmd, args )

	ply.Buddies = ply.Buddies or {}
	sql.Query( "DELETE FROM pprotect_buddies WHERE uniqueid = '" .. cl_PProtect.Buddy.BuddyToRemove[0] .. "'" )
	
	cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies")

	if cl_PProtect.Buddy.Buddies == nil then
		cl_PProtect.Buddy.Buddies = {}
	end

	cl_PProtect.sendBuddies(cl_PProtect.Buddy.Buddies)

	cl_PProtect.Info( "Deleted buddy!" )
	cl_PProtect.UpdateMenus()

	cl_PProtect.resetBuddyVariables("delete")
	

end
concommand.Add("btn_deletebuddy", cl_PProtect.Delete_B )

function cl_PProtect.OnPlayerBuddyIPE()

	cl_PProtect.sendBuddies(cl_PProtect.Buddy.Buddies)
end
hook.Add( "InitPostEntity", "PlayerBuddyIPE", cl_PProtect.OnPlayerBuddyIPE )