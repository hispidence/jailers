-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- Categories.lua
--
-- Which tiled object categories map to which objects?
-------------------------------------------------------------------------------

require("src/gameObject")
require("src/entities/mover")



-------------------------------------------------------------------------------
-- g_categories
--
-- Chooses which type of object should be constructed based on the argument
-- given to buildByCategory.
-------------------------------------------------------------------------------
local g_categories = {
  typeless  = gameObject,
  switch    = gameObject,
  door      = gameObject,
  enemy     = gameObject,
  mover     = mover
}

-------------------------------------------------------------------------------
-- buildByCategory
--
-- Invokes constructor and returns object.
-------------------------------------------------------------------------------
function buildByCategory(category)
  local constructor = g_categories[category];
  if not constructor then
    return nil
  else
    return constructor();
  end
end