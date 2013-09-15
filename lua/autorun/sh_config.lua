PAS = PAS or {}

if PAS.ConVars then
	return
end

--Create ConVars-Table
PAS.ConVars = {}

--Put all Variables into the ConVar-Table
PAS.ConVars.PAS_ANTISPAM = {
	use = 1,
	cooldown = 3.5,
	noantiadmin = 1,
	spamcount = 20,
	spamaction = 0,
	bantime = 10.5,
	concommand = "",
	toolprotection = 1
}

--Create ConVars
for Protection, ConVars in pairs(PAS.ConVars) do

	for Option, value in pairs(ConVars) do
		CreateConVar( "_" .. Protection .. "_" .. Option, value, {FCVAR_ARCHIVE, FCVAR_REPLICATED} )
	end
	
end