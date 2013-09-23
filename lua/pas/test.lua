util.AddNetworkString( "test" ) -- Cache the net message.

local function Test( ply )
	net.Start( "test" )
	net.WriteString( "Hello, your name is: " .. ply:Nick() )
	net.Send( ply )
end

hook.Add( "PlayerInitialSpawn", "Test", Test )