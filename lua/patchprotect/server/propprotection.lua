----------------
--  SETTINGS  --
----------------

function sv_PProtect.CheckPPAdmin( ply, ent )

	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or ply:IsSuperAdmin() then return true end
	if ply:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] == 1 then
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

		-- Prop-Block
		if ent:GetModel() != nil then
			local mdl = string.lower( ent:GetModel() )
			if sv_PProtect.CheckASAdmin( ply ) == false and sv_PProtect.Settings.Antispam[ "propblock" ] == 1 and isstring( mdl ) and table.HasValue( sv_PProtect.Settings.Blockedprops, mdl ) or string.find( mdl, "/../" ) then
				sv_PProtect.Notify( ply, "This Prop is in the Blacklist!" )
				ent:Remove()
				return false
			end
		end
		
		-- Duplicator exception
		if ply.duplicate == true and enttype != "duplicates" and enttype != "AdvDupe2" then
			ply.duplicate = false
		end

		-- Set owner of the entity
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

	-- Check Entity
	if !ent:IsValid() or ent:IsWorld() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to hold this object!" )
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

	-- Check Creatorprotection
	if tool == "creator" and sv_PProtect.Settings.Propprotection[ "creatorprotection" ] == 1 then
		return true
	elseif tool == "creator" and sv_PProtect.Settings.Propprotection[ "creatorprotection" ] == 0 then
		sv_PProtect.Notify( ply, "You are not allowed to use the creator tool!" )
		return false
	end

	-- Check Entity
	local ent = trace.Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or ent:IsWorld() and ent.World != true or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "toolgun" ) then
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
	if sv_PProtect.Settings.Propprotection[ "useprotection" ] == 0 then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- World-Entity
	if ent.World and string.find( ent:GetClass(), "func_" ) and sv_PProtect.Settings.Propprotection[ "worldbutton" ] == 1 then return true end
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to use this object!" )
		return false
	end

end
hook.Add( "PlayerUse", "AllowUsing", sv_PProtect.CanUse )



------------------------------
--  PROP PICKUP PROTECTION  --
------------------------------
function sv_PProtect.CanPickup( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end
	if sv_PProtect.Settings.Propprotection[ "proppickup" ] == 0 then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to pickup this object!" )
		return false
	end

end
hook.Add( "AllowPlayerPickup", "PropPickup", sv_PProtect.CanPickup )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

-- CAN PROPERTY
function sv_PProtect.CanProperty( ply, property, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end
	if property == "persist" then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end
	
	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "property" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to change the properties on this object!" )
		return false
	end

end
hook.Add( "CanProperty", "AllowProperty", sv_PProtect.CanProperty )

-- CAN DRIVE
function sv_PProtect.CanDrive( ply, ent )
	
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Driveprotection
	if sv_PProtect.Settings.Propprotection[ "propdriving" ] == 0 then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "property" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to drive this object!" )
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

	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or sv_PProtect.Settings.Propprotection[ "damageprotection" ] == 0 then return end
	
	if Attacker:IsPlayer() and Owner != Attacker and !sv_PProtect.isBuddy( Owner, Attacker, "damage" ) then

		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] == 1 then return end

		info:SetDamage( 0 )
		timer.Simple( 0.1, function()

			if ent:IsOnFire() then
				ent:Extinguish()
			end

		end )

	elseif !Attacker:IsPlayer() then 

		return false

	elseif Attacker:IsPlayer() and Owner == Attacker then 

		return

	end

end
hook.Add( "EntityTakeDamage", "AllowEntityDamage", sv_PProtect.CanDamage )



---------------------------------
--  PHYSGUN-RELOAD PROTECTION  --
---------------------------------

function sv_PProtect.CanPhysReload( weapon, ply )
	
	if sv_PProtect.CheckPPAdmin( ply, ply:GetEyeTrace().Entity ) then return end

	-- Check Reloadprotection
	if sv_PProtect.Settings.Propprotection[ "reloadprotection" ] == 0 then return end
	
	-- Check Entity
	local ent = ply:GetEyeTrace().Entity
	if !ent:IsValid() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.isBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to unfreeze this object!" )
		return false
	end

end
hook.Add( "OnPhysgunReload", "AllowPhysReload", sv_PProtect.CanPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.CanGravPunt( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Gravgunprotection
	if sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] == 0 then return false end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 1 then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to punt this object!" )
		return false
	end

end
hook.Add( "GravGunPunt", "AllowGravPunt", sv_PProtect.CanGravPunt )

function sv_PProtect.CanGravPickup( ply, ent )

	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Gravgunprotection
	if sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] == 0 then return false end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- World-Entity
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 0 then
		local worlddrop = true
	end

	-- Check Owner
	if ply != ent:CPPIGetOwner() or worlddrop then
		sv_PProtect.Notify( ply, "You are not allowed to use the Grav-Gun on this object!" )
		ply:DropObject()
	end

end
hook.Add( "GravGunOnPickedUp", "AllowGravPickup", sv_PProtect.CanGravPickup )



-----------------------
--  SET WORLD PROPS  --
-----------------------

function sv_PProtect.SetWorldProps()

	table.foreach( ents:GetAll(), function( id, ent )

		if string.find( tostring( ent:GetClass() ), "func_" ) or string.find( tostring( ent:GetClass() ), "prop_" ) then
			ent.World = true
		end
		
	end )

end
hook.Add( "PersistenceLoad", "SetWorldOwnedEnts", sv_PProtect.SetWorldProps )



------------------
--  NETWORKING  --
------------------

-- SEND THE OWNER TO THE CLIENT
net.Receive( "pprotect_get_owner", function( len, pl )
	
	local ent = net.ReadEntity()
	local info = ""

	if sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "physgun" ) == true or 
	sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "use" ) == true or 
	sv_PProtect.isBuddy( ent:CPPIGetOwner(), pl, "toolgun" ) == true then
		info = "buddy"
	end

	if ent.World == true then info = "world" end

	net.Start( "pprotect_send_owner" )
		net.WriteEntity( ent:CPPIGetOwner() )
		net.WriteString( info )
	net.Send( pl )

end )
