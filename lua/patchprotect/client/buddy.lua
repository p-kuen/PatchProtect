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



-------------------
--  SET BUDDIES  --
-------------------

-- CHANGE TABLES
function cl_PProtect.SetBuddyVars( type )

	if type == "add" then

		cl_PProtect.Buddy.RowType = {
			use = false,
			physgun = false,
			toolgun = false,
			damage = false,
			property = false
		}
		
		if cl_PProtect.Buddy.CurrentBuddy == nil then
			cl_PProtect.Buddy.CurrentBuddy = {}
		else
			table.Empty( cl_PProtect.Buddy.CurrentBuddy )
		end

	elseif type == "delete" then

		if cl_PProtect.Buddy.BuddyToRemove == nil then
			cl_PProtect.Buddy.BuddyToRemove = {}
		else
			table.Empty( cl_PProtect.Buddy.BuddyToRemove )
		end
		
	end

end

-- SEND BUDDIES
function cl_PProtect.sendBuddies( buddytable )
	
	net.Start( "send_Buddy" )
        net.WriteTable( buddytable )
    net.SendToServer()
	
end

cl_PProtect.SetupBuddySettings()

cl_PProtect.Buddy = {}
cl_PProtect.Buddy.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" ) or {}

cl_PProtect.SetBuddyVars( "add" )
cl_PProtect.SetBuddyVars( "delete" )

-- ADD BUDDY
net.Receive( "add_buddy", function( len, pl )

	ply.Buddies = ply.Buddies or {}
	sql.Query( "INSERT INTO pprotect_buddies('uniqueid', 'nick', 'permission' ) VALUES( '" .. cl_PProtect.Buddy.CurrentBuddy[0] .. "', '" .. cl_PProtect.Buddy.CurrentBuddy[1] .. "', '"..table.concat( table.KeysFromValue( cl_PProtect.Buddy.RowType, "true" ),", " ).."')" )
	
	cl_PProtect.Buddy.Buddies = sql.Query("SELECT * FROM pprotect_buddies")

	cl_PProtect.sendBuddies( cl_PProtect.Buddy.Buddies )

	cl_PProtect.Info( "Added new buddy!" )

	net.Start( "send_other_buddy" )
		net.WriteString( tostring( cl_PProtect.Buddy.CurrentBuddy[0] ) )
	net.SendToServer()
	
	cl_PProtect.UpdateMenus()
	cl_PProtect.SetBuddyVars( "add" )
	

end )

-- DELETE BUDDY
net.Receive( "delete_buddy", function( len, pl )

	ply.Buddies = ply.Buddies or {}
	sql.Query( "DELETE FROM pprotect_buddies WHERE uniqueid = '" .. cl_PProtect.Buddy.BuddyToRemove[0] .. "'" )
	
	cl_PProtect.Buddy.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" )

	if cl_PProtect.Buddy.Buddies == nil then
		cl_PProtect.Buddy.Buddies = {}
	end

	cl_PProtect.sendBuddies( cl_PProtect.Buddy.Buddies )

	cl_PProtect.Info( "Deleted buddy!" )
	cl_PProtect.UpdateMenus()

	cl_PProtect.SetBuddyVars( "delete" )
	
end )

-- IF PLAYER JOINS THE SERVER -> SEND BUDDIES
function cl_PProtect.OnPlayerBuddyIPE()

	cl_PProtect.sendBuddies( cl_PProtect.Buddy.Buddies )
end
hook.Add( "InitPostEntity", "PlayerBuddyIPE", cl_PProtect.OnPlayerBuddyIPE )