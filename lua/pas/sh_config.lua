PAS = PAS or {}


--Return if Table esists

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

PAS.ConVars.PAS_ANTISPAM_tools = {}

function sv_PP.createToolTable()

	if not PAS.ConVars then
		PAS.ConVars = {}
	end

	if PAS.ConVars.PAS_ANTISPAM_tools[1] ~= nil then
		return
	end

	for _, wep in pairs( weapons.GetList() ) do

		if wep.ClassName == "gmod_tool" then 
			local t = wep.Tool
			for name, tool in pairs( t ) do
				table.insert(PAS.ConVars.PAS_ANTISPAM_tools, tostring(name))
			end
		end
	end

	for p, cvar in pairs(PAS.ConVars) do

		for k, v in pairs( cvar ) do
			--CreateConVar( "_" .. p .. "_" .. v, 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED} )
			if p == "PAS_ANTISPAM_tools" then
				CreateClientConVar("_" .. p .. "_" .. v, 0, false, true)
				
			end
			
		end
	
	end

end

--Create ConVars

for p, cvar in pairs(PAS.ConVars) do

	for k, v in pairs( cvar ) do
		if type(k) == "number" then
			CreateConVar( "_" .. p .. "_" .. v, 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED} )
		else
			CreateConVar( "_" .. p .. "_" .. k, v, {FCVAR_ARCHIVE, FCVAR_REPLICATED} )
		end

	end
	
end
--CreateConVar( "_PatchProtect_PropProtection_" .. "UsePP", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED} )
