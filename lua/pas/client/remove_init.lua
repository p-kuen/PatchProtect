AddCSLuaFile( "Remove_Init.lua" )
function RemovePlyProps()
	RunConsoleCommand( "gmod_cleanup" )
end
concommand.Add( "cleanupmyprops", RemovePlyProps )