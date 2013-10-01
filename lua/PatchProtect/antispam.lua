----------------
--  SETTINGS  --
----------------

-- SET PLAYER VARS
function sv_PProtect.Setup(ply)

	--Props
	ply.propcooldown = 0
	ply.props = 0

	--Tools
	ply.toolcooldown = 0
	ply.tools = 0
	ply.spawned = false
	ply.tooltype = ""

end
hook.Add( "PlayerInitialSpawn", "Setup_AntiSpamVariables", sv_PProtect.Setup )



-------------------
--  SPAM ACTION  --
-------------------

-- SET SPAM ACTION
function sv_PProtect.spamaction(ply)

	local action = tonumber(sv_PProtect.Settings.General["spamaction"])

	--Cleanup
	if action == 2 then

		cleanup.CC_Cleanup(ply, "", {} )
		ply.cleanedup = true
		sv_PProtect.InfoNotify(ply, "Your props have been cleanuped!")
		sv_PProtect.AdminNotify(ply:Nick() .. "s props were cleaned up! (Reason: Spam)")
		print("[PatchProtect - AS] " .. ply:Nick() .. "s props have been cleaned up!")

	--Kick
	elseif action == 3 then

		ply:Kick("Kicked by PProtect: Spammer")
		sv_PProtect.AdminNotify(ply:Nick() .. " was kicked from the server! (Reason: Spam)")
		print("[PatchProtect - AS] " .. ply:Nick() .. " was kicked from the server!")

	--Ban
	elseif action == 4 then

		local banminutes = tonumber(sv_PProtect.Settings.General["bantime"])
		ply:Ban(banminutes, "Banned by PProtect: Spammer")
		sv_PProtect.AdminNotify(ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes! (Reason: Spam)")
		print("[PatchProtect - AS] " .. ply:Nick() .. " was banned from the server for " .. banminutes .. " minutes!")

	--ConCommand
	elseif action == 5 then

		local concommand = tostring(sv_PProtect.Settings.General["concommand"])
		concommand = string.Replace(concommand, "<player>", ply:Nick())
		local commands = string.Explode(" ", concommand)
		RunConsoleCommand(commands[1], unpack(commands, 2))
		print("[PatchProtect - AS] Ran console command " .. tostring(sv_PProtect.Settings.General["concommand"]) .. " on " .. ply:Nick())

	end

end



----------------------
--  PROP ANTI SPAM  --
----------------------

function sv_PProtect.Spawn(ply)
	
	--Check, if PProtect is enabled
	if tobool(sv_PProtect.Settings.General["use"]) == false then return end

	--Check Admin
	if ply:IsAdmin() and tobool(sv_PProtect.Settings.General["noantiadmin"]) then return end

	--Checking Coodown
	if CurTime() < ply.propcooldown then
				
		--Add One Prop to the Warning List
		ply.props = ply.props + 1

		--Notify to Admin about spamming
		if ply.props >= tonumber(sv_PProtect.Settings.General["spamcount"]) then
					
			sv_PProtect.AdminNotify(ply:Nick() .. " is spamming!")
			print("[PatchProtect - AS] " .. ply:Nick() .. " is spamming!")
			ply.props = 0
			sv_PProtect.spamaction(ply)

		end

		sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.propcooldown - CurTime(), 1))
		-- Block spawning the Prop
		return false

	end

	--Set Cooldown
	ply.props = 0
	ply.propcooldown = CurTime() + tonumber(sv_PProtect.Settings.General["cooldown"])


end
hook.Add("PlayerSpawnProp", "SpawningProp", sv_PProtect.Spawn)
hook.Add("PlayerSpawnEffect", "SpawningEffect", sv_PProtect.Spawn)
hook.Add("PlayerSpawnSENT", "SpawningSENT", sv_PProtect.Spawn)
hook.Add("PlayerSpawnRagdoll", "SpawningRagdoll", sv_PProtect.Spawn)
hook.Add("PlayerSpawnVehicle", "SpawningVehicle", sv_PProtect.Spawn)



----------------------
--  TOOL ANTI SPAM  --
----------------------

function sv_PProtect.CanTool( ply, trace, mode )

	--Set some player information
	ply.spawned = true
	ply.tooltype = mode

	--Check, if PProtect is enabled
	if tobool(sv_PProtect.Settings.General["use"]) == false or tobool(sv_PProtect.Settings.General["toolprotection"]) == false then return end
	
	--Check Admin
	if ply:IsAdmin() and tobool(sv_PProtect.Settings.General["noantiadmin"]) then return end

	local delete = false

	local function blockedtool()

		--Checking Cooldown
		if CurTime() < ply.toolcooldown then

			ply.tools = ply.tools + 1

			--Notify Admin about Spam
			if ply.tools >= tonumber(sv_PProtect.Settings.General["spamcount"]) then

				sv_PProtect.AdminNotify("PatchProtect - AS] " .. ply:Nick() .. " is spamming with " .. tostring(mode) .. "s!")
				ply.tools = 0
				spamaction(ply)

			end


			sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.toolcooldown - CurTime(), 1))
			--Block Tool
			delete = true
			return false

		else

			delete = false
			ply.tools = 0
			ply.toolcooldown = CurTime() + tonumber(sv_PProtect.Settings.General["cooldown"])

		end

	end

	table.foreach( sv_PProtect.BlockedTools, function( key, value )

 		if value == mode then
 			blockedtool()
 		end

	end )

	if delete then
		return false
	end
	
end
hook.Add("CanTool", "LimitToolGuns", sv_PProtect.CanTool)