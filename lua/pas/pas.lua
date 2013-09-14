-- These are the default settings. Don't mind changing these.
PAS = PAS or {}

--==============================DO NOT EDIT BELOW THIS POINT===================================
function PAS.Setup(ply)
	--Prop
	ply.d_time = 0
	ply.r_time = 0
	ply.t_time = 0
	ply.props = 0
	ply.lastprop = "none"
	ply.spawnspecial = false

	--Tool
	ply.tool_d_time = 0
	ply.tool_r_time = 0
	ply.tool_t_time = 0
	ply.tools = 0

	ply.propspawning = false
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

function PAS.Spawn(ply, type, ent, toolgun)

	--If AntiSpam is deactivated
	if tobool(PAS.Settings["use"]) == false then return end

	--Set Physics Object
	local phy = ent:GetPhysicsObject()

	--If Entity is not Valid
	if !phy:IsValid() then return end

	--Get Class of the Entity
	--local class = ent:GetClass()

	--Removing Entity
	if not toolgun then

		if CurTime() < ply.d_time then

			if ply:IsAdmin() and tobool(PAS.Settings["noantiadmin"]) then
			else
				timer.Create(ply:Nick().."_propcooldown", 10, 1, function()
					ply.props = 0
				end)

				ply.props = ply.props + 1
		
				if ply.props >= tonumber(PAS.Settings["spamcount"]) then

					PAS.AdminNotify("Player "..ply:Nick().." is spamming!")
					ply.props = 0
					spamaction(ply)

				end

				ply.r_time = ply.d_time - CurTime()
				PAS.Notify(ply, "Wait: ".. math.Round(ply.r_time,1) .."s")

				--Remove Entity
				ent:Remove()

				--ply.propspawning = false

				return

			end
		end

		ply.d_time = CurTime() + tonumber(PAS.Settings["cooldown"])

		--ply.propspawning = false

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
	--[[
	if not ply.blocktool then return end
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
			return false
		end
	end
	ply.tool_d_time = CurTime() + tonumber(PAS.Settings["cooldown"])
	]]
	
	if table.Count(ply.toolprops) == 0 then return end

	timer.Simple(0.00001, function()

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

		--ply.propspawning = true

		if Type != "duplicates" and !ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, false)

		elseif ply.usingtoolgun then

			PAS.Spawn(ply, Type, ent, true)

		end
	end

end
