local function Test()
	local str = net.ReadString() -- Here, we read the string that was sent from the server
	chat.AddText( str ) -- And here we print it to the chat
end

net.Receive( "test", Test )