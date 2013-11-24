----------------
--  SETTINGS  --
----------------

function sv_PProtect.CheckPPAdmin( ply, ent )

	if tobool( sv_PProtect.Settings.PropProtection["use"] ) == false or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and tobool( sv_PProtect.Settings.PropProtection["noantiadmin"] ) == true then
		if ent:IsValid() then
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
		
		if ply.duplicate == true then
			if enttype != "duplicates" then
				ply.duplicate = false
			end
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
function sv_PProtect.CheckPlayer( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	if !ent:IsValid() or ent:IsWorld() then return false end
	if ply == ent:CPPIGetOwner() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "AllowPhysPickup", sv_PProtect.CheckPlayer )
hook.Add( "GravGunOnPickedUp", "AllowGravPickup", sv_PProtect.CheckPlayer )
hook.Add( "PlayerUse", "AllowUsing", sv_PProtect.CheckPlayer )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.CanToolProtection( ply, trace, tool )
	
	if sv_PProtect.CheckPPAdmin( ply, trace.Entity ) then return true end
	if tool == "creator" and tobool( sv_PProtect.Settings.PropProtection[ "blockcreatortool" ] ) == true then return false end

	local ent = trace.Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end
	
	local Owner = ent:CPPIGetOwner()
	if ply != Owner and !ent:IsWorld() then return false end

	if ent:IsWorld() and tobool( sv_PProtect.Settings.PropProtection[ "tool_world" ] ) == false then return false end
	
	if ply == Owner or ent:IsWorld() and ent.WorldOwned != true then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

-- CAN PROPERTY
function sv_PProtect.CanProperty( ply, property, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	
	if ply == ent:CPPIGetOwner() and property != "persist" then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.CanProperty )

-- CAN DRIVE
function sv_PProtect.CanDrive( ply, ent )
	
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	if tobool( sv_PProtect.Settings.PropProtection[ "cdrive" ] ) == false then
		sv_PProtect.Notify( ply, "You are not allowed to do this!" )
		return false
	end

	if ply == ent:CPPIGetOwner() then
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
	if tobool( sv_PProtect.Settings.PropProtection[ "use" ] ) == false or tobool( sv_PProtect.Settings.PropProtection[ "damageprotection" ] ) == false then return true end
	
	if Attacker:IsPlayer() and Owner != Attacker then
		
		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and tobool( sv_PProtect.Settings.PropProtection[ "noantiadmin" ] ) == true then return end

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

	if tobool( sv_PProtect.Settings.PropProtection[ "reloadprotection" ] ) == false then return end
	
	local ent = ply:GetEyeTrace().Entity
	
	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return
	else
		return false
	end

end
hook.Add( "OnPhysgunReload", "AllowPhysReload", sv_PProtect.CanPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.CanGravPunt( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	if tobool( sv_PProtect.Settings.PropProtection[ "gravgunprotection" ] ) == false then return false end

	if !ent:IsValid() then return false end

	if ply == ent:CPPIGetOwner() then
		return true
	else
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
net.Receive( "getOwner", function( len, pl )
	
	local ent = net.ReadEntity()
	local went = ""

	if ent.WorldOwned == true then went = "World" end

	net.Start( "sendOwner" )
		net.WriteEntity( ent:CPPIGetOwner() )
		net.WriteString( went )
	net.Send( pl )

end )
