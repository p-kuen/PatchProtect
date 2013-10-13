-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF TOOL-ENTS
if cleanup then

	function cleanup.Add( ply, type, ent )
		
		if IsEntity(ent) == false or ent:IsPlayer() then return end
		ent:CPPISetOwner(ply)

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

-- CHECK ADMIN FUNCTION
function sv_PProtect.checkAdmin( ply )

	if sv_PProtect.Settings.PropProtection["use"] == false or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.PropProtection["noantiadmin"] == true then return true end

end

-- GENERAL CHECK-PLAYER FUNCTION
function sv_PProtect.checkPlayer( ply, ent )

	if sv_PProtect.checkAdmin( ply ) then return true end

	local Owner = ent:CPPIGetOwner()

	if Owner == nil then return false end

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

function sv_PProtect.canToolProtection( ply, trace, tool )
	
	if sv_PProtect.checkAdmin( ply ) then return true end

	local ent = trace.Entity
	if not ent:IsValid() then return end

	local Owner = ent:CPPIGetOwner()

	if ent:IsWorld() and tonumber(sv_PProtect.Settings.PropProtection["tool_world"]) == 0 then return false end

	if Owner == ply or ent:IsWorld() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end
 	
end



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

function sv_PProtect.playerProperty( ply, string, ent )

	if sv_PProtect.checkAdmin( ply ) then return true end
	if string == "drive" and sv_PProtect.Settings.PropProtection["cdrive"] == false then return false end

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



-------------------------
--  RELOAD PROTECTION  --
-------------------------

function sv_PProtect.PhysgunReload( weapon, ply )
	
	if sv_PProtect.checkAdmin( ply ) then return end
	if sv_PProtect.Settings.PropProtection["reloadprotection"] == false then return false end

	local entity = ply:GetEyeTrace().Entity
	if !entity:IsValid() then return false end

	if ply != entity:CPPIGetOwner() then return false end

end
hook.Add("OnPhysgunReload", "PhysgunReloading", sv_PProtect.PhysgunReload)



------------------
--  NETWORKING  --
------------------

-- SET OWNER OVER PROPERTY MENU
net.Receive( "SetOwnerOverProperty", function( len, pl )

	local sentInformation = net.ReadTable()
	local ent = sentInformation[1]
	local Owner = ent:CPPIGetOwner()

	if pl != Owner then return end

	ent:CPPISetOwner( sentInformation[2] )

end )

-- SEND THE OWNER TO THE CLIENT
net.Receive( "getOwner", function( len, pl )
     
	local entity = net.ReadEntity()

	net.Start("sendOwner")
		net.WriteEntity( entity:CPPIGetOwner() )
	net.Send( pl )

end )
