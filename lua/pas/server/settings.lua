PAS = PAS or {}
local savecount = 0

function PAS.SetupSettings()
	MsgC(
		Color(0,235,200),
		"==================================================\n",
		"[PatchAntiSpam] Successfully loaded\n",
		"==================================================\n"
	)
	if sql.TableExists("patchantispam") then
		local testquery = sql.Query("SELECT " .. tostring(table.GetLastKey(PAS.ConVars.PAS_ANTISPAM) .. "from patchantispam")
		if testquery == false then
			sql.Query("DROP TABLE patchantispam")
			MsgC(
				Color(235, 0, 0), 
				"==================================================\n",
				"[PatchAntiSpam] Deleted the old settings-table\n",
				"==================================================\n"
				)
		end
	end
	
	if(!sql.TableExists("patchantispam")) then
		sql.Query("CREATE TABLE IF NOT EXISTS patchantispam(use INTEGER, cooldown DOUBLE NOT NULL, noantiadmin INTEGER, spamcount INTEGER NOT NULL, spamaction INTEGER, bantime DOUBLE, concommand varchar(255), toolprotection INTEGER);")
		sql.Query("INSERT INTO patchantispam(use, cooldown, noantiadmin, spamcount, spamaction, bantime, 'concommand', toolprotection) VALUES(" .. table.concat( PAS.ConVars.PAS_ANTISPAM, ", " ) .. ")") --1, 3, 1, 20, 0, 10, '', 1
		MsgC(
			Color(0, 240, 100),
			"==================================================\n",
			"[PatchAntiSpam] Created new settings-table\n",
			"==================================================\n"
			)

	end
	
	return sql.QueryRow("SELECT * FROM patchantispam LIMIT 1")
end
PAS.Settings = PAS.SetupSettings()
PrintTable(PAS.Settings)
function PAS.ApplySettings(ply, cmd, args)
	
	if !ply then
		PAS.InfoNotify(ply, "This command can only be run in-game!")
	end
	if(!ply:IsAdmin()) then
		return
	end

	--We should delete this
	--[[
	local use = GetConVarNumber("_PAS_ANTISPAM_use")
	local cooldown = GetConVarNumber("_PAS_ANTISPAM_cooldown")
	local noantiadmin = GetConVarNumber("_PAS_ANTISPAM_noantiadmin")
	local spamcount = GetConVarNumber("_PAS_ANTISPAM_spamcount")
	local spamaction = GetConVarNumber("_PAS_ANTISPAM_spamaction")
	local bantime = GetConVarNumber("_PAS_ANTISPAM_bantime")
	local concommand = GetConVarString("_PAS_ANTISPAM_concommand")

	sql.Query("UPDATE patchantispam SET use = "..use..", cooldown = "..cooldown..", noantiadmin = "..noantiadmin..", spamcount = "..spamcount..", spamaction = "..spamaction..", bantime = "..bantime..", concommand = '"..concommand.."'")
	sql.Query("UPDATE patchantispam SET noantiadmin = "..noantiadmin)
	]]

	--print("saving: " .. args[1] .. " value: " .. GetConVarNumber("_PAS_ANTISPAM_"..args[1]))
	
	if args[1] != nil then
		local number = GetConVar("_PAS_ANTISPAM_"..args[1]):GetFloat()
		local text = GetConVar("_PAS_ANTISPAM_"..args[1]):GetString()

		if text != 0 and number == 0 then
			sql.Query("UPDATE patchantispam SET '" .. args[1] .. "' = '" .. text .. "'")
		else
			sql.Query("UPDATE patchantispam SET " .. args[1] .. " = " .. number)
		end
		--[[
		if args[1] == "concommand" then
			sql.Query("UPDATE patchantispam SET " .. args[1] .. " = " .. GetConVarNumber("_PAS_ANTISPAM_"..args[1]))
		else
			sql.Query("UPDATE patchantispam SET " .. args[1] .. " = " .. GetConVarNumber("_PAS_ANTISPAM_"..args[1]))
		end
		]]
	end
	
	--print("Anzahl: "..sql.QueryValue( "SELECT count(*) from patchantispam LIMIT 1" ))

end
concommand.Add("PAS_SetSettings", PAS.ApplySettings)

function PAS.CCV(ply, cmd, args)
	
	RunConsoleCommand("_PAS_ANTISPAM_" ..args[1], args[2])
	
	RunConsoleCommand("PAS_SetSettings", args[1])
	

	savecount = savecount + 1
	if savecount == table.Count(PAS.Settings) then
		savecount = 0
		timer.Simple(0.1, function()
			PAS.Settings = sql.QueryRow("SELECT * FROM patchantispam LIMIT 1")
			PAS.InfoNotify(ply, "Settings saved!")
			
		end)
	end
end
concommand.Add("PAS_ChangeConVar", PAS.CCV)

function PAS.InfoNotify(ply, text)
	umsg.Start("PAS_InfoNotify", ply)
		umsg.String(text)
	umsg.End()
end
function PAS.AdminNotify(text)
	umsg.Start("PAS_AdminNotify")
		umsg.String(text)
	umsg.End()
end
function PAS.Notify(ply, text)
	umsg.Start("PAS_Notify", ply)
		umsg.String(text)
	umsg.End()
end