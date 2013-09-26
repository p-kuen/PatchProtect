PAS = PAS or {}

--SETTINGS

function PAS.Setup(ply)

	--Props
	ply.propcooldown = 0
	ply.props = 0

	--Tools
	ply.toolcooldown = 0
	ply.tools = 0
	ply.spawned = false
	ply.tooltype = ""

end
hook.Add( "PlayerInitialSpawn", "Setup_AntiSpamVariables", PAS.Setup )


--SPAM ACTION

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


--PROP ANTI SPAM

function PAS.Spawn(ply)
	
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
					print("[PatchProtect - PAS] " .. ply:Nick() .. " spams!")
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
hook.Add("PlayerSpawnProp", "SpawningProp", PAS.Spawn)
hook.Add("PlayerSpawnEffect", "SpawningEffect", PAS.Spawn)
hook.Add("PlayerSpawnSENT", "SpawningSENT", PAS.Spawn)
hook.Add("PlayerSpawnRagdoll", "SpawningRagdoll", PAS.Spawn)
hook.Add("PlayerSpawnVehicle", "SpawningVehicle", PAS.Spawn)


--BLOCK THINGS

function PAS.BlockSWEP(ply, type)

	if ply:IsAdmin() then
		return true
	else
		print("[PatchProtect - PAS] " .. ply:Nick() .. " tried to spawn " .. tostring(type) .. "!")
		return false
	end

end
hook.Add("PlayerSpawnSWEP", "BlockSWEP", PAS.BlockThis)
hook.Add("PlayerSpawnNPC", "BlockNPC", PAS.BlockThis)


--SET OWNER

function PAS.SpawnedProp( ply, mdl, ent )

	ent.name = ply:Nick()
	ent:SetNetworkedString("Owner", ply:Nick())

end
hook.Add("PlayerSpawnedProp", "SpawnedProp", PAS.SpawnedProp)

function PAS.SpawnedEnt( ply, ent )

	ent.name = ply:Nick()
	ent:SetNetworkedString("Owner", ply:Nick())

end
hook.Add("PlayerSpawnedEffect", "SpawnedEffect", PAS.SpawnedEnt)
hook.Add("PlayerSpawnedNPC", "SpawnedNPC", PAS.SpawnedEnt)
hook.Add("PlayerSpawnedRagdoll", "SpawnedRagdoll", PAS.SpawnedEnt)
hook.Add("PlayerSpawnedSENT", "SpawnedSENT", PAS.SpawnedEnt)
hook.Add("PlayerSpawnedSWEP", "SpawnedSWEP", PAS.SpawnedEnt)
hook.Add("PlayerSpawnedVehicle", "SpawnedVehicle", PAS.SpawnedEnt)


--TOOL ANTI SPAM

function PAS.Tool( ply, trace, mode )

	ply.spawned = true
	ply.tooltype = mode

	--Check, if PAS is enabled and also the Tool Restriction
	if tobool(PAS.Settings.General["use"]) == false or tobool(PAS.Settings.General["toolprotection"]) == false then return end

	local delete = false

	local function blockedtool()

		--Checking Cooldown
		if CurTime() < ply.toolcooldown then

			if ply:IsAdmin() and tobool(PAS.Settings.General["noantiadmin"]) then
				--Do nothing...
			else

				ply.tools = ply.tools + 1

				--Notify Admin about Spam
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


--SET OWNER FOR STOOL-ENTITIES
local keep = 0 --IMPORTANT, ONLY ACTIVATE IT IF YOU DON'T HAVE ANY OTHER PP ACTIVATED.  @producers: We must set a condition instead of "keep", that this only will be runned, if PropProtection checkbox is enabled.
if cleanup and keep == 1 then
	
	local Clean = cleanup.Add

	function cleanup.Add(ply, type, ent)

		if ent then

		    if ply:IsPlayer() and ent:IsValid() and ply.spawned == true then

		    	if ent.name == nil then

		        	ent.name = ply:Nick()
					ent:SetNetworkedString("Owner", ply:Nick())

				end

		        ply.spawned = false

		    end

		end

		Clean(ply, type, ent)

	end

end