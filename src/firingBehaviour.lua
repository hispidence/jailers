-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2017
--
--
-- firingBehaviour.lua
--
-- Object to contain gun behaviour.
-------------------------------------------------------------------------------

firingBehaviour = {}

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
  self.playerPos = vector(0.0, 0.0)
  self.gunPos = vector(0.0, 0.0)
  self.updateBullet = nil
  self.updateGun = nil
end



-------------------------------------------------------------------------------
-- setPositions
--
-- Set the positions of the player and the gun, since these may change.
-------------------------------------------------------------------------------
function firingBehaviour:setPositions()
  self.playerPos = vector(0.0, 0.0)
  self.gunPos = vector(0.0, 0.0)
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
