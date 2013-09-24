PAS = PAS or {}


--Settings Variables:

function PAS.Setup(ply)

	--Props
	ply.propcooldown = 0
	ply.props = 0

	--Tools
	ply.toolcooldown = 0
	ply.tools = 0

end
hook.Add( "PlayerInitialSpawn", "Setup_AntiSpamVariables", PAS.Setup )


--Spam Action:

function spamaction(ply)

	local action = tonumber(PAS.Settings.General["spamaction"])

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

		local banminutes = tonumber(PAS.Settings.General["bantime"])
		ply:Ban(banminutes, "Banned by PAS: Spammer")
		PAS.AdminNotify(ply:Nick() .. " banned from the server for " .. banminutes .. " minutes, cause of spamming!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring(PAS.Settings.General["concommand"])
		concommand = string.Replace(concommand, "<player>", ply:Nick())
		local commands = string.Explode(" ", concommand)
		RunConsoleCommand(commands[1], unpack(commands, 2))

	end

end


--Prop Anti Spam:

function PAS.Spawn(ply, mdl)

	--Check if PAS is enabled
	if tobool(PAS.Settings.General["use"]) == false then return end

		--Checking Coodown
		if CurTime() < ply.propcooldown then

			if ply:IsAdmin() and tobool(PAS.Settings.General["noantiadmin"]) then
				--Do nothing...
			else
				
				--Add One Prop to the Warning List
				ply.props = ply.props + 1

				--Notify to Admin about spamming
				if ply.props >= tonumber(PAS.Settings.General["spamcount"]) then
					
					PAS.AdminNotify(ply:Nick() .. " is spamming!")
					ply.props = 0
					spamaction(ply)

				end

				--Notify Client about Wait-Time
				PAS.Notify( ply, "Wait: " .. math.Round( ply.propcooldown - CurTime(), 1))

				--Block entity
				return false

			end

		else

			--Set Cooldown
			ply.props = 0
			ply.propcooldown = CurTime() + tonumber(PAS.Settings.General["cooldown"])

		end

end
hook.Add("PlayerSpawnProp", "SpawnedProp", PAS.Spawn)


--Tool Anti Spam:

function PAS.Tool( ply, trace, mode )

	--Check, if PAS is enabled and also the Tool Restriction
	if tobool(PAS.Settings.General["use"]) == false or tobool(PAS.Settings.General["toolprotection"]) == false then return end

	local delete = false

	local function blockedtool()
		--Set AntiSpam:
		if CurTime() < ply.toolcooldown then

			if ply:IsAdmin() and tobool(PAS.Settings.General["noantiadmin"]) then
			else

				ply.tools = ply.tools + 1

				--Notify Admin about spamming
				if ply.tools >= tonumber(PAS.Settings.General["spamcount"]) then

					PAS.AdminNotify(ply:Nick() .. " is spamming with " .. tostring(mode) .. "s!")
					ply.tools = 0
					spamaction(ply)

				end

				--Notify Client about Wait-Time
				PAS.Notify( ply, "Wait: " .. math.Round( ply.toolcooldown - CurTime(), 1))

				--Block Tool
				delete = true
				return false

				end

			else

				delete = false
				ply.tools = 0
				ply.toolcooldown = CurTime() + tonumber(PAS.Settings.General["cooldown"])

			end
	end

	table.foreach( PAS.BlockedTools, function( key, value )
 		if value == mode then
 			blockedtool()
 		end
	end )

	if delete then
		return false
	end
end
hook.Add("CanTool", "LimitToolGuns", PAS.Tool)