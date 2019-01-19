-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2019
--
--
-- objectFauxFactory.lua
--
-- Which tiled object types map to which objects?
-------------------------------------------------------------------------------

local gameObject = require("src/entities/gameObject")
local mover      = require("src/entities/mover")
local gun        = require("src/entities/gun")
local character  = require("src/entities/character")



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
  camera    = gameObject,
  scenery   = gameObject, --stuff that won't move
  trigger   = gameObject,
  mover     = mover,
  gun       = gun,
  character = character
}



-------------------------------------------------------------------------------
-- buildByType
--
-- Invokes constructor and returns object.
-------------------------------------------------------------------------------
function buildByType(theType)
  local constructor = types[theType];
  if not constructor then
    print("Warning! No constructor for " .. theType)
    return nil
  else
    return constructor();
  end
end