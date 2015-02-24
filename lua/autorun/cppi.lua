CPPI = CPPI or {}
CPPI.CPPI_DEFER = 022015 -- January 2015
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

	return 1.1

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

	if SERVER then
		local ply = self.pprotect_owner
		if !IsValid( ply ) or !ply:IsPlayer() then return nil, self.pprotect_owner_id end
		return ply, ply:UniqueID()
	else
		return CPPI_NOTIMPLEMENTED
	end

end

if SERVER then

	-- Set owner of an entity
	function ENTITY:CPPISetOwner( ply )
		
		if !self or !IsValid( ply ) or !ply:IsPlayer() then return false end

		self.pprotect_owner, self.pprotect_owner_id = ply, ply:UniqueID()

		table.foreach( constraint.GetAllConstrainedEntities( self ), function( _, cent )

			if IsEntity( cent.pprotect_owner ) and cent.pprotect_owner:IsValid() then return end
			cent.pprotect_owner, cent.pprotect_owner_id = ply, ply:UniqueID()

		end )

		return true

	end

	-- Set owner of an entity by UID
	function ENTITY:CPPISetOwnerUID( uid )

		local ply = player.GetByUniqueID( tostring( uid ) )
		if !IsValid( ply ) or !ply:IsPlayer() then return false end

		if !self.pprotect_owner then

			self.pprotect_owner, self.pprotect_owner_id = ply, ply:UniqueID()

		end

		return true

	end

	-- Can physgun
	function ENTITY:CPPICanPhysgun( ply )

		return sv_PProtect.CanTouch( ply, self )

	end

	-- Can tool
	function ENTITY:CPPICanTool( ply, tool )

		return sv_PProtect.CanToolProtection( ply, ply:GetEyeTrace(), tool )

	end

	-- Can pickup
	function ENTITY:CPPICanPickup( ply )

		return sv_PProtect.CanPickup( ply, self )

	end

	-- Can punt
	function ENTITY:CPPICanPunt( ply )

		return sv_PProtect.CanGravPunt( ply, self )

	end

end
