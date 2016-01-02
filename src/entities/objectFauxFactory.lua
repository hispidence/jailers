-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- objectFauxFactory.lua
--
-- Which tiled object types map to which objects?
-------------------------------------------------------------------------------

require("src/gameObject")
require("src/entities/mover")



-------------------------------------------------------------------------------
-- types
--
-- Chooses which type of object should be constructed based on the argument
-- given to buildByType.
-------------------------------------------------------------------------------
local types = {
  typeless  = gameObject,
  switch    = gameObject,
  door      = gameObject,
  enemy     = gameObject,
  mover     = mover
}



-------------------------------------------------------------------------------
-- buildByType
--
-- Invokes constructor and returns object.
-------------------------------------------------------------------------------
function buildByType(theType)
  local constructor = types[theType];
  if not constructor then
    print("no constructor for " .. theType)
    return nil
  else
    return constructor();
  end
end