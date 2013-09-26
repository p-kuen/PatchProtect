----------------------------
--  MAIN PROP PROTECTION  --
----------------------------

-- PROPS, DRIVE
function CheckPlayer(ply, ent)

	if tonumber(PatchPP.Config["usepp"]) == 1 then

		if !ply:IsAdmin() then

			if ent.name == ply:Nick() and !ent:IsWorld() then
				return true
			else
				PAS.Notify( ply, "You are not allowed to do this!" )
				return false
			end

		else
			return true
		end

	end

end
hook.Add( "PhysgunPickup", "Allow Player Pickup", CheckPlayer )
hook.Add( "CanDrive", "Allow Driving", CheckPlayer )


-- TOOLS
function CanTool(ply, trace, tool)

	if tonumber(PatchPP.Config["usepp"]) == 1 then

		if !ply:IsAdmin() then

			if IsValid( trace.Entity ) then

				ent = trace.Entity

				if !ent:IsWorld() and ent.name == ply:Nick() then
					return true
				else
					PAS.Notify( ply, "You are not allowed to do this!" )
					return false
				end

			end

		else
			return true
		end

	end
 	
end
hook.Add( "CanTool", "Allow Player Tool-Useage", CanTool )


-- CDRIVE
function PlayerProperty(ply, string, ent)

	if tonumber(PatchPP.Config["usepp"]) == 1 then

		if !ply:IsAdmin() then

			if string != "drive" or tonumber(PatchPP.Config["cdrive"]) == 1 then

				if ent.name != nil and ent.name == ply:Nick() and !ent.IsWorld() and string != "persist" then
 					return true
 				else
 					PAS.Notify( ply, "You are not allowed to do this!" )
 					return false
 				end

			else
				return false
			end

		else
			return true
		end

	end

end
hook.Add( "CanProperty", "Allow Player Property", PlayerProperty )





------------------------------------------
--  DISCONNECTED PLAYER'S PROP CLEANUP  --
------------------------------------------


-- CREATE TIMER
function CleanupDiscPlayersProps( name )

	if tonumber(PatchPP.Config["usepd"]) == 1 and tonumber(PatchPP.Config["usepp"]) == 1 then

		timer.Create( "CleanupPropsOf" .. name , tonumber(PatchPP.Config["pddelay"]), 1, function()

			for k, v in pairs( ents.GetAll() ) do

				ent = v
				if ent.cleanuped == name and ent.name == "Disconnected Player" then
					ent:Remove()
				end

			end

			print("[PatchProtect - Cleanup] Removed " .. name .. "'s Props!")

		end)

	end
	
end


-- PLAYER LEFT SERVER
function SetCleanupProps( ply )

	if tonumber(PatchPP.Config["usepd"]) == 1 and tonumber(PatchPP.Config["usepp"]) == 1 then

		for k, v in pairs( ents.GetAll() ) do

			ent = v
			if ent.name == ply:Nick() then
				ent.name = "Disconnected Player"
				ent.cleanuped = ply:Nick()
			end

		end

		CleanupDiscPlayersProps( ply:Nick() )

	end

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", SetCleanupProps )


-- PLAYER COME BACK
function CheckComeback( name )

	if tonumber(PatchPP.Config["usepd"]) == 1 and tonumber(PatchPP.Config["usepp"]) == 1 then

		if timer.Exists( "CleanupPropsOf" .. name ) then

			timer.Destroy( "CleanupPropsOf" .. name )
			for k, v in pairs( ents.GetAll() ) do

				ent = v
				if ent.cleanuped == name and ent.name == "Disconnected Player" then
					ent.name = name
				end

			end

		end

	end

end
hook.Add( "PlayerConnect", "CheckAbortCleanup", CheckComeback )





-------------------------------------------------
--  SAVE PROP PROTECTION SETTINGS FROM CLIENT  --
-------------------------------------------------


-- SYNCH CONFIG WITH CLIENT
function PatchPP.GetPatchPPInfo(ply)

	if(!ply or !ply:IsValid()) then
		return
	end
	
	for k, v in pairs(PatchPP.Config) do

		local configs = k
		ply:ConCommand("patchpp_" .. configs .. " " .. v .. "\n")

	end

end
hook.Add("PlayerInitialSpawn", "getpatchppconfig", PatchPP.GetPatchPPInfo)


-- SAVE SETTINGS TO DATABASE
function PatchPP.SaveSettings(ply, cmd, args)

	if !ply then
		MsgN("This command can only be run in-game!")
	end

	if(!ply:IsAdmin()) then
		return
	end

	-- SAVE THINGS TO SERVER (GET DATA FROM SAVER)
	local usepp = tonumber(ply:GetInfo("patchpp_usepp") or 1)
	local usepd = tonumber(ply:GetInfo("patchpp_usepd") or 1)
	local pddelay = tonumber(ply:GetInfo("patchpp_pddelay") or 120)
	local cdrive = tonumber(ply:GetInfo("patchpp_cdrive") or 0)

	sql.Query("UPDATE patchpp SET usepp = " .. usepp .. ", usepd = " .. usepd .. ", pddelay = " .. pddelay .. ", cdrive = " .. cdrive)
	PatchPP.Config = sql.QueryRow("SELECT * FROM patchpp LIMIT 1")

	PAS.InfoNotify(ply, "Settings Saved!")

	-- SYNCH NEW CONFIG WITH ALL CLIENTS
	timer.Simple(2, function()

		local Players = player.GetAll()

		for i = 1, table.Count(Players) do
			PatchPP.GetPatchPPInfo(Players[i])
		end

	end)

end
concommand.Add("patchpp_save", PatchPP.SaveSettings)





---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------


-- CLEANUP EVERYTHING
function PatchPP.CleanupEverything()

	game.CleanUpMap()
	PAS.InfoNotify(ply, "Cleaned Map!")

end
concommand.Add("patchpp_cleanup_everything", PatchPP.CleanupEverything)


-- CLEANUP PLAYERS PROPS
function PatchPP.CleanupPlayersProps( cleared )

	local name = cleared:GetName()
	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.name == name then
			ent:Remove()
		end

	end

	PAS.InfoNotify(ply, "Cleaned " .. name .. "'s Props!")

end
concommand.Add("patchpp_clean", PatchPP.CleanupPlayersProps)