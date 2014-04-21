----------------
--  SETTINGS  --
----------------

function sv_PProtect.CheckPPAdmin( ply, ent )

	if sv_PProtect.Settings.PropProtection[ "enabled" ] == 0 or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.PropProtection[ "admins" ] == 1 then
		if ent:IsValid() and ent:CPPIGetOwner() != nil then
			if ent:CPPIGetOwner():IsSuperAdmin() == true then return false else return true end
		else
			return true
		end
	end
	return false

end



-----------------
--  SET OWNER  --
-----------------

-- SET OWNER OF TOOL-ENTS
if cleanup then
	
	local Clean = cleanup.Add

	function cleanup.Add( ply, enttype, ent )
		
		if ply.duplicate == true and enttype != "duplicates" then
			ply.duplicate = false
		end

		if ent != nil and ent:IsValid() and ply:IsPlayer() then
			ent:CPPISetOwner( ply )
		end

		Clean( ply, enttype, ent )

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

-- GENERAL CHECK-PLAYER FUNCTION
function sv_PProtect.CanTouch( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	if !ent:IsValid() or ent:IsWorld() then return false end
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPhysPickup", sv_PProtect.CanTouch )
hook.Add( "GravGunOnPickedUp", "AllowGravPickup", sv_PProtect.CanTouch )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.CanToolProtection( ply, trace, tool )
	
	if sv_PProtect.CheckPPAdmin( ply, trace.Entity ) then return true end
	if tool == "creator" and sv_PProtect.Settings.PropProtection[ "creatorprotection" ] == 1 then return false end

	local ent = trace.Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end
	
	local Owner = ent:CPPIGetOwner()
	if ply != Owner and !ent:IsWorld() then return false end

	if ent:IsWorld() then return false end
	
	if ply == Owner or ent:IsWorld() and ent.WorldOwned != true or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "toolgun" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to use " .. tool .. " on this object!" )
		return false
	end

end



---------------------------
--  USE PROP PROTECTION  --
---------------------------

function sv_PProtect.CanUse( ply, ent )
	
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	if sv_PProtect.Settings.PropProtection[ "useprotection" ] == 0 then return true end

	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to use this object!" )
		return false
	end

end
hook.Add( "PlayerUse", "AllowUsing", sv_PProtect.CanUse )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

-- CAN PROPERTY
function sv_PProtect.CanProperty( ply, property, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	
	if ply == ent:CPPIGetOwner() and property != "persist" or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "property" ) and property != "persist" then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to change the propierties on this object!" )
		return false
	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.CanProperty )

-- CAN DRIVE
function sv_PProtect.CanDrive( ply, ent )
	
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	if sv_PProtect.Settings.PropProtection[ "propdriving" ] == 0 then
		sv_PProtect.Notify( ply, "You are not allowed to drive this object!" )
		return false
	end

	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "property" ) then
		return true
	else
		return false
	end

end
hook.Add( "CanDrive", "AllowDriving", sv_PProtect.CanDrive )



------------------------------
--  DAMAGE PROP PROTECTION  --
------------------------------

function sv_PProtect.CanDamage( ent, info )
	
	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()

	if !ent:IsValid() or ent:IsPlayer() then return false end
	if sv_PProtect.Settings.PropProtection[ "enabled" ] == 0 or sv_PProtect.Settings.PropProtection[ "damageprotection" ] == 0 then return true end
	
	if Attacker:IsPlayer() and Owner != Attacker or Attacker:IsPlayer() and !sv_PProtect.isBuddy( Owner, Attacker, "damage" ) then
		
		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and sv_PProtect.Settings.PropProtection[ "admins" ] == 1 then return end

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
	
	if sv_PProtect.CheckPPAdmin( ply, ply:GetEyeTrace().Entity ) then return end

	if sv_PProtect.Settings.PropProtection[ "reloadprotection" ] == 0 then return end
	
	local ent = ply:GetEyeTrace().Entity
	
	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to use the 'reload' function on this object!" )
		return false
	end

end
hook.Add( "OnPhysgunReload", "AllowPhysReload", sv_PProtect.CanPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.CanGravPunt( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	if sv_PProtect.Settings.PropProtection[ "gravgunprotection" ] == 0 then return false end

	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to use the Grav-Gun on this object!" )
		return false
	end

end
hook.Add( "GravGunPunt", "AllowGravPunt", sv_PProtect.CanGravPunt )



-----------------------
--  SET WORLD PROPS  --
-----------------------

function sv_PProtect.SetWorldProps()

	table.foreach( ents:GetAll(), function( key, value )

		if value:IsValid() and value:GetClass() == "prop_physics" then 
			local ent = value
			ent.WorldOwned = true
		end
		
	end )

end
hook.Add( "PersistenceLoad", "SetWorldOwnedEnts", sv_PProtect.SetWorldProps )



------------------
--  NETWORKING  --
------------------

-- SEND THE OWNER TO THE CLIENT
net.Receive( "get_owner", function( len, pl )
	
	local ent = net.ReadEntity()
	local info = ""

	if sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "physgun" ) == true or 
	sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "use" ) == true or 
	sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "toolgun" ) == true then
		info = "buddy"
	end

	if ent.WorldOwned == true then info = "world" end

	net.Start( "send_owner" )
		net.WriteEntity( ent:CPPIGetOwner() )
		net.WriteString( info )
	net.Send( pl )

end )
