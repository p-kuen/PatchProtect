-- http://ulyssesmod.net/archive/CPPI_v1-3.pdf

CPPI = CPPI or {}

CPPI.CPPI_DEFER = 8080 -- PP (PathProtect)
CPPI.CPPI_NOTIMPLEMENTED = 012019 -- month/year of newest version

local PLAYER = FindMetaTable('Player')
local ENTITY = FindMetaTable('Entity')

-- Get name of prop protection
function CPPI:GetName()
  return 'PatchProtect'
end

-- Get version of prop protection
function CPPI:GetVersion()
  return '1.4.0'
end

-- Get interface version of CPPI
function CPPI:GetInterfaceVersion()
  return 1.3
end

-- Get name of player from UID
function CPPI:GetNameFromUID(uid)
  local ply = player.GetByUniqueID(uid)
  if !ply then return end
  return ply:Nick()
end

-- Get friends from a player
function PLAYER:CPPIGetFriends()
  if CLIENT then return CPPI.CPPI_NOTIMPLEMENTED end -- TODO add this for client side (maybe only for local player)
  return self.Buddies
end

-- Get the owner of an entity
function ENTITY:CPPIGetOwner()
  local ply = self:GetNWEntity('pprotect_owner')
  if ply == nil or !ply:IsPlayer() then return nil, nil end
  return ply, ply:UniqueID()
end

if CLIENT then return end

-- Set owner of an entity
function ENTITY:CPPISetOwner(ply)
  if ply == nil or !ply:IsPlayer() then return false end

  if hook.Run('CPPIAssignOwnership', ply, self, ply:UniqueID()) == false then return false end

  self:SetNWEntity('pprotect_owner', ply)

  table.foreach(constraint.GetAllConstrainedEntities(self), function(_, cent)
    if cent:CPPIGetOwner() then return end
    cent:SetNWEntity('pprotect_owner', ply)
  end)

  return true
end

-- Set owner of an entity by UID
function ENTITY:CPPISetOwnerUID(uid)
  return self:CPPISetOwner(player.GetByUniqueID(uid) or nil)
end

-- Can tool
function ENTITY:CPPICanTool(ply, tool)
  return sv_PProtect.CanTool(ply, self, tool)
end

-- Can physgun
function ENTITY:CPPICanPhysgun(ply)
  return sv_PProtect.CanPhysgun(ply, self)
end

-- Can pickup
function ENTITY:CPPICanPickup(ply)
  return sv_PProtect.CanPickup(ply, self)
end

-- Can punt
function ENTITY:CPPICanPunt(ply)
  return sv_PProtect.CanGravPunt(ply, self)
end

-- Can use
function ENTITY:CPPICanUse(ply)
  return sv_PProtect.CanUse(ply, self)
end

-- Can damage
function ENTITY:CPPICanDamage(ply)
  return sv_PProtect.CanDamage(ply, self)
end

-- Can drive
function ENTITY:CPPICanDrive(ply)
  return sv_PProtect.CanDrive(ply, self)
end

-- Can property
function ENTITY:CPPICanProperty(ply, property)
  return sv_PProtect.CanProperty(ply, property, self)
end

-- Can edit variable
function ENTITY:CPPICanEditVariable(ply, key, val, edit)
  return CPPI.CPPI_NOTIMPLEMENTED -- TODO
end
