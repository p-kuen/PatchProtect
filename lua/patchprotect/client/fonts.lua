local fonts = {}
function cl_PProtect.setFont( f, s, b, a, sh, sy )

	b, a, sh, sy = b or 500, a or false, sh or false, sy or false
	local fstr = "pprotect_" .. f .. "_" .. tostring( s ) .. "_" .. tostring( b ) .. "_" .. string.sub( tostring( a ), 1, 1 ) .. "_" .. string.sub( tostring( sh ), 1, 1 )

	if table.HasValue( fonts, fstr ) then return fstr end

	surface.CreateFont( fstr, {
		font = f,
		size = s,
		weight = b,
		antialias = a,
		shadow = sh,
		symbol = sy
	} )

	table.insert( fonts, fstr )

	return fstr

end
