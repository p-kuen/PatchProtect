
-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF PROPS
function sv_PProtect.SpawnedProp( ply, mdl, ent )

	timer.Simple( 0.1, function()


	end )

end
hook.Add("PlayerSpawnedProp", "SpawnedProp", sv_PProtect.SpawnedProp)
hook.Add("PlayerSpawnedRagdoll", "SpawnedRagdoll", sv_PProtect.SpawnedEnt)
hook.Add("PlayerSpawnedEffect", "SpawnedEffect", sv_PProtect.SpawnedEnt)

-- SET OWNER OF ENTS
function sv_PProtect.SpawnedEnt( ply, ent )

	timer.Simple( 0.1, function()

		--local Owner = ent:CPPIGetOwner()

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

net.Receive( "SetOwnerOverProperty", function( len, pl )

	local sentInformation = net.ReadTable()
	local ent = sentInformation[1]
	local newOwner = sentInformation[2]
	local Owner = ent:CPPIGetOwner()

	if pl != Owner then return end

	ent:CPPISetOwner(newOwner)

end )



--------------------
--  CHECK PLAYER  --
--------------------

function sv_PProtect.checkPlayer(ply, ent)

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end

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

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and tonumber(sv_PProtect.Settings.PropProtection["noantiadmin"]) == 1 then return true end
	if ply:IsSuperAdmin() then return true end

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

	if tonumber(sv_PProtect.Settings.PropProtection["use"]) == 0 or ply:IsSuperAdmin() then return true end
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



------------------
--  NETWORKING  --
------------------

function sv_PProtect.sendOwnerToClient(ent, ply)
	
	net.Start("sendOwner")
		net.WriteEntity( ent:CPPIGetOwner() )
	net.Send( ply )

end

net.Receive( "getOwner", function( len, pl )
     
	local entity = net.ReadEntity()

	sv_PProtect.sendOwnerToClient(entity, pl)

end )
