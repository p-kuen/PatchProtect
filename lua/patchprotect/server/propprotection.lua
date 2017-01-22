----------------------
--  GENERAL CHECKS  --
----------------------

-- CHECK ADMIN
function sv_PProtect.CheckPPAdmin( ply, ent )

	if ent != nil and ent:IsValid() and !ent:CPPIGetOwner() and !ent:GetNWBool( "pprotect_world" ) then ent:SetNWBool( "pprotect_world", true ) end

	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or 
	ply:IsSuperAdmin() and sv_PProtect.Settings.Propprotection[ "superadmins" ] or 
	ply:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] then
		if ent != nil and ent:IsValid() and ent:CPPIGetOwner() != nil and !ply:IsSuperAdmin() and ent:CPPIGetOwner():IsSuperAdmin() then return false end
		return true
	else
		return false
	end

end

-- CHECK WORLD
function sv_PProtect.CheckWorld( ent, sett )

	if ent:GetNWBool( "pprotect_world" ) and sv_PProtect.Settings.Propprotection[ "world" .. sett ] then
		return true
	else
		return false
	end

end

-- CHECK SHARED
function sv_PProtect.IsShared( ent, mode )

	if !ent or !ent:IsValid() or !mode or !isstring( mode ) then return false end
	return ent:GetNWBool( "pprotect_shared_" .. mode )

end



-----------------
--  SET OWNER  --
-----------------

-- GET DATA
local en, uc, ue, up, uf = nil, undo.Create, undo.AddEntity, undo.SetPlayer, undo.Finish
function undo.Create( typ ) en = { t = typ, e = {}, o = nil } uc( typ ) end
function undo.AddEntity( ent ) if ent != nil and IsEntity( ent ) and ent:GetClass() != "phys_constraint" then table.insert( en.e, ent ) end ue( ent ) end
function undo.SetPlayer( ply ) en.o = ply up( ply ) end
function undo.Finish() sv_PProtect.SetOwner( en.o, en.t, en.e ) en = nil uf() end

-- SET OWNER
function sv_PProtect.SetOwner( ply, typ, ent )

	if !ent or !ply:IsPlayer() then return end

	-- Duplicator-Exception
	if ply.duplicate == true and typ != "Duplicator" and !string.find( typ, "AdvDupe" ) then ply.duplicate = false end

	-- Set Owner Of Ents
	table.foreach( ent, function( k, e )

		-- Check Entity
		if !e:IsValid() then return end

		-- Set Owner
		e:CPPISetOwner( ply )

		-- Check PropInProp
		if ply.duplicate or !sv_PProtect.Settings.Antispam[ "propinprop" ] or sv_PProtect.CheckPPAdmin( ply ) or e:GetClass() != "prop_physics" then return end

		-- PropInProp-Protection
		if e:GetPhysicsObject():IsPenetrating() then
			sv_PProtect.Notify( ply, "You are not allowed to spawn a prop in an other prop!" )
			e:Remove()
		end

	end )

end



-------------------------------
--  PHYSGUN PROP PROTECTION  --
-------------------------------

function sv_PProtect.CanTouch( ply, ent )

	-- Check Entity
	if !ent:IsValid() or ent:IsWorld() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Entity 2
	if ent:IsPlayer() then return false end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "phys" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "phys" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to hold this object!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "pprotect_touch", sv_PProtect.CanTouch )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.CanToolProtection( ply, trace, tool )

	local ent = trace.Entity

	-- Check Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if tool == "creator" and !sv_PProtect.Settings.Propprotection[ "creator" ] then
		sv_PProtect.Notify( ply, "You are not allowed to use the creator tool!" )
		return false
	end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "tool" ) or ent:IsWorld() then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "tool" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "tool" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to use " .. tool .. " on this object!" )
		return false
	end

end



---------------------------
--  USE PROP PROTECTION  --
---------------------------

function sv_PProtect.CanUse( ply, ent )

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection / Gamemode
	if !sv_PProtect.Settings.Propprotection[ "use" ] or engine.ActiveGamemode() == "prop_hunt" then return true end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "use" ) then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "use" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to use this object!" )
		return false
	end

end
hook.Add( "PlayerUse", "pprotect_use", sv_PProtect.CanUse )



------------------------------
--  PROP PICKUP PROTECTION  --
------------------------------

function sv_PProtect.CanPickup( ply, ent )

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "proppickup" ] then return end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "use" ) then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "use" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to pick up this object!" )
		return false
	end

end
hook.Add( "AllowPlayerPickup", "pprotect_proppickup", sv_PProtect.CanPickup )



--------------------------------
--  PROPERTY PROP PROTECTION  --
--------------------------------

-- CAN PROPERTY
function sv_PProtect.CanProperty( ply, property, ent )

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Persist
	if property == "persist" then
		sv_PProtect.Notify( ply, "You are not allowed to make this object persistant!" )
		return false
	end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "prop" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to change the properties on this object!" )
		return false
	end

end
hook.Add( "CanProperty", "pprotect_property", sv_PProtect.CanProperty )

-- CAN DRIVE
function sv_PProtect.CanDrive( ply, ent )

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "propdriving" ] then return false end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "prop" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to drive this object!" )
		return false
	end

end
hook.Add( "CanDrive", "pprotect_drive", sv_PProtect.CanDrive )



------------------------------
--  DAMAGE PROP PROTECTION  --
------------------------------

function sv_PProtect.CanDamage( ent, info )

	local ply = info:GetAttacker():CPPIGetOwner() or info:GetAttacker()

	-- Check Entity
	if !ent:IsValid() and ply:GetClass() != "player" and ply:GetClass() != "entityflame" then return end

	-- Check Admin
	if ply:IsPlayer() and sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "damage" ] then return end

	-- Check Damage from Player in Vehicle
	if ply:IsPlayer() and ply:InVehicle() and sv_PProtect.Settings.Propprotection[ "damageinvehicle" ] then
		sv_PProtect.Notify( ply, "You are not allowed to damage other players while sitting in a vehicle!" )
		return true
	end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "dmg" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "dmg" ) or ply:GetClass() == "entityflame" or ent:IsPlayer() then
		return
	else
		if ply:IsPlayer() then sv_PProtect.Notify( ply, "You are not allowed to damage this object!" ) end
		return true
	end

end
hook.Add( "EntityTakeDamage", "pprotect_damage", sv_PProtect.CanDamage )



---------------------------------
--  PHYSGUN-RELOAD PROTECTION  --
---------------------------------

function sv_PProtect.CanPhysReload( weapon, ply )

	local ent = ply:GetEyeTrace().Entity

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "reload" ] then return end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "phys" ) then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to unfreeze this object!" )
		return false
	end

end
hook.Add( "OnPhysgunReload", "pprotect_physreload", sv_PProtect.CanPhysReload )



-------------------------------
--  GRAVGUN PUNT PROTECTION  --
-------------------------------

function sv_PProtect.CanGravPunt( ply, ent )

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "gravgun" ] then return end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "pick" ) then return end 
	-- I assume people don't want to allow both grabing and throwing props using gravity gun

	-- Check Owner
	if ply == ent:CPPIGetOwner() then
		return
	else
		sv_PProtect.Notify( ply, "You are not allowed to punt this object!" )
		return false
	end

end
hook.Add( "GravGunPunt", "pprotect_gravpunt", sv_PProtect.CanGravPunt )

function sv_PProtect.CanGravPickup( ply, ent )

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "gravgun" ] then return false end

	-- Check World
	if sv_PProtect.CheckWorld( ent, "grav" ) then return end

	-- Check Owner
	if ply != ent:CPPIGetOwner() then
		sv_PProtect.Notify( ply, "You are not allowed to use the Grav-Gun on this object!" )
		ply:DropObject()
	end

end
hook.Add( "GravGunOnPickedUp", "pprotect_gravpickup", sv_PProtect.CanGravPickup )



-----------------------
--  SET WORLD PROPS  --
-----------------------

function sv_PProtect.setWorldProps()

	table.foreach( ents:GetAll(), function( id, ent )
		if string.find( ent:GetClass(), "func_" ) or string.find( ent:GetClass(), "prop_" ) then ent:SetNWBool( "pprotect_world", true ) end
	end )

end
hook.Add( "PersistenceLoad", "pprotect_worldprops", sv_PProtect.setWorldProps )
