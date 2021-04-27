-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- gun.lua
--
-- Base class for guns.
-------------------------------------------------------------------------------


local vector = require("src.external.hump.vector")
local jlutil = require("src.utils")

local bullet = require("src.entities.bullet")

-- OO stuff
local gameObject = require("src.entities.gameObject")

local gun = {}
gun.__index = gun

setmetatable(gun,
	{__index = gameObject,
	__call = function(cls, ...)
		return cls.new(...)
		end
	})



-------------------------------------------------------------------------------
-- new
--
--
-------------------------------------------------------------------------------
function gun.new()
	local self = setmetatable(gameObject(), gun)
	self:init()
	return self
end



-------------------------------------------------------------------------------
-- init
--
--
-------------------------------------------------------------------------------
function gun:init()
	gameObject.init(self)
	self.firingBehaviourBullet = nil
	self.firingBehaviourGun = nil
	self.bulletCollisionBehaviour = nil
	self.bulletsMade = 0
  self.bullets = nil
	self.bulletOffset = vector(1, 0)
	self.bulletTextureSet = {}
  self.firingBehaviour = nil
end



-------------------------------------------------------------------------------
-- assignFromProperties
--
-- Populate the gun's members with properties from its Tiled object.
-------------------------------------------------------------------------------
function gun:assignFromProperties(prop)
  -- We've got many properties, some of which are needed by guns and bullets.

  local dirVec = vector(prop.directionX, prop.directionY)

  local stdVec = vector(0, -1)

  self.angle = stdVec:angleTo(dirVec)

  if(prop.behaviourScript) then
    local scriptFile = "src/levels/scripts/" .. prop.behaviourScript
    local firingBehaviourFactory = require(scriptFile)

    self.firingBehaviour = firingBehaviourFactory:makeFiringBehaviour(prop)

    self.numBullets = prop.numBullets
    if 0 == self.numBullets then
      self.numBullets = 10
    end

    jlutil.unrequire(scriptFile)
  end

  self:setState("active")

  self.bulletTextureSet = prop.textureset_bullet

  self.bulletOffset.x = prop.bulletOffsetX
  self.bulletOffset.y = prop.bulletOffsetY

  self.bullets = {}
  for i = 1, self.numBullets do
    self.bullets[i] = self:createBullet()
  end

  return true
end



-------------------------------------------------------------------------------
-- createBullet
--
--
-------------------------------------------------------------------------------
function gun:createBullet()
  local b = bullet()
  b:setSize(vector(8, 8))
  b:setState("dormant")
  b:setInvisible(true)
  b:setPos(self.position:clone() + self.bulletOffset)

  b:setID(self:getID() .. "_bullet" .. self.bulletsMade)
  b:setCategory("bullet")
  b:setGunID(self:getID())

  self.bulletsMade = self.bulletsMade + 1

  b:assignTextureSet(self.bulletTextureSet)

	b:setQuad(love.graphics.newQuad(0,
													0,
													b:getSize().x,
													b:getSize().y,
													b:getSize().x,
													b:getSize().y))

  -- Hopefully, lua will give each bullet the SAME closure
  b:setFiringBehaviour(self.firingBehaviour)
  return b
end



---------------------------------------------------------------------------------------------------
--	gun:update(dt)
--
--
---------------------------------------------------------------------------------------------------
function gun:update(dt)
	if "active" == self.state then
    self.firingBehaviour:updateGun(dt, self.position)
    for _, v in ipairs(self.bullets) do
      v:update(dt)
    end
  end
end



---------------------------------------------------------------------------------------------------
--  gun:draw(dt)
--
--
---------------------------------------------------------------------------------------------------
function gun:draw()
  gameObject.draw(self)
  if "active" == self.state then
    for _, v in ipairs(self.bullets) do
      v:draw()
    end
  end
end

return gun
