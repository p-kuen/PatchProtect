-- GET OWNER
function sh_PProtect.GetOwner(ent)
  if !ent then return end
  return ent:GetNWEntity('pprotect_owner')
end

-- CHECK SHARED
-- ent: valid entity to check for shared state
-- mode: string value for the mode to check for
function sh_PProtect.IsShared(ent, mode)
  return ent:GetNWBool('pprotect_shared_' .. mode)
end
