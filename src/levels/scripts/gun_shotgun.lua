-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2017
--
--
-- gun_shotgun.lua
--
-- Script for shotgun-type gun turret.
-------------------------------------------------------------------------------

require("src/firingBehaviour")

local firingBehaviourFactory = {}



-------------------------------------------------------------------------------
-- makeFiringBehaviour
--
-- Creates the firing behaviour object and gives it its functions. "data"
-- holds the gun's properties from the level file.
-------------------------------------------------------------------------------
function firingBehaviourFactory:makeFiringBehaviour(data)
  
  -- Make a generic gun
  local timeBetween = 2 -- one every 2 seconds
  local timeLastBullet = 0 -- time since gun last fired
  
  -- fires bullets - or will, eventually
  local fireFunc = function(behaviour, dt)
    if behaviour.state == "active" and timeLastBullet > timeBetween then
      -- fire a new bullet
      timeLastBullet = timeLastBullet - timeBetween
    end
    timeLastBullet = timeLastBullet + dt
  end
  
  -- create the object and pass it its closures/information
  local fbObject = firingBehaviour:new()
  
  fbObject:setFireFunc(fireFunc)
  fbObject:setState("active")
  
  return fbObject;
end



-- return the module
return firingBehaviourFactory