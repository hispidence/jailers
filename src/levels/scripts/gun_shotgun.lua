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

  local updateGun = function(behaviour, dt)
    timeLastBullet = timeLastBullet + dt
  end

  -- fires bullets - or will, eventually
  local updateBullet = function(behaviour, dt)
    local ready = false
    if behaviour.state == "active" and timeLastBullet > timeBetween then
      -- fire a new bullet
      timeLastBullet = timeLastBullet - timeBetween
      ready = true
    end
    
    return ready
  end
  
  local defaultVelocity = vector(15.0, 15.0)
  
  -- set initial position and velocity for the bullet
  local calcInitialsFunc = function(behaviour, dt, gunPos, playerPos)
    local velocity = defaultVelocity:clone()
    local position = gunPos:clone()
    
    return position, velocity
  end
  
  -- create the object and pass it its closures/information
  local fbObject = firingBehaviour:new()
  
  fbObject:setUpdateBulletFunc(updateBullet)
  fbObject:setUpdateGunFunc(updateGun)
  fbObject:setCalcInitialsFunc(calcInitialsFunc)
  fbObject:setState("active")
  
  return fbObject;
end



-- return the module
return firingBehaviourFactory