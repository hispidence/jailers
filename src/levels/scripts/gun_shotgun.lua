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
  local timeLastBullet = 0 -- time since gun last fired

  local timeBetween = data.secondsBetween
  if 0 == timeBetween then
    timeBetween = 0.5
  end
  
  local bulletsPerShot = data.bulletsPerShot
  if 0 == bulletsPerShot then
    bulletsPerShot = 3
  end
  
  local angle = data.firingAngle
  if 0 == angle then
    angle = 0.5
  end
  angle = math.rad(angle)
  local radsPerShot = angle/(bulletsPerShot-1)
  
  local directionVectors = {}
  
  local startAngle = -angle/2;
  
  local originalDirVec = vector(data.directionX, data.directionY)
  
  for i = 1, bulletsPerShot do
    directionVectors[i] = originalDirVec:rotated(startAngle + radsPerShot*(i-1))
  end
  
  local bulletsAddedToShot = 0
  local bulletsFired = 0
  
  local updateGun = function(behaviour, dt, gunPos)
    self.gunPos = gunPos
    timeLastBullet = timeLastBullet + dt
    bulletsAddedToShot = 0
    bulletsFired = 0
  end

  -- fires bullets - or will, eventually
  local updateBullet = function(behaviour, dt)
    local ready = false
    if behaviour.state == "active" and timeLastBullet > timeBetween then
      -- fire a new bullet. max 5 per shot
      if bulletsPerShot > bulletsAddedToShot then
        bulletsAddedToShot = bulletsAddedToShot + 1
        if bulletsPerShot == bulletsAddedToShot then
            timeLastBullet = timeLastBullet - timeBetween
        end
        ready = true
      end
    end
    
    return ready
  end
  
  local collideBullet = function(behaviour, velVec, posVec)
    local killBullet = false
    if behaviour.state == "active" then
      killBullet = true
    end
    
    return killBullet
  end

  local speed = data.speed
  -- set initial position and velocity for the bullet
  local calcInitialsFunc = function(behaviour)
    local position = self.gunPos:clone()
    bulletsFired = bulletsFired+1
    local velocity = directionVectors[bulletsFired]*speed
    return position, velocity
  end
  
  -- create the object and pass it its closures/information
  local fbObject = firingBehaviour:new()
  
  fbObject:setUpdateBulletFunc(updateBullet)
  fbObject:setUpdateGunFunc(updateGun)
  fbObject:setBulletCollideFunc(collideBullet)
  fbObject:setCalcInitialsFunc(calcInitialsFunc)
  fbObject:setState("active")
  
  return fbObject;
end



-- return the module
return firingBehaviourFactory