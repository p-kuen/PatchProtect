local ownerTable = {}

-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF PROPS
function sv_PProtect.SpawnedProp( ply, mdl, ent )

	timer.Simple( 0.1, function()

		local Owner = ent:CPPIGetOwner()
		local id = ent:EntIndex()

		ownerTable[id] = Owner

		net.Start("PatchPPOwner")
			--net.WriteEntity( Owner )
			--net.WriteType( id )
			net.WriteTable( ownerTable )
		--net.Send( ply )
		net.Broadcast()

	end )

end
hook.Add("PlayerSpawnedProp", "SpawnedProp", sv_PProtect.SpawnedProp)
hook.Add("PlayerSpawnedRagdoll", "SpawnedRagdoll", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedEffect", "SpawnedEffect", sv_PProtect.SpawnedEnt)

-- SET OWNER OF ENTS
function sv_PProtect.SpawnedEnt( ply, ent )

	timer.Simple( 0.1, function()

		local Owner = ent:CPPIGetOwner()
		local id = ent:EntIndex()

		ownerTable[id] = Owner

		net.Start("PatchPPOwner")
			net.WriteTable( ownerTable )
		net.Broadcast()

	end )

end
hook.Add("PlayerSpawnedNPC", "SpawnedNPC", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedSENT", "SpawnedSENT", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedSWEP", "SpawnedSWEP", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedVehicle", "SpawnedVehicle", sv_PProtect.SpawnedEnt)


--SET OWNER OF TOOL-ENTS
if cleanup then

	function cleanup.Add(ply, type, ent)

		if !ent:IsValid() or !ply:IsPlayer() then return end

		ent:CPPISetOwner(ply)

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

function sv_PProtect.checkPlayer(ply, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	--if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	local Owner = ent:CPPIGetOwner()

	if Owner == nil then
		return false
	end

	if !ent:IsWorld() and Owner == ply then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPlayerPickup", sv_PProtect.checkPlayer )
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.checkPlayer )
hook.Add( "CanUse", "AllowUseing", sv_PProtect.checkPlayer )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.canTool(ply, trace, tool)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	local ent = trace.Entity
	local Owner = ent:CPPIGetOwner()

	if ent:IsWorld() and tonumber(sv_PProtect.Settings.PropProtection["tool_world"]) == 0 then return false end

	if Owner == ply or ent:IsWorld() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end
 	
end
hook.Add( "CanTool", "AllowToolUsage", sv_PProtect.canTool )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

function sv_PProtect.playerProperty(ply, string, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

	if string == "drive" and tonumber(sv_PProtect.Settings.PropProtection["cdrive"]) == 0 then return false end

	local Owner = ent:CPPIGetOwner()

	if !ent:IsWorld() and Owner == ply and string != "persist" then
 		return true
 	else
 		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
 		return false
 	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.playerProperty )



------------------------------
--  DAMAGE PROP PROTECTION  --
------------------------------

function sv_PProtect.EntityDamage(ent, info)
	
	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()

	if !ent:IsValid() or ent:IsPlayer() then return end
	if Owner == Attacker then return end -- Add Checkbox (Can Damage own Props/Ents)

	info:SetDamage(0)

end
hook.Add("EntityTakeDamage", "EntityGetsDamage", sv_PProtect.EntityDamage)



------------------------------------------
--  DISCONNECTED PLAYER'S PROP CLEANUP  --
------------------------------------------

-- PLAYER LEFT SERVER
function sv_PProtect.setCleanupProps( ply )

	local plyname = ply:Nick()
	
	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v

		local Owner = ent:CPPIGetOwner()
		if Owner == ply then
			ent.PatchPPCleanup = ply:Nick()
		end

	end
	
	-- Create Timer
	timer.Create( "CleanupPropsOf" .. plyname , tonumber(sv_PProtect.Settings.PropProtection["propdelete_delay"]), 1, function()

		for k, v in pairs( ents.GetAll() ) do

			ent = v
			if ent.PatchPPCleanup == plyname then
				ent:Remove()
			end

		end
		print( "[PatchProtect - Cleanup] Removed " .. plyname .. "'s Props!" )

	end )

	table.foreach(ownerTable, function(key, value)


		if value == ply then

			ownerTable[key] = "Disconnected (" .. ply:GetName() .. ")"

		end 


	end)

end
hook.Add( "PlayerDisconnected", "CleanupDisconnectedPlayersProps", sv_PProtect.setCleanupProps )

-- PLAYER CAME BACK
function sv_PProtect.checkComeback( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["propdelete"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	if timer.Exists( "CleanupPropsOf" .. ply:Nick() ) then
		timer.Destroy( "CleanupPropsOf" .. ply:Nick() )
	end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPCleanup == ply then
			ent.PatchPPCleanup = ""
		end

	end

end
hook.Add( "PlayerSpawn", "CheckAbortCleanup", sv_PProtect.checkComeback )


-- CLEAN ALL DISCONNECTED PLAYERS PROPS
function sv_PProtect.CleanAllDisconnectedPlayersProps( ply )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		if ent.PatchPPCleanup != nil and ent.PatchPPCleanup != "" then
			ent:Remove()
		end

	end
	sv_PProtect.InfoNotify( ply, "Cleaned all disconnected Players Props!" )
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed all Props from disconnected Players!" )

end
concommand.Add("btn_cleandiscprops", sv_PProtect.CleanAllDisconnectedPlayersProps)


---------------------------------
--  CLEANUP MAP/PLAYERS PROPS  --
---------------------------------

-- CLEANUP EVERYTHING
function sv_PProtect.CleanupEverything( ply )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end

	game.CleanUpMap()
	sv_PProtect.InfoNotify(ply, "Cleaned Map!")

end
concommand.Add("btn_cleanup", sv_PProtect.CleanupEverything)

-- CLEANUP PLAYERS PROPS
function sv_PProtect.CleanupPlayersProps( ply, cmd, args )

	if !ply:IsAdmin() and !ply:IsSuperAdmin() then return end
	local count = 0

	for k, v in pairs( ents.GetAll() ) do

		ent = v
		local Owner = ent:CPPIGetOwner()

		if Owner != nil and Owner:GetName() == tostring(args[1]) then
			ent:Remove()
			count = count + 1
		end

	end

	sv_PProtect.InfoNotify(ply, "Cleaned " .. tostring(args[1]) .. "'s Props! (" .. count .. ")")
	print( "[PatchProtect - Cleanup] " .. ply:Nick() .. " removed " .. count .. " Props from " .. tostring(args[1]) .. "!" )

end
concommand.Add("btn_cleanup_player", sv_PProtect.CleanupPlayersProps)



-------------------
--  OWNER TABLE  --
-------------------

function sv_PProtect.sendOwners( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	net.Start("PatchPPOwner")
		--net.WriteEntity( Owner )
		--net.WriteType( id )
		net.WriteTable( ownerTable )
	net.Send( ply )
	

end
hook.Add( "PlayerInitialSpawn", "sentOwnerTable", sv_PProtect.sendOwners )
