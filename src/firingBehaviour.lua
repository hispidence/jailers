-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- firingBehaviour.lua
--
-- Object to contain gun behaviour.
-------------------------------------------------------------------------------

local vector = require("src.external.hump.vector")

local firingBehaviour = {}

firingBehaviour.__index = firingBehaviour

setmetatable(firingBehaviour,
		{__call = function(cls, ...)
      return cls.new(...)
		end})



function firingBehaviour:new(...)
  local self = setmetatable({}, firingBehaviour)
	self:init(...)
	return self
end



-------------------------------------------------------------------------------
-- init
--
-- Sets default values.
-------------------------------------------------------------------------------
function firingBehaviour:init()
  self.gunPos = vector(0.0, 0.0)
  self.updateBullet = nil
  self.updateGun = nil
  self.bulletCollide = nil
end



-------------------------------------------------------------------------------
-- setGunPositionfunc
--
-- Set the positions of the player and the gun, since these may change.
-------------------------------------------------------------------------------
function firingBehaviour:setGunPosition(gunPos)
  self.gunPos = gunPos
end



-------------------------------------------------------------------------------
-- fire
--
-- Fires bullets (or rather, tells bullets to fire themselves).
-------------------------------------------------------------------------------
function firingBehaviour:fire(dt)
	print("No fire behaviour set")
end



-------------------------------------------------------------------------------
-- setState
--
-- Sets the state - i.e. should the bullets fire or not?
-------------------------------------------------------------------------------
function firingBehaviour:setState(state)
  self.state = state
end



-------------------------------------------------------------------------------
-- setUpdateBulletFunc
--
-- Sets the function for updating bullets
-------------------------------------------------------------------------------
function firingBehaviour:setUpdateBulletFunc(updateBulletFunc)
	self.updateBullet = updateBulletFunc
end



-------------------------------------------------------------------------------
-- setBulletCollideFunc
--
-- Sets the function for what happens when a bullet hits a solid object
-------------------------------------------------------------------------------
function firingBehaviour:setBulletCollideFunc(bulletCollideFunc)
	self.bulletCollide = bulletCollideFunc
end



-------------------------------------------------------------------------------
-- setUpdateGunFunc
--
-- Sets the function for updating the gun
-------------------------------------------------------------------------------
function firingBehaviour:setUpdateGunFunc(setUpdateGunFunc)
	self.updateGun = setUpdateGunFunc
end



-------------------------------------------------------------------------------
-- setCalcInitialsFunc
--
-- Sets the function which determines the velocity and starting position of a
-- bullet when it has been fired.
-------------------------------------------------------------------------------
function firingBehaviour:setCalcInitialsFunc(calcInitialsFunc)
	self.calcInitials = calcInitialsFunc
end

return firingBehaviour
