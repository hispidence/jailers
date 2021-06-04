-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- bullet.lua
--
-- Base class for bullets.
-------------------------------------------------------------------------------

-- get the base class
local gameObject = require("src.entities.gameObject")

local bullet = {}
bullet.__index = bullet

setmetatable(bullet,
  {__index = gameObject,
  __call = function(cls, ...)
    return cls.new(...)
    end
  })



-------------------------------------------------------------------------------
-- new
-------------------------------------------------------------------------------
function bullet.new()
  local self = setmetatable(gameObject(), bullet)
  self:init()
  return self
end



-------------------------------------------------------------------------------
-- init
-------------------------------------------------------------------------------
function bullet:init()
  gameObject.init(self)
  self:reset()
  self.gunID = nil
  self.firingBehaviour = nil
end



-------------------------------------------------------------------------------
-- setGunID
-------------------------------------------------------------------------------
function bullet:setGunID(id)
  self.gunID = id
end



-------------------------------------------------------------------------------
-- reset
-------------------------------------------------------------------------------
function bullet:reset()
  self.state = "dormant"
  self.invisible = true
  self.canCollide = false

  if self.collisionShape then
    theCollider:remove(self.collisionShape)
  end

  -- Bullets need to stop when they collide with a solid object.
  -- However, the gun that fires them is a solid object itself, so these two
  -- bools are used to determine whether the bullet is currently colliding
  -- with its own gun (wasColliding), and whether it is ready to have its
  -- collision resolution switched on (readyToCollide)
  self.wasColliding = true
  self.readyToCollide = false
end



-------------------------------------------------------------------------------
-- processEvent
-------------------------------------------------------------------------------
function bullet:processEvent(e)
  gameObject.processEvent(self, e)
  if e:getID() == "collision" then
    if e:getSender() == self.gunID and not self.readyToCollide then
      self.wasColliding = true
    elseif e:getDesc() ~= "active_bullet" then
      -- optionally kill the bullet (and do collision behaviour)
      local killBullet = self.firingBehaviour:bulletCollide(self.vel, self.pos)
      if killBullet then
        self:reset()
      end
    end
  end
end



-------------------------------------------------------------------------------
--  setFiringBehaviour
-------------------------------------------------------------------------------
function bullet:setFiringBehaviour(fb)
  self.firingBehaviour = fb
end



-------------------------------------------------------------------------------
--  update
-------------------------------------------------------------------------------
function bullet:update(dt)
  if "active" == self.state then
    if(not self.wasColliding) then
      self.readyToCollide = true
    else
      self.wasColliding = false
    end
    local vec = {}
    vec.x = self.vel.x * dt
    vec.y = self.vel.y * dt

    self:move(vec)
  end
  if "dormant" == self.state then
    local ready = self.firingBehaviour:updateBullet(dt)
    if(ready) then
      self.position, self.vel = self.firingBehaviour:calcInitials()
      self.state = "active"
      self:setCollisionCircle()
      self.canCollide = true
      self:setPos(self.position)

      self.invisible = false
    end
  end
end



return bullet
