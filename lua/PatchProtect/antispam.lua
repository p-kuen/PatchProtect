----------------
--  SETTINGS  --
----------------

-- SET PLAYER VARS
function sv_PProtect.Setup( ply )

	-- PROPS
	ply.propcooldown = 0
	ply.props = 0

	-- TOOLS
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
function sv_PProtect.spamaction( ply )

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

function sv_PProtect.Spawn( ply )
	
	--Check if AntiSpam is enabled
	if tobool(sv_PProtect.Settings.General["use"]) == false then return end

	--Check Admin
	if ply:IsAdmin() and tobool(sv_PProtect.Settings.General["noantiadmin"]) then return end

	--Check Blocked Prop
	if tobool(sv_PProtect.Settings.General["propblock"]) then

		--here goes propblock function

	end

	--Check Cooldown
	if CurTime() < ply.propcooldown then
				
		--Add one Prop to the Warning-List
		ply.props = ply.props + 1

		--Notify Admin about the Spam
		if ply.props >= tonumber(sv_PProtect.Settings.General["spamcount"]) then
					
			sv_PProtect.AdminNotify(ply:Nick() .. " is spamming!")
			print("[PatchProtect - AS] " .. ply:Nick() .. " is spamming!")
			ply.props = 0
			sv_PProtect.spamaction(ply)

		end

		--Block Prop-Spawning
		sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.propcooldown - CurTime(), 1))
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
hook.Add("PlayerSpawnNPC", "SpawningNPC", sv_PProtect.Spawn)
hook.Add("PlayerSpawnSWEP", "SpawningSWEP", sv_PProtect.Spawn)



----------------------
--  TOOL ANTI SPAM  --
----------------------

function sv_PProtect.CanTool( ply, trace, mode )

	--Set some Player information
	ply.spawned = true
	ply.tooltype = mode

	--Check, if AntiSpam is enabled or ToolProtection is disabled
	if tobool(sv_PProtect.Settings.General["use"]) == false or tobool(sv_PProtect.Settings.General["toolprotection"]) == false or ply:IsSuperAdmin() then return true end

	--Check Admin
	if ply:IsAdmin() and tobool(sv_PProtect.Settings.General["noantiadmin"]) then return true end

	local delete = false

	local function blockedtool()

		--Check Cooldown
		if CurTime() < ply.toolcooldown then

			--Add one Tool-Action to the Warning-List
			ply.tools = ply.tools + 1

			--Notify Admin about Tool-Spam
			if ply.tools >= tonumber(sv_PProtect.Settings.General["spamcount"]) then

				sv_PProtect.AdminNotify("PatchProtect - AntiSpam] " .. ply:Nick() .. " is spamming with " .. tostring(mode) .. "s!")
				ply.tools = 0
				spamaction(ply)

			end

			--Block Toolgun-Firing
			sv_PProtect.Notify( ply, "Wait: " .. math.Round( ply.toolcooldown - CurTime(), 1))
			delete = true
			return false

		else

			--Set Cooldown
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
hook.Add( "CanTool", "LimitToolGuns", sv_PProtect.CanTool )