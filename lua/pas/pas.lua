PAS = PAS or {}


--Blocked Tools:

local BlockedTools = {"dynamite", "thruster"}


--Settings Variables:

function PAS.Setup(ply)

	--Props
	ply.cooldown = 0
	ply.props = 0

	--Tools
	ply.toolcooldown = 0
	ply.tools = 0

end
hook.Add( "PlayerInitialSpawn", "Setup_AntiSpamVariables", PAS.Setup )


--Spam Action:

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
		PAS.AdminNotify(ply:Nick() .. " kicked from the server, cause of spamming!")

	--Ban
	elseif action == 4 then

		local banminutes = tonumber(PAS.Settings["bantime"])
		ply:Ban(banminutes, "Banned by PAS: Spammer")
		PAS.AdminNotify(ply:Nick() .. " banned from the server for " .. banminutes .. " minutes, cause of spamming!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring(PAS.Settings["concommand"])
		concommand = string.Replace(concommand, "<player>", ply:Nick())
		local commands = string.Explode(" ", concommand)
		RunConsoleCommand(commands[1], unpack(commands, 2))

	end

end


--Prop Anti Spam:

function PAS.Spawn(ply, mdl)

	--Check if PAS is enabled
	if tobool(PAS.Settings["use"]) == false then return end

		--Checking Coodown
		if CurTime() < ply.cooldown then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
				--Do nothing...
			else
				
				--Add One Prop to the Warning List
				ply.props = ply.props + 1

				--Notify to Admin about spamming
				if ply.props >= tonumber(PAS.Settings["spamcount"]) then
					
					PAS.AdminNotify(ply:Nick() .. " is spamming!")
					ply.props = 0

				end

				--Notify Client about Wait-Time
				PAS.Notify( ply, "Wait: " .. math.Round( ply.cooldown - CurTime(), 1))

				--Block entity
				return false

			end

		else

			--Set Cooldown
			ply.props = 0
			ply.cooldown = CurTime() + tonumber(PAS.Settings["cooldown"])

		end

end
hook.Add("PlayerSpawnProp", "SpawnedProp", PAS.Spawn)


--Tool Anti Spam:

function PAS.Tool ( ply, trace, mode )
	
	--Check, if PAS is enabled and also the Tool Restriction
	if tobool(PAS.Settings["use"]) == false or tobool(PAS.Settings["toolprotection"]) == false then return end

	--Check, what tool the player uses
	for k, v in pairs( BlockedTools ) do

		if mode == v then

			--Set AntiSpam:
			if CurTime() < ply.toolcooldown then

				if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
					--Do nothing...
				else

					ply.tools = ply.tools + 1

					--Notify Admin about spamming
					if ply.tools >= tonumber(PAS.Settings["spamcount"]) then

						PAS.AdminNotify(ply:Nick() .. " is spamming with " .. tostring(mode) .. "'s!")
						ply.tools = 0

					end

					--Notify Client about Wait-Time
					PAS.Notify( ply, "Wait: " .. math.Round( ply.toolcooldown - CurTime(), 1))

					--Block Tool
					return false

				end

			else

				ply.tools = 0
				ply.toolcooldown = CurTime() + tonumber(PAS.Settings["cooldown"])

			end

		end

	end
	
end
hook.Add("CanTool", "LimitToolGuns", PAS.Tool)