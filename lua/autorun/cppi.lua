CPPI = CPPI or {}
CPPI.CPPI_DEFER = 072014 -- July 2014
CPPI.CPPI_NOTIMPLEMENTED = 8084 -- PT ( Patcher and Ted )
pprotect_cppi_call = false
pprotect_cppi_right = false

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

-- PLAYER ( METATABLE )
local PLAYER = FindMetaTable( "Player" )

function PLAYER:CPPIGetFriends()

	return CPPI.CPPI_DEFER

end

-- ENTITY ( METATABLE )
local ENTITY = FindMetaTable( "Entity" )

function ENTITY:CPPIGetOwner()

	local Owner = self.PatchPPOwner

	if not IsValid( Owner ) or not Owner:IsPlayer() then return Owner, self.PatchPPOwnerID end
	return Owner, Owner:UniqueID()

end

-- SERVERSIDED THINGS
if SERVER then

	-- SET OWNER
	function ENTITY:CPPISetOwner( ply )
		
		if self == nil then return end

		self.PatchPPOwner = ply
		self.PatchPPOwnerID = ply:SteamID()
		
		if constraint.HasConstraints( self ) then
			
			local ConstrainedEntities = constraint.GetAllConstrainedEntities( self )

			table.foreach( ConstrainedEntities, function( _, cent )

				if IsEntity( cent.PatchPPOwner ) and cent.PatchPPOwner:IsValid() then return end

				cent.PatchPPOwner = ply
				cent.PatchPPOwnerID = ply:SteamID()

			end )

		end

		return true

	end

	-- SET OWNER UNIQUE ID
	function ENTITY:CPPISetOwnerUID( UID )

		local ply = player.GetByUniqueID( tostring( UID ) )

		if self.PatchPPOwner and ply:IsValid() then

			if self.AllowedPlayers then
				table.insert( self.AllowedPlayers, ply )
			else
				self.AllowedPlayers = { ply }
			end

			return true

		elseif ply:IsValid() then

			self.PatchPPOwner = ply
			self.PatchPPOwnerID = ply:SteamID()

			return true

		end

		return false

	end

	-- CAN TOOL
	function ENTITY:CPPICanTool( ply, tool )

		pprotect_cppi_call = true
		pprotect_cppi_right = sv_PProtect.CanToolProtection( ply, ply:GetEyeTrace(), tool )
		pprotect_cppi_call = false
		return pprotect_cppi_right

	end

	-- CAN PHYSGUN
	function ENTITY:CPPICanPhysgun( ply )

		pprotect_cppi_call = true
		pprotect_cppi_right = sv_PProtect.CanTouch( ply, self )
		pprotect_cppi_call = false
		return pprotect_cppi_right

	end

	-- CAN PICKUP
	function ENTITY:CPPICanPickup( ply )

		pprotect_cppi_call = true
		pprotect_cppi_right = sv_PProtect.CanPickup( ply, self )
		pprotect_cppi_call = false
		return pprotect_cppi_right

	end

	-- CAN PUNT
	function ENTITY:CPPICanPunt( ply )

		pprotect_cppi_call = true
		pprotect_cppi_right = sv_PProtect.CanGravPunt( ply, self )
		pprotect_cppi_call = false
		return pprotect_cppi_right

	end

end
