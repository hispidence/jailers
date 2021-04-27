-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- objectFauxFactory.lua
--
-- Which tiled object types map to which objects?
-------------------------------------------------------------------------------

local gameObject = require("src.entities.gameObject")
local mover      = require("src.entities.mover")
local gun        = require("src.entities.gun")
local character  = require("src.entities.character")



-------------------------------------------------------------------------------
-- types
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
-- createObject
-------------------------------------------------------------------------------
local function createObject(theType)
  local constructor = types[theType];
  if not constructor then
    print("Warning! No constructor for " .. theType)
    return nil
  else
    return constructor();
  end
end

return createObject
