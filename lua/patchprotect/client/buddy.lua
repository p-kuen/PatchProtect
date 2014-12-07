--------------------------
--  BUDDY SQL SETTINGS  --
--------------------------

if !sql.TableExists( "pprotect_buddies" ) then

	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies( 'uniqueid' TEXT, 'nick' TEXT, 'permission' TEXT )" )
	
	MsgC(
		Color(50, 240, 0),
		"[PatchProtect] Created new Buddy-Table\n"
	)

end

function cl_PProtect.resetBuddySettings()

	-- Delete whole Buddy-List
	sql.Query( "DROP TABLE pprotect_buddies" )
	-- Create new clear Buddy-List
	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies( 'uniqueid' TEXT, 'nick' TEXT, 'permission' TEXT )" )

	cl_PProtect.Buddy.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" )
	cl_PProtect.UpdateMenus()
	cl_PProtect.ClientNote( "Cleared Buddy-List", "info" )

end



-------------------
--  SET BUDDIES  --
-------------------

function sendBuddiesToServer( buddies )

	buddies = buddies or {}

	net.Start( "pprotect_send_buddy" )
		net.WriteTable( buddies )
	net.SendToServer()

end

-- ADD BUDDY
function cl_PProtect.AddBuddy( newBuddy )

	local valid = false

	table.foreach( newBuddy.permissions, function( name, checked )

		if checked then valid = true end

	end )

	if !valid then
		cl_PProtect.ClientNote( "Please select a permission first!", "normal" )
		return
	end

	local me = LocalPlayer()

	sql.Query( "INSERT INTO pprotect_buddies( 'uniqueid', 'nick', 'permission' ) VALUES( '" .. newBuddy.player:UniqueID() .. "', '" .. newBuddy.player:Nick() .. "', '" .. table.concat( table.KeysFromValue( newBuddy.permissions, true ),", " ) .. "' )" )
	
	me.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" )
	
	sendBuddiesToServer( me.Buddies )

	-- Send message to other player
	net.Start( "pprotect_send_other_buddy" )
		net.WriteString( tostring( newBuddy.player:UniqueID() ) )
	net.SendToServer()
	
	cl_PProtect.ClientNote( "Added " .. newBuddy.player:Nick() .. " to the Buddy-List!", "info" )
	cl_PProtect.UpdateMenus()

end

-- DELETE BUDDY
function cl_PProtect.DeleteBuddy( buddy )

	if !buddy then return end
	local me = LocalPlayer()

	sql.Query( "DELETE FROM pprotect_buddies WHERE uniqueid = '" .. buddy.uniqueid .. "'" )
	me.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" )

	sendBuddiesToServer( me.Buddies )

	cl_PProtect.ClientNote( "Deleted " .. buddy.nick .. " from the Buddy-List!", "info" )
	cl_PProtect.UpdateMenus()
	
end

-- IF PLAYER JOINS THE SERVER -> SEND BUDDIES
function cl_PProtect.OnPlayerBuddyIPE()

	LocalPlayer().Buddies = sql.Query( "SELECT * FROM pprotect_buddies" )
	if !LocalPlayer().Buddies then return end

end
hook.Add( "InitPostEntity", "PlayerBuddyIPE", cl_PProtect.OnPlayerBuddyIPE )
