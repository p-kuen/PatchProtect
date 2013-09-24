PAS = PAS or {}
PAS.Settings = PAS.Settings or {}

function PAS.SetupGeneralSettings()

	MsgC(
		Color(0,235,200),
		"\n[PatchAntiSpam]"
	)

	MsgC(
		Color(255,255,255),
		" Successfully loaded (Coded by Patcher56 & Ted894)\n\n"
	)

	--Networks
	util.AddNetworkString( "toolTable" ) -- Cache the net message.

	if sql.TableExists("pprotect_antispam_general") then

		--Check Table
		local checktable = sql.Query("SELECT toolprotection from pprotect_antispam_general")

		if checktable == false then

			sql.Query("DROP TABLE pprotect_antispam_general")

			MsgC(
				Color(235, 0, 0), 
				"[PatchAntiSpam] Deleted the old General-Settings-Table\n"
			)

		end

	end

	if ( !sql.TableExists("pprotect_antispam_general") ) then
		
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

		sql.Query("CREATE TABLE IF NOT EXISTS pprotect_antispam_general(" .. table.concat( sqlvars, ", " ) .. ");")
		sql.Query("INSERT INTO pprotect_antispam_general(" .. table.concat( options, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")") --
		
		MsgC(
			Color(0, 240, 100),
			"[PatchAntiSpam] Created new General-Settings-Table\n"
		)

	end
	
	return sql.QueryRow("SELECT * FROM pprotect_antispam_general LIMIT 1")

end

function PAS.SetupToolsSettings() 
	
	sv_PP.createToolTable()
	
	
	if !sql.TableExists("pprotect_antispam_tools") then
		local values = {}
		local vars = {}

		for p, cvars in pairs(PAS.ConVars) do
			if p == "PAS_ANTISPAM_tools" then

				for k, v in pairs(cvars) do

					table.insert(vars, v)
					table.insert(values, 0)
				
				end

			end

		end
		sql.Query("CREATE TABLE IF NOT EXISTS pprotect_antispam_tools(" .. table.concat( vars, ", " ) .. ");")
		sql.Query("INSERT INTO pprotect_antispam_tools(" .. table.concat( vars, ", " ) .. ") VALUES(" .. table.concat( values, ", " ) .. ")")
		
		MsgC(
			Color(0, 240, 100),
			"[PatchAntiSpam] Created new Tools-Settings-Table!\n"
		)

	end
	
	return sql.QueryRow("SELECT * FROM pprotect_antispam_tools LIMIT 1")

end

PAS.Settings.General = PAS.SetupGeneralSettings()
timer.Simple(0.1, function()
	PAS.Settings.Tools = PAS.SetupToolsSettings()
end)

timer.Simple(0.2, function()
	PAS.setBlockedTools()
end)

function PAS.ApplySettings(ply, cmd, args)
	
	if !ply then
		PAS.InfoNotify(ply, "This command can only be run in-game!")
	end
--[[ NOT WORKING AT THE MOMENT! - Not needed? A Non-Admin can't press the Save-Button
	if (!ply:IsAdmin()) then
		return
	end
]]	
	if args[1] != nil then

		local mode = string.Explode("_", args[1])

		if mode[1] == "tools" then

			local name = string.sub(args[1], 7)

			sql.Query("UPDATE pprotect_antispam_tools SET " .. name .. " = " .. args[2])

		else
			local number = GetConVar("_PAS_ANTISPAM_" .. args[1]):GetFloat()
			local text = GetConVar("_PAS_ANTISPAM_" .. args[1]):GetString()

			if text != 0 and number == 0 then
				sql.Query("UPDATE pprotect_antispam_general SET '" .. args[1] .. "' = '" .. text .. "'")
			else
				sql.Query("UPDATE pprotect_antispam_general SET " .. args[1] .. " = " .. number)
			end

		end
	end

end
concommand.Add("PAS_SetSettings", PAS.ApplySettings)

local savecount = 0
function PAS.CCV(ply, cmd, args)

	if tonumber(args[3]) == 0 then
		RunConsoleCommand("_PAS_ANTISPAM_" .. args[1], args[2])
	end

	RunConsoleCommand("PAS_SetSettings", args[1], args[2], args[3])

	savecount = savecount + 1

	local condition = 0

	if tonumber(args[3]) == 1 then condition = table.Count(PAS.Settings.Tools) else condition = table.Count(PAS.Settings.General) end
	if savecount >= condition then
		savecount = 0
		timer.Simple(0.1, function()

			PAS.Settings.Tools = sql.QueryRow("SELECT * FROM pprotect_antispam_tools LIMIT 1")
			PAS.Settings.General = sql.QueryRow("SELECT * FROM pprotect_antispam_general LIMIT 1")
			PAS.setBlockedTools()

			toolTableMessage(ply)
			
			PAS.InfoNotify(ply, "Settings saved!")
		end)

	end

end
concommand.Add("PAS_ChangeConVar", PAS.CCV)


--Notification Functions

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

function PAS.setBlockedTools()
	PAS.BlockedTools = {}

	table.foreach( PAS.Settings.Tools, function( key, value )
		if tonumber(value) == 1 then
			table.insert(PAS.BlockedTools, key)
		end
	end )
end

--Networking
function toolTableMessage( ply )
	net.Start( "toolTable" )
		net.WriteTable( PAS.Settings.Tools )
	net.Send( ply )
end
hook.Add( "PlayerInitialSpawn", "ToolTableMessage", toolTableMessage )
