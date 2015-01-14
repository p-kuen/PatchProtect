CPPI = CPPI or {}
CPPI.CPPI_DEFER = 012015 -- January 2015
CPPI.CPPI_NOTIMPLEMENTED = 8084 -- PT ( Patcher and Ted )
local PLAYER = FindMetaTable( "Player" )
local ENTITY = FindMetaTable( "Entity" )

-- NAME
function CPPI:GetName()

	return "PatchProtect"

end

-- VERSION
function CPPI:GetVersion()

	return "1.2.1"

end

-- FACE VERSION
function CPPI:GetInterfaceVersion()

	return 1.1

end

-- UID NAME
function CPPI:GetNameFromUID( uid )

	return CPPI.CPPI_NOTIMPLEMENTED

end

function PLAYER:CPPIGetFriends()

	return CPPI.CPPI_DEFER

end

function ENTITY:CPPIGetOwner()

	local Owner = self.pprotect_owner

	if !IsValid( Owner ) or !Owner:IsPlayer() then return Owner, self.pprotect_owner_id end
	return Owner, Owner:UniqueID()

end

-- SERVERSIDED THINGS
if SERVER then

	-- SET OWNER
	function ENTITY:CPPISetOwner( ply )
		
		if !self then return false end

		self.pprotect_owner = ply
		self.pprotect_owner_id = ply:SteamID()

		table.foreach( constraint.GetAllConstrainedEntities( self ), function( _, cent )

			if IsEntity( cent.pprotect_owner ) and cent.pprotect_owner:IsValid() then return end

			cent.pprotect_owner = ply
			cent.pprotect_owner_id = ply:SteamID()

		end )

		return true

	end

	-- SET OWNER UNIQUE ID
	function ENTITY:CPPISetOwnerUID( UID )

		local ply = player.GetByUniqueID( tostring( UID ) )
		if !ply:IsValid() then return false end

		if self.pprotect_owner then

			if self.AllowedPlayers then
				table.insert( self.AllowedPlayers, ply )
			else
				self.AllowedPlayers = { ply }
			end

			return true

		else

			self.pprotect_owner = ply
			self.pprotect_owner_id = ply:SteamID()

			return true

		end

	end

	-- CAN TOOL
	function ENTITY:CPPICanTool( ply, tool )

		return sv_PProtect.CanToolProtection( ply, ply:GetEyeTrace(), tool )

	end

	-- CAN PHYSGUN
	function ENTITY:CPPICanPhysgun( ply )

		return sv_PProtect.CanTouch( ply, self )

	end

	-- CAN PICKUP
	function ENTITY:CPPICanPickup( ply )

		return sv_PProtect.CanPickup( ply, self )

	end

	-- CAN PUNT
	function ENTITY:CPPICanPunt( ply )

		return sv_PProtect.CanGravPunt( ply, self )

	end

end
