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

		if ent == nil or enttype == nil then return end
		if ent:IsPlayer() then return end

		--print(ent)
		--print(enttype)
		ent:CPPISetOwner( ply )

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

-- CHECK ADMIN FUNCTION
function sv_PProtect.CheckPPAdmin( ply )

	if sv_PProtect.Settings.PropProtection["use"] == false or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.PropProtection["noantiadmin"] == true then return true end

end

-- GENERAL CHECK-PLAYER FUNCTION
function sv_PProtect.CheckPlayer( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply ) == true then return true end
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
hook.Add( "PhysgunPickup", "AllowPhysPickup", sv_PProtect.CheckPlayer )
hook.Add( "GravGunOnPickedUp", "AllowGravPickup", sv_PProtect.CheckPlayer )
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.CheckPlayer )
hook.Add( "CanUse", "AllowUseing", sv_PProtect.CheckPlayer )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.CanToolProtection( ply, trace, tool )
	
	if sv_PProtect.CheckPPAdmin( ply ) == true then return true end
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

function sv_PProtect.CanProperty( ply, property, ent )

	if sv_PProtect.CheckPPAdmin( ply ) == true then return true end
	if property == "drive" and sv_PProtect.Settings.PropProtection["cdrive"] == false then return false end

	local Owner = ent:CPPIGetOwner()

	if !ent:IsWorld() and Owner == ply and property != "persist" then
 		return true
 	else
 		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
 		return false
 	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.CanProperty )



------------------------------
--  DAMAGE PROP PROTECTION  --
------------------------------

function sv_PProtect.CanDamage( ent, info )
	
	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()

	if !ent:IsValid() or ent:IsPlayer() or sv_PProtect.Settings.PropProtection["use"] == false or sv_PProtect.Settings.PropProtection["damageprotection"] == false then return end

	if Attacker:IsPlayer() and Owner != Attacker then
		
		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and sv_PProtect.Settings.PropProtection["noantiadmin"] == true then return end

		info:SetDamage( 0 )
		timer.Simple( 0.1, function()
			if ent:IsOnFire() then
				ent:Extinguish()
			end
		end )

	end

end
hook.Add( "EntityTakeDamage", "AllowEntityDamage", sv_PProtect.CanDamage )



---------------------------------
--  PHYSGUN-RELOAD PROTECTION  --
---------------------------------

function sv_PProtect.CanPhysReload( weapon, ply )
	
	if sv_PProtect.CheckPPAdmin( ply ) then return true end
	if sv_PProtect.Settings.PropProtection["reloadprotection"] == false then return false end

	local entity = ply:GetEyeTrace().Entity
	if !entity:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
		return false
	end

end
hook.Add( "OnPhysgunReload", "AllowPhysReload", sv_PProtect.CanPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.CanGravPunt( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply ) then return true end
	if sv_PProtect.Settings.PropProtection["gravgunprotection"] == false then return false end
	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
		return false
	end

end
hook.Add( "GravGunPunt", "AllowGravPunt", sv_PProtect.CanGravPunt )



------------------
--  NETWORKING  --
------------------

-- SEND THE OWNER TO THE CLIENT
net.Receive( "getOwner", function( len, pl )
	
	local ent = net.ReadEntity()

	net.Start( "sendOwner" )
		net.WriteEntity( ent:CPPIGetOwner() )
	net.Send( pl )

end )
