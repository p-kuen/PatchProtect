----------------------
--  GENERAL CHECKS  --
----------------------

-- CHECK ADMIN
function sv_PProtect.CheckPPAdmin( ply, ent )

	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or
		ply:IsSuperAdmin() and sv_PProtect.Settings.Propprotection[ "superadmins" ] or
		ply:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] then
		return true
	end

	if !IsValid( ent ) then return end
	if !ent:CPPIGetOwner() and !ent.World then return true end

end

-- CHECK SHARED
function sv_PProtect.IsShared( ent, mode )

	if ent.share == nil then return false end
	if ent.share[ mode ] == true then return true else return false end

end



-----------------
--  SET OWNER  --
-----------------

-- GET DATA
local en, uc, ue, up, uf = nil, undo.Create, undo.AddEntity, undo.SetPlayer, undo.Finish
function undo.Create( typ ) en = { t = typ, e = {}, o = nil } uc( typ ) end
function undo.AddEntity( ent ) if ent:GetClass() != "phys_constraint" then table.insert( en.e, ent ) end ue( ent ) end
function undo.SetPlayer( ply ) en.o = ply up( ply ) end
function undo.Finish() sv_PProtect.SetOwner( en.o, en.typ, en.e ) en = nil uf() end

-- SET OWNER
function sv_PProtect.SetOwner( ply, typ, ent )

	if !ent or !ply:IsPlayer() then return end

	-- Duplicator exception
	if ply.duplicate == true and typ != "Duplicator" and typ != "AdvDupe (pasting...)" and typ != "AdvDupe2_Paste" then ply.duplicate = false end

	-- Set owner of the entity
	table.foreach( ent, function( k, e )

		-- Check entity
		if !e:IsValid() then return end

		-- Set owner
		e:CPPISetOwner( ply )

		-- Check PropInProp-Exceptions
		if ply.duplicate or !sv_PProtect.Settings.Antispam[ "propinprop" ] or sv_PProtect.CheckPPAdmin( ply ) or e:GetClass() != "prop_physics" then return end

		-- PropInProp-Protection
		local te = util.TraceLine( { start = e:LocalToWorld( e:OBBMins() ), endpos = e:LocalToWorld( e:OBBMaxs() ), filter = e } )
		if IsValid( te.Entity ) and !te.Entity:IsPlayer() then
			sv_PProtect.Notify( ply, "You are not allowed to spawn a prop in an other prop!" )
			e:Remove()
		end

	end )

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
	if sv_PProtect.IsShared( ent, "phys" ) then return true end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to hold this object!" )
		return false
	end

end
hook.Add( "PhysgunPickup", "pprotect_physpickup", sv_PProtect.CanTouch )
hook.Add( "GravGunOnPickedUp", "pprotect_graphpickup", sv_PProtect.CanTouch )



----------------------------
--  TOOL PROP PROTECTION  --
----------------------------

function sv_PProtect.CanToolProtection( ply, trace, tool )

	local ent = trace.Entity

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Protection
	if tool == "creator" and !sv_PProtect.Settings.Propprotection[ "creatorprotection" ] then
		sv_PProtect.Notify( ply, "You are not allowed to use the creator tool!" )
		return false
	end

	-- Check Entity
	if !ent:IsValid() and !ent:IsWorld() then return false end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "tool" ) then return true end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or ent:IsWorld() and ent.World != true or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "toolgun" ) then
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
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "useprotection" ] then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "use" ) then return end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldbutton" ] then return end
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return end

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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "proppickup" ] then return true end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "use" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to pickup this object!" )
		return false
	end

end
hook.Add( "AllowPlayerPickup", "pprotect_proppickup", sv_PProtect.CanPickup )



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
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "property" ) then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to change the properties on this object!" )
		return false
	end

end
hook.Add( "CanProperty", "pprotect_property", sv_PProtect.CanProperty )

-- CAN DRIVE
function sv_PProtect.CanDrive( ply, ent )

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "propdriving" ] then return false end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "property" ) then
		return true
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

	local Owner = ent:CPPIGetOwner()
	local Attacker = info:GetAttacker()

	-- Check Entity
	if !ent:IsValid() or ent:IsPlayer() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "enabled" ] or !sv_PProtect.Settings.Propprotection[ "damageprotection" ] then return end

	-- Check Shared
	if sv_PProtect.IsShared( ent, "dmg" ) then return end

	-- Check Owner
	if Attacker:IsPlayer() and Owner != Attacker and !sv_PProtect.IsBuddy( Owner, Attacker, "damage" ) then

		if Attacker:IsSuperAdmin() and sv_PProtect.Settings.Propprotection[ "superadmins" ] then return end
		if Attacker:IsAdmin() and sv_PProtect.Settings.Propprotection[ "admins" ] then return end

		info:SetDamage( 0 )
		timer.Simple( 0.1, function()

			if !ent:IsValid() then return end

			if ent:IsOnFire() then ent:Extinguish() end

		end )

	elseif !Attacker:IsPlayer() then return false

	elseif Attacker:IsPlayer() and Owner == Attacker then return

	end

end
hook.Add( "EntityTakeDamage", "pprotect_damage", sv_PProtect.CanDamage )



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
	if !sv_PProtect.Settings.Propprotection[ "reloadprotection" ] then return end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return end

	-- Check Owner
	if ply == ent:CPPIGetOwner() or sv_PProtect.IsBuddy( ent:CPPIGetOwner(), ply, "physgun" ) then
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

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] then return false end

	-- Check World
	if ent.World and sv_PProtect.Settings.Propprotection[ "worldprops" ] then return true end

	-- Check Owner
	if ply == ent:CPPIGetOwner() then
		return true
	else
		sv_PProtect.Notify( ply, "You are not allowed to punt this object!" )
		return false
	end

end
hook.Add( "GravGunPunt", "pprotect_graphpunt", sv_PProtect.CanGravPunt )

function sv_PProtect.CanGravPickup( ply, ent )

	-- Check Admin
	if sv_PProtect.CheckPPAdmin( ply, ent ) then return true end

	-- Check Entity
	if !ent:IsValid() then return false end

	-- Check Protection
	if !sv_PProtect.Settings.Propprotection[ "gravgunprotection" ] then return false end

	-- Check World
	if ent.World and !sv_PProtect.Settings.Propprotection[ "worldprops" ] then
		local worldprop = true
	end

	-- Check Owner
	if ply != ent:CPPIGetOwner() or worldprop then
		sv_PProtect.Notify( ply, "You are not allowed to use the Grav-Gun on this object!" )
		ply:DropObject()
	end

end
hook.Add( "GravGunOnPickedUp", "pprotect_graphpickedup", sv_PProtect.CanGravPickup )



-----------------------
--  SET WORLD PROPS  --
-----------------------

function sv_PProtect.setWorldProps()

	table.foreach( ents:GetAll(), function( id, ent )

		if string.find( ent:GetClass(), "func_" ) or string.find( ent:GetClass(), "prop_" ) then ent.World = true end

	end )

end
hook.Add( "PersistenceLoad", "pprotect_worldprops", sv_PProtect.setWorldProps )



------------------
--  NETWORKING  --
------------------

-- SEND THE OWNER TO THE CLIENT
net.Receive( "pprotect_get_owner", function( len, pl )

	local ent = net.ReadEntity()
	local ply = ent:CPPIGetOwner()
	local info = ""

	if sv_PProtect.IsBuddy( ply, pl, "physgun" ) == true or 
	sv_PProtect.IsBuddy( ply, pl, "use" ) == true or 
	sv_PProtect.IsBuddy( ply, pl, "toolgun" ) == true then
		info = "buddy"
	end

	if ent.pprotect_cleanup != nil then info = ent.pprotect_cleanup end
	if ent.World == true then info = "world" end

	net.Start( "pprotect_send_owner" )
		net.WriteEntity( ply )
		net.WriteString( info )
	net.Send( pl )

end )

-- SEND NEW SHARED ENTITY INFORMAITON TO THE CLIENT
local shared_ent = nil
net.Receive( "pprotect_get_sharedEntity", function( len, pl )

	shared_ent = net.ReadEntity()

	net.Start( "pprotect_send_sharedEntity" )

		if istable( shared_ent.share ) then
			net.WriteTable( shared_ent.share )
		else
			net.WriteTable( {} )
		end

	net.Send( pl )

end )

-- SAVE NEW SHARED ENTITY
net.Receive( "pprotect_save_sharedEntity", function( len, pl )

	local info = net.ReadTable()
	if istable( info ) then shared_ent.share = info end

end )
