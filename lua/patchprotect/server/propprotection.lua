----------------------
--  GENERAL CHECKS  --
----------------------

-- CHECK ADMIN
function sv_PProtect.CheckPPAdmin( ply, ent )

	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or ply:IsSuperAdmin() and sv_PProtect.Settings.Propprotection[ "superadmins" ] == 1 then
		return true
	end

	if ply:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] == 1 then
		if ent and ent:CPPIGetOwner() and ent:CPPIGetOwner():IsSuperAdmin() and cl_PProtect.Settings.Propprotection[ "adminssuperadmins" ] == 0 then
			return false
		end
		return true
	end
	
	return false

end

-- CHECK SHARED
function sv_PProtect.isShared( ent, mode )

	if ent.share == nil then return false end
	if ent.share[ mode ] == true then return true else return false end

end



-----------------
--  SET OWNER  --
-----------------

-- ADV DUPE
hook.Add( "AdvDupe_StartPasting", "pprotect_startpaste", function( player, num )
	player.pasting = true
end )
hook.Add( "AdvDupe_FinishPasting", "pprotect_finishpaste", function( data, current )
	if data[current].Player then data[current].Player.pasting = false end
end )

-- SET OWNER OF TOOL-ENTS
if cleanup then
	
	local Clean = cleanup.Add

	function cleanup.Add( ply, enttype, ent )

		if !ent:IsValid() or !ply:IsPlayer() then return end

		-- Prop-Block
		if ent:GetModel() != nil then
			local mdl = string.lower( ent:GetModel() )
			if sv_PProtect.CheckASAdmin( ply ) == false and sv_PProtect.Settings.Antispam[ "propblock" ] == 1 and isstring( mdl ) and table.HasValue( sv_PProtect.Settings.Blockedprops, mdl ) or string.find( mdl, "/../" ) then
				sv_PProtect.Notify( ply, "This prop is in the blacklist!" )
				ent:Remove()
				return
			end
		end
		
		-- Prop-In-Prop protection
		local trace = util.TraceLine( { start = ent:LocalToWorld( ent:OBBMins() ), endpos = ent:LocalToWorld( ent:OBBMaxs() ), filter = ent } )
		if IsValid( trace.Entity ) and !trace.Entity:IsPlayer() and sv_PProtect.CheckASAdmin( ply ) == false and sv_PProtect.Settings.Antispam[ "propinprop" ] == 1 and ply.duplicate == false and ent:GetClass() == "prop_physics" then
			sv_PProtect.Notify( ply, "You are not allowed to spawn a prop in an other prop!" )
			ent:Remove()
			return
		end
		
		-- Duplicator exception
		if ply.duplicate == true and enttype != "duplicates" and enttype != "AdvDupe2" and ply.pasting != true then
			ply.duplicate = false
		end

		-- Set owner of the entity
		ent:CPPISetOwner( ply )

		-- Run normal function now
		Clean( ply, enttype, ent )

	end

end



--------------------
--  CHECK PLAYER  --
--------------------

-- GENERAL CHECK-PLAYER FUNCTION
function sv_PProtect.CanTouch( ply, ent )

	-- Check Player
	if ent:IsPlayer() then return end
	
	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() or ent:IsWorld() then return false end

	-- Check Shared
	if sv_PProtect.isShared( ent, "phys" ) then return true end

	-- Check World
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
	
	local ent = trace.Entity

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end

	-- Check Protection
	if tool == "creator" and sv_PProtect.Settings.Propprotection[ "creatorprotection" ] == 0 then
		sv_PProtect.Notify( ply, "You are not allowed to use the creator tool!" )
		return false
	end

	-- Check Shared
	if sv_PProtect.isShared( ent, "tool" ) then return true end

	-- Check World
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
	
	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "useprotection" ] == 0 then return true end

	-- Check Shared
	if sv_PProtect.isShared( ent, "use" ) then return true end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldbutton" ] == 1 then return true end
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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "proppickup" ] == 0 then return true end

	-- Check World
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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Persist
	if property == "persist" and !ply:IsSuperAdmin() then
		sv_PProtect.Notify( ply, "You are not allowed to make this object persistant!" )
		return false
	end

	-- Check World
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
	
	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "propdriving" ] == 0 then return false end

	-- Check World
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

	-- Check Entity
	if !ent:IsValid() or ent:IsPlayer() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "enabled" ] == 0 or sv_PProtect.Settings.Propprotection[ "damageprotection" ] == 0 then return end
	
	-- Check Owner
	if Attacker:IsPlayer() and Owner != Attacker and !sv_PProtect.isBuddy( Owner, Attacker, "damage" ) then

		if Attacker:IsSuperAdmin() or Attacker:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] == 1 then return end

		info:SetDamage( 0 )
		timer.Simple( 0.1, function()

			if !ent:IsValid() then return end

			if ent:IsOnFire() then
				ent:Extinguish()
			end

		end )

	elseif !Attacker:IsPlayer() then return false

	elseif Attacker:IsPlayer() and Owner == Attacker then return

	end

end
hook.Add( "EntityTakeDamage", "AllowEntityDamage", sv_PProtect.CanDamage )



---------------------------------
--  PHYSGUN-RELOAD PROTECTION  --
---------------------------------

function sv_PProtect.CanPhysReload( weapon, ply )
	
	local ent = ply:GetEyeTrace().Entity

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "reloadprotection" ] == 0 then return end
	
	-- Check World
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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] == 0 then return false end

	-- Check World
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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] == 0 then return false end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] == 0 then
		local worldprop = true
	end

	-- Check Owner
	if ply != ent:CPPIGetOwner() or worldprop then
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

		if string.find( ent:GetClass(), "func_" ) or string.find( ent:GetClass(), "prop_" ) then
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

-- SEND NEW SHARED ENTITY INFORMAITON TO THE CLIENT
sv_PProtect.shared = nil
net.Receive( "pprotect_get_sharedEntity", function( len, pl )
	
	local entity = net.ReadEntity()
	sv_PProtect.shared = entity

	net.Start( "pprotect_send_sharedEntity" )

		if istable( entity.share ) then
			net.WriteTable( entity.share )
		else
			net.WriteTable( {} )
		end

	net.Send( pl )

end )

-- SAVE NEW SHARED ENTITY
net.Receive( "pprotect_save_sharedEntity", function( len, pl )
	
	local entity = sv_PProtect.shared
	local info = net.ReadTable()
	if istable( info ) then entity.share = info end

end )
