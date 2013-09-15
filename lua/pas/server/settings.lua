PAS = PAS or {}

local savecount = 0

function PAS.SetupSettings()

	MsgC(
		Color(0,235,200),
		"\n[PatchAntiSpam]"
	)

	MsgC(
		Color(255,255,255),
		" Successfully loaded (Coded by Patcher56 & Ted894)\n\n"
	)

	if sql.TableExists("patchantispam") then

		--Check Table
		local checktable = sql.Query("SELECT toolprotection from patchantispam")

		if checktable == false then

			sql.Query("DROP TABLE patchantispam")
			MsgC(
				Color(235, 0, 0), 
				"[PatchAntiSpam] Deleted the old Settings - Table\n"
			)

		end

	end

	if ( !sql.TableExists("patchantispam") ) then
		
		local options = {}
		local values = {}
		local sqlvars = {}

		for Protection, ConVars in pairs(PAS.ConVars) do

			for Option, value in pairs(ConVars) do

				local Type = type(PAS.ConVars.PAS_ANTISPAM[Option])

				if Type == "number" then

					local isDecimal
					if tonumber(value) > math.floor(tonumber(value)) then isDecimal = true else isDecimal = false end
					if  not isDecimal then Type = string.gsub(Type, "number", "INTEGER") else Type = string.gsub(Type, "number", "DOUBLE") end
					
				end

				Type = string.gsub(Type, "string", "VARCHAR(255)")

				if Option == "spamcount" or Option == "cooldown" then

					table.insert(sqlvars, tostring(Option) .. " " .. Type)

				else

					table.insert(sqlvars, tostring(Option) .. " " .. Type)
					

				end
				if value == "" then
					table.insert(values, "''")
					table.insert(options, "'" .. Option .. "'")
				else
					table.insert(values, value)
					table.insert(options, Option)
				end
				
			end
		end
		sql.Query("CREATE TABLE IF NOT EXISTS patchantispam(" .. table.concat( sqlvars, ", " ) .. ");")

		sql.Query("INSERT INTO patchantispam(" .. table.concat( options, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")") --
		
		MsgC(
			Color(0, 240, 100),
			"[PatchAntiSpam] Created new Settings - Table\n"
			)

	end
	
	return sql.QueryRow("SELECT * FROM patchantispam LIMIT 1")
end

PAS.Settings = PAS.SetupSettings()

function PAS.ApplySettings(ply, cmd, args)
	
	if !ply then
		PAS.InfoNotify(ply, "This command can only be run in-game!")
	end

	if (!ply:IsAdmin()) then
		return
	end
	
	if args[1] != nil then

		local number = GetConVar("_PAS_ANTISPAM_"..args[1]):GetFloat()

		local text = GetConVar("_PAS_ANTISPAM_"..args[1]):GetString()

		if text != 0 and number == 0 then
			sql.Query("UPDATE patchantispam SET '" .. args[1] .. "' = '" .. text .. "'")
		else
			sql.Query("UPDATE patchantispam SET " .. args[1] .. " = " .. number)
		end

	end

end

concommand.Add("PAS_SetSettings", PAS.ApplySettings)

function PAS.CCV(ply, cmd, args)
	RunConsoleCommand("_PAS_ANTISPAM_" .. args[1], args[2])
	
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