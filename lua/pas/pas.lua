PAS = PAS or {}

function PAS.Setup(ply)

	--Props
	ply.cooldown = 0
	ply.props = 0
	ply.lastprop = "none"
	ply.spawnspecial = false

	--Tool
	ply.tool_d_time = 0
	ply.tool_r_time = 0
	ply.tool_t_time = 0
	ply.tools = 0

	ply.usingtoolgun = false
	ply.blocktool = false
	ply.count = 0
	ply.toolprops = {}

end
hook.Add( "PlayerInitialSpawn", "Setup_PropSpawn", PAS.Setup )

function spamaction(ply)

	local action = tonumber(PAS.Settings["spamaction"])

	if action == 2 then

		cleanup.CC_AdminCleanup(ply, "", {} )
		ply.cleanedup = true
		PAS.InfoNotify(ply, "Your props have been cleanuped!")

	elseif action == 3 then

		ply:Kick("Kicked by PAS: Spammer")

	elseif action == 4 then

		local banminutes = tonumber(PAS.Settings["bantime"])
		ply:Ban(banminutes, "Banned by PAS: Spammer")

	elseif action == 5 then

		local concommand = tostring(PAS.Settings["concommand"])
		concommand = string.Replace(concommand, "<player>", ply:Nick())
		local commands = string.Explode(" ", concommand)
		RunConsoleCommand(commands[1], unpack(commands, 2))

	end

end

--Anti Spam Function
function PAS.Spawn(ply, type, ent, toolgun)

	--If AntiSpam is deactivated
	if tobool(PAS.Settings["use"]) == false then return end

	--Dev:
	if not toolgun then

		if CurTime() < ply.cooldown then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
				--Do nothing...
			else

				--Add One Prop to the Warning List
				ply.props = ply.props + 1

				--Notify to Admin about spamming
				if ply.props > tonumber(PAS.Settings["spamcount"]) then

					PAS.AdminNotify("Player "..ply:Nick().." is spamming!")
					ply.props = 0
					spamaction( ply )

				end

				--Notify Client about Wait-Time
				PAS.Notify( ply, "Wait: " .. math.Round( ply.cooldown - CurTime(), 1))

				--Remove Entity
				ent:Remove()

				return

			end

		else

			--Set Cooldown
			ply.props = 0
			ply.cooldown = CurTime() + tonumber(PAS.Settings["cooldown"])

		end

	else
		ply.count = ply.count + 1
		ply.toolprops[ply.count] = ent
	end

end

local function removeent(ply)

	for i = 1, table.Count(ply.toolprops) do

		if ply.toolprops[i]:IsValid() then ply.toolprops[i]:Remove() end
		
	end

	ply.toolprops = {}

end

function firedToolGun(ply, tr, tool)
	ply.usingtoolgun = true

	--If Tool Restriction is deactivated
	if tobool(PAS.Settings["use"]) == false or tobool(PAS.Settings["toolprotection"]) == false then return end
	--If activated
	ply.toolprops = {}
	


	timer.Simple(0.00001, function()

		if table.Count(ply.toolprops) == 0 then return end

		ply.usingtoolgun = false
		ply.count = 0

		if CurTime() < ply.tool_d_time then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
			else
				timer.Create(ply:Nick().."_toolcooldown", 10, 1, function()
					ply.tools = 0
				end)
				ply.tools = ply.tools + 1
				if ply.tools >= tonumber(PAS.Settings["spamcount"]) then
					PAS.AdminNotify("Player "..ply:Nick().." is spamming with " .. tool .. "s!")
					ply.tools = 0
					spamaction(ply)
				end
				ply.tool_r_time = ply.tool_d_time - CurTime()
				PAS.Notify(ply, "Wait: "..math.Round(ply.tool_r_time,1).."s")
				removeent(ply)
				return

			end

		end
		ply.tool_d_time = CurTime() + tonumber(PAS.Settings["cooldown"])

	end)

end
hook.Add( "CanTool", "FiredToolGun", firedToolGun )

if cleanup then

	function cleanup.Add(ply, Type, ent)
		if IsValid(ent) and ply:IsPlayer() then
			if NADMOD then
				NADMOD.PlayerMakePropOwner(ply, ent)
			end
		end

		if Type != "duplicates" and !ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, false)

		elseif ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, true)

		end
	end

end
