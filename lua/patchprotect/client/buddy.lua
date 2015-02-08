--------------------------
--  BUDDY SQL SETTINGS  --
--------------------------

-- LOAD BUDDIES WHEN JOINED THE SERVER
local function loadBuddies()

	cl_PProtect.Buddies = sql.Query( "SELECT * FROM pprotect_buddies" ) or {}

end
hook.Add( "InitPostEntity", "pprotect_load_buddies", loadBuddies )

-- CREATE NEW BUDDY TABLE
local function createTable()

	sql.Query( "CREATE TABLE IF NOT EXISTS pprotect_buddies( uniqueid TEXT, nick TEXT, permission TEXT )" )
	loadBuddies()
	MsgC( Color( 50, 240, 0 ), "[PatchProtect] Created new Buddy-Table\n" )

end
if !sql.TableExists( "pprotect_buddies" ) then createTable() end

-- RESET BUDDIES
concommand.Add( "pprotect_reset_buddies", function()

	sql.Query( "DROP TABLE pprotect_buddies" )
	createTable()

	print( "[PProtect-Buddy] Successfully deleted all Buddies!" )

end )



-------------------
--  SET BUDDIES  --
-------------------

local function sendBuddy( buddies )

	buddies = buddies or {}

	net.Start( "pprotect_send_buddy" )
		net.WriteTable( buddies )
	net.SendToServer()

end

-- ADD BUDDY
function cl_PProtect.addBuddy( newBuddy )

	-- Check permissions
	if !table.HasValue( newBuddy.permissions, true ) then
		cl_PProtect.ClientNote( "Please select a permission first!", "normal" )
		return
	end

	sql.Query( "INSERT INTO pprotect_buddies( uniqueid, nick, permission ) VALUES( '" .. newBuddy.player:UniqueID() .. "', '" .. newBuddy.player:Nick() .. "', '" .. table.concat( table.KeysFromValue( newBuddy.permissions, true ), ", " ) .. "' )" )

	loadBuddies()
	sendBuddy( cl_PProtect.Buddies )

	-- Send message to other player
	net.Start( "pprotect_send_other_buddy" )
		net.WriteString( tostring( newBuddy.player:UniqueID() ) )
	net.SendToServer()

	cl_PProtect.ClientNote( "Added " .. newBuddy.player:Nick() .. " to the Buddy-List!", "info" )
	cl_PProtect.UpdateMenus()

end

-- DELETE BUDDY
function cl_PProtect.deleteBuddy( buddy )

	if !buddy then return end

	sql.Query( "DELETE FROM pprotect_buddies WHERE uniqueid = '" .. buddy.uniqueid .. "'" )

	loadBuddies()
	sendBuddy( cl_PProtect.Buddies )

	cl_PProtect.ClientNote( "Deleted " .. buddy.nick .. " from the Buddy-List!", "info" )
	cl_PProtect.UpdateMenus()

end
