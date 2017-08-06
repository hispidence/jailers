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
--
-- gun_shotgun types have two modes; default and rotate. Both types fire a
-- "cone" of bullets; default-style guns fire several (bulletsPerShot) at
-- once, wheras rotate-style guns fire bullets one at a time.
--
-- Rotate guns themselves come in two styles: if "changeDir" is 1, it will
-- change its winding whenever it has fired bulletsPerShot bullets. If
-- changeDir is 0, it will rotate in the same direction, andcontinue to fire
-- its bullets in the same order.
-------------------------------------------------------------------------------
function firingBehaviourFactory:makeFiringBehaviour(data)
  
  local timeLastBullet = 0 -- time since gun last fired

  -- if rotate is 1, it's a rotate-type gun
  local rotate = data.rotate
  
  -- if rotate and changeDir are 1, it's a rotate-type gun
  -- which changes direction
  local changeDir = data.changeDir and rotate
  local changeDirReady = false

  -- the time in seconds to wait before firing the gun again
  local timeBetween = data.secondsBetween
  if 0 == timeBetween then
    timeBetween = 0.5
  end
  
  -- how many bullets to shoot in a "shot"
  local bulletsPerShot = data.bulletsPerShot
  if 0 == bulletsPerShot then
    bulletsPerShot = 3
  end
  
  -- for rotating guns; which way should the gun initially rotate?
  local winding = data.initialWinding
  if 0 == winding then
    winding = 1
  end
  
  -- how many radians in the gun's firing arc?
  local angle = math.rad(data.firingAngle)
  if 0 == angle then
    angle = 0.5
  end
  
  -- angle in radians between bullets in a shot
  local radsPerShot = angle/(bulletsPerShot-1)
  
  -- angle of first bullet, relative to the gun's original direction vector
  local startAngle = -angle/2;
  
  -- direction the gun is pointing; all firing angles are relative to this vector
  local originalDirVec = vector(data.directionX, data.directionY)
  
  -- calculate direction vectors for each bullet in advance
  local directionVectors = {}
  for i = 1, bulletsPerShot do
    directionVectors[i] = originalDirVec:rotated(startAngle + radsPerShot*(i-1))
  end
  
  -- How many bullets have we prepared?
  local bulletsPrepared = 0
  
  -- Which bullet are we firing?
  local currentBullet = 0

  -- If winding is negative, start at the last bullet
  if changeDir and -1 == winding then
      currentBullet = bulletsPerShot
  end
  
  -- Which bullet should we fire next?
  -- Winding can be 1 or -1 depending on which direction the gun is rotating.
  -- Non-rotate guns will always have a winding value of 1.
  local function incrementBullet()
    currentBullet = currentBullet + winding
  end

  -- Have we fired enough bullets to either change rotation direction or
  -- reset our angle or its initial position?
  local function isReadyToReset()
    if changeDir and -1 == winding then
      return 1 == currentBullet
    else
      return bulletsPerShot == currentBullet
    end
  end

  -- fires bullets
  local updateBullet = function(behaviour, dt)
    local ready = false
    local timeRemaining = 0
    if behaviour.state == "active" and timeLastBullet > timeBetween then
      -- If there are still bullets in the shot, prepare them
      if bulletsPerShot > bulletsPrepared then
        bulletsPrepared = bulletsPrepared + 1
        -- if this gun is in "rotate" mode, we fire a bullet one at a time,
        -- so subtract timeBetween from timeLastBullet here
        
        -- if it isn't, we wait until the rest of the bullets are
        -- prepared before modifying timeLastBullet, since we're firing
        -- several bullets at once
        if rotate or bulletsPerShot == bulletsPrepared then
            timeLastBullet = timeLastBullet - timeBetween
            timeRemaining = timeLastBullet
        end
        
        ready = true
      end
    end
    
    return ready, timeRemaining
  end
  
  -- Called once per gun per frame
  local updateGun = function(behaviour, dt, gunPos)
    self.gunPos = gunPos
    timeLastBullet = timeLastBullet + dt
    if not rotate then
      currentBullet = 0
      bulletsPrepared = 0
    end
    return angle
  end
  
  -- What should a bullet do when it collides with something?
  local collideBullet = function(behaviour, velVec, posVec)
    local killBullet = false
    if behaviour.state == "active" then
      killBullet = true
    end
    
    return killBullet
  end

  -- set initial position and velocity for the bullet
  local speed = data.speed

  local calcInitialsFunc = function(behaviour)
    local position = self.gunPos:clone()
    incrementBullet()
    local velocity = directionVectors[currentBullet]*speed
    -- update position based on how long ago the bullet was fired.
    -- For example, if timeBetween is 2 but timeLastBullet was 2.5
    -- at the time of firing, then the bullet will be fired 0.5
    -- seconds too late. We thus need to move it to where it would
    -- be if it was fired at the correct time.
    position = position + (velocity*timeLastBullet)
    if rotate and isReadyToReset() then
      bulletsPrepared = 0
      -- Change winding if it's the right time to do so
      if changeDir then
        winding = -winding
      else
        currentBullet = 0
      end
    end
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