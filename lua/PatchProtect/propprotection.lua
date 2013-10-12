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
			net.WriteTable( ownerTable )
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

-- SET OWNER OF TOOL-ENTS
if cleanup then

	function cleanup.Add(ply, type, ent)
		
		if IsEntity(ent) == false or ent:IsPlayer() then return end
		ent:CPPISetOwner(ply)

	end

end

-- SET OWNER OVER PROPERTY MENU
function sv_PProtect.setownerbyproperty( ply, cmd, args )

	--We have to make that different. At the moment, I don't know how to make that as simple as possible.
	--Maybe we send with usermessages or somthing like that the entity,
	--which the player is looking at and the player-entity (the person, who will own the prop)

	--Also it is very important to add also here an if-condition, that he is really
	--the owner of the prop and also an ent:IsValid() of the entity, which the player is looking at.
	
end
concommand.Add("setpropertyowner", sv_PProtect.setownerbyproperty)



--------------------
--  CHECK PLAYER  --
--------------------

function sv_PProtect.checkPlayer(ply, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end
	if ply:IsSuperAdmin() then return true end

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

function sv_PProtect.EntityDamage( ent, info )
	
	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()
	
	if !ent:IsValid() or ent:IsPlayer() or tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 or tonumber(sv_PProtect.Settings.PropProtection["damageprotection"]) == 0 then return end
	if Owner == Attacker then return end

	info:SetDamage(0)

end
hook.Add("EntityTakeDamage", "EntityGetsDamage", sv_PProtect.EntityDamage)



-------------------
--  OWNER TABLE  --
-------------------

function sv_PProtect.sendOwners( ply )

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 then return end

	net.Start("PatchPPOwner")
		net.WriteTable( ownerTable )
	net.Send( ply )
	

end
hook.Add( "PlayerInitialSpawn", "sentOwnerTable", sv_PProtect.sendOwners )
