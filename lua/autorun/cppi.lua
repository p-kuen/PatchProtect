CPPI = CPPI or {}
CPPI.CPPI_DEFER = 042015
CPPI.CPPI_NOTIMPLEMENTED = 8084 -- PT ( Patcher and Ted )
local PLAYER = FindMetaTable( "Player" )
local ENTITY = FindMetaTable( "Entity" )

-- Get name
function CPPI:GetName()

	return "PatchProtect"

end

-- Get version of CPPI
function CPPI:GetVersion()

	return "1.3"

end

-- Get interface version of CPPI
function CPPI:GetInterfaceVersion()

	return 1.3

end

-- Get name from UID
function CPPI:GetNameFromUID( uid )

	local ply = player.GetByUniqueID( tostring( uid ) )
	if !IsValid( ply ) or !ply:IsPlayer() then return end
	return ply:Nick()

end

-- Get friends from a player
function PLAYER:CPPIGetFriends()

	return CPPI_NOTIMPLEMENTED

end

-- Get the owner of an entity
function ENTITY:CPPIGetOwner()

	local ply = self:GetNWEntity( "pprotect_owner" )
	if ply != nil and ply:IsValid() and ply:IsPlayer() then
		return ply, ply:UniqueID()
	else
		return nil, nil
	end

end

if CLIENT then return end

-- Set owner of an entity
function ENTITY:CPPISetOwner( ply )

	if !self or !ply or !ply:IsPlayer() then return false end

	self:SetNWEntity( "pprotect_owner", ply )

	table.foreach( constraint.GetAllConstrainedEntities( self ), function( _, cent )

		if cent:CPPIGetOwner() then return end
		cent:SetNWEntity( "pprotect_owner", ply )

	end )

	return true

end

-- Set owner of an entity by UID
function ENTITY:CPPISetOwnerUID( uid )

	if !uid then return false end
	local ply = player.GetByUniqueID( tostring( uid ) )

	return self:CPPISetOwner( ply )

end

-- Can physgun
function ENTITY:CPPICanPhysgun( ply )

    if sv_PProtect.CanTouch( ply, self ) == false then
        return false
    else
        return true
    end

end

-- Can tool
function ENTITY:CPPICanTool( ply, tool )

    if sv_PProtect.CanToolProtection( ply, ply:GetEyeTrace(), tool ) == false then
        return false
    else
        return true
    end

end

-- Can pickup
function ENTITY:CPPICanPickup( ply )
	
    if sv_PProtect.CanPickup( ply, self ) == false then
        return false
    else
        return true
    end

end

-- Can punt
function ENTITY:CPPICanPunt( ply )

    if sv_PProtect.CanGravPunt( ply, self ) == false then
        return false
    else
        return true
    end

end
