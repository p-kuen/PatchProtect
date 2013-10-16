-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF TOOL-ENTS
if cleanup then

	function cleanup.Add( ply, enttype, ent )
		
		if ply.duplicate == true then
			if enttype != "duplicates" then
				ply.duplicate = false
			end
		end

		if IsEntity( ent ) == false or ent:IsPlayer() then return end
		ent:CPPISetOwner( ply )

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
	if not ent:IsValid() or ent:IsWorld() then return false end

	local Owner = ent:CPPIGetOwner()
	if Owner == nil then return false end

	if !ent:IsWorld() and Owner == ply then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPhysPickup", sv_PProtect.checkPlayer )
hook.Add( "GravGunOnPickedUp", "AllowGravPickup", sv_PProtect.checkPlayer )
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.checkPlayer )
hook.Add( "CanUse", "AllowUseing", sv_PProtect.checkPlayer )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.canToolProtection( ply, trace, tool )
	
	if sv_PProtect.checkAdmin( ply ) then return true end
	if tool == "creator" and sv_PProtect.Settings.PropProtection["blockcreatortool"] == true then return false end

	local ent = trace.Entity
	if not ent:IsValid() and not ent:IsWorld() then return false end

	local Owner = ent:CPPIGetOwner()
	if Owner == nil then return false end
	
	if ent:IsWorld() and sv_PProtect.Settings.PropProtection["tool_world"] == false then return false end
	
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

function sv_PProtect.canProperty( ply, property, ent )

	if sv_PProtect.checkAdmin( ply ) then return true end
	if property == "drive" and sv_PProtect.Settings.PropProtection["cdrive"] == false then return false end

	local Owner = ent:CPPIGetOwner()

	if !ent:IsWorld() and Owner == ply and property != "persist" then
 		return true
 	else
 		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
 		return false
 	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.canProperty )



------------------------------
--  DAMAGE PROP PROTECTION  --
------------------------------

function sv_PProtect.canDamage( ent, info )
	
	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()

	if !ent:IsValid() or ent:IsPlayer() or sv_PProtect.Settings.PropProtection["use"] == false or sv_PProtect.Settings.PropProtection["damageprotection"] == false then return end

	if Attacker:IsPlayer() and Owner != Attacker then
		
		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and sv_PProtect.Settings.PropProtection["noantiadmin"] == true then return end

		info:SetDamage(0)
		timer.Simple( 0.1, function()
			if ent:IsOnFire() then
				ent:Extinguish()
			end
		end )

	end

end
hook.Add( "EntityTakeDamage", "AllowEntityDamage", sv_PProtect.canDamage )



---------------------------------
--  PHYSGUN-RELOAD PROTECTION  --
---------------------------------

function sv_PProtect.canPhysReload( weapon, ply )
	
	if sv_PProtect.checkAdmin( ply ) then return true end
	if sv_PProtect.Settings.PropProtection["reloadprotection"] == false then return false end

	local entity = ply:GetEyeTrace().Entity
	if !entity:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
		return false
	end

end
hook.Add( "OnPhysgunReload", "AllowPhysReload", sv_PProtect.canPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.canGravPunt( ply, ent )

	if sv_PProtect.checkAdmin( ply ) then return true end
	if sv_PProtect.Settings.PropProtection["gravgunprotection"] == false then return false end
	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
		return false
	end

end
hook.Add( "GravGunPunt", "AllowGravPunt", sv_PProtect.canGravPunt )



------------------
--  NETWORKING  --
------------------

-- SET OWNER OVER PROPERTY MENU
net.Receive( "SetOwnerOverProperty", function( len, pl )

	local Info = net.ReadTable()
	local ent = Info[1]
	if !ent:IsValid() then return end
	local Owner = ent:CPPIGetOwner()

	if pl != Owner then return end

	ent:CPPISetOwner( Info[2] )

end )

-- SEND THE OWNER TO THE CLIENT
net.Receive( "getOwner", function( len, pl )
	
	local ent = net.ReadEntity()

	net.Start( "sendOwner" )
		net.WriteEntity( ent:CPPIGetOwner() )
	net.Send( pl )

end )
