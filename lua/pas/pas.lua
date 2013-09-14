PAS = PAS or {}

function PAS.Setup(ply)

	--Props
	ply.cooldown = 0
	ply.props = 0
	ply.lastprop = "none"
	ply.spawnspecial = false

	--Tools
	ply.toolcooldown = 0
	ply.tools = 0
	ply.usingtoolgun = false
	ply.count = 0
	ply.toolprops = {}

end
hook.Add( "PlayerInitialSpawn", "Setup_PropSpawn", PAS.Setup )

function spamaction(ply)

	local action = tonumber(PAS.Settings["spamaction"])

	--Cleanup
	if action == 2 then

		cleanup.CC_AdminCleanup(ply, "", {} )
		ply.cleanedup = true
		PAS.InfoNotify(ply, "Your props have been cleanuped!")
		PAS.AdminNotify(ply:Nick() .. "'s props were cleaned up, cause of spamming!")

	--Kick
	elseif action == 3 then

		ply:Kick("Kicked by PAS: Spammer")
		PAS.AdminNotify(ply:Nick() .. " kicked from the server cause of spamming!")

	--Ban
	elseif action == 4 then

		local banminutes = tonumber(PAS.Settings["bantime"])
		ply:Ban(banminutes, "Banned by PAS: Spammer")
		PAS.AdminNotify(ply:Nick() .. " banned from the server for " .. banminutes .. " minutes cause of spamming!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring(PAS.Settings["concommand"])
		concommand = string.Replace(concommand, "<player>", ply:Nick())
		local commands = string.Explode(" ", concommand)
		RunConsoleCommand(commands[1], unpack(commands, 2))

	end

end

--Anti Spam Function ## PROPS ##
function PAS.Spawn(ply, type, ent, toolgun)

	--If AntiSpam is deactivated
	if tobool(PAS.Settings["use"]) == false then return end

	if not toolgun then

		if CurTime() < ply.cooldown then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
				--Do nothing...
			else
				
				--Add One Prop to the Warning List
				ply.props = ply.props + 1
				print(ply.props)
				RunConsoleCommand("say", tostring(ply.props))
				RunConsoleCommand("say", "plyprops: " .. tostring(PAS.Settings["spamcount"]))
				--Notify to Admin about spamming
				if ply.props >= tonumber(PAS.Settings["spamcount"]) then
					RunConsoleCommand("say", "MESSAGE")
					PAS.AdminNotify(ply:Nick() .. " is spamming!")
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






--Anti Spam Function ## TOOLS ##
function firedToolGun(ply, tr, tool)

	ply.usingtoolgun = true

	--If Tool Restriction is deactivated OR whole AntiSpam
	if tobool(PAS.Settings["use"]) == false or tobool(PAS.Settings["toolprotection"]) == false then return end

	--Reset Tool Entities
	ply.toolprops = {}
	
	--Start Timer
	timer.Simple(0.00001, function()

		if table.Count(ply.toolprops) == 0 then return end

		ply.usingtoolgun = false
		ply.count = 0

		if CurTime() < ply.toolcooldown then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
				--Do nothing ...
			else

				ply.tools = ply.tools + 1

				if ply.tools >= tonumber(PAS.Settings["spamcount"]) then

					PAS.AdminNotify(ply:Nick() .. " is spamming with " .. tool .. "'s")
					ply.tools = 0

				end

				ply.tool_r_time = 
				PAS.Notify( ply, "Wait: ".. math.Round( ply.toolcooldown - CurTime(), 1 ) )
				
				--Remove Toolgun-Entities
				for i = 1, table.Count(ply.toolprops) do
					ply.toolprops[i]:Remove()
				end
				ply.toolprops = {}

				return

			end

		else

			ply.tools = 0
			ply.toolcooldown = CurTime() + tonumber(PAS.Settings["cooldown"])

		end

	end)

end
hook.Add( "CanTool", "FiredToolGun", firedToolGun )






--Anti Spam Function ## RUN FUNCTIONS ##
if cleanup then

	function cleanup.Add(ply, Type, ent)

		--Set Prop's Owner
		if IsValid(ent) and ply:IsPlayer() then
			if NADMOD then
				NADMOD.PlayerMakePropOwner(ply, ent)
			end
		end

		--If Toolgun is not used
		if Type != "duplicates" and !ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, false)

		elseif ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, true)

		end
	end

end
