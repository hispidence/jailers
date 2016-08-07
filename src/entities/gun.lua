-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- gun.lua
--
-- Base class for guns.
-------------------------------------------------------------------------------

require("src/entities/bullet")

-- OO stuff
require("src/gameObject")

gun = {}
gun.__index = gun

setmetatable(gun,
	{__index = gameObject,
	__call = function(cls, ...) 
		return cls.new(...)	
		end
	})

function gun:new()
	local self = setmetatable(gameObject(), gun)
	self:init()
	return self
end



-------------------------------------------------------------------------------
-- init
--
-- Sets default values.
-------------------------------------------------------------------------------
function gun:init()
	gameObject.init(self)
	self.firingBehaviour = nil
	self.bulletVel = vector(-1, 0)
	self.bullets = {}
	self.ages = {}
	self.bulletCollisionBehaviour = nil
	self.bulletLife = 0
	self.bulletTime = 1
	self.mostRecentDead = "bullet1"
	self.bulletsMade = 0
	self.bulletOffset = vector(1, 0)
	self.timeLastBullet = 0
	self.bulletTextureSet = {}
  self:makeFiringBehaviour()
end



-------------------------------------------------------------------------------
-- assignFromProperties
--
-- Populate the gun's members with properties from its Tiled object.
-------------------------------------------------------------------------------
function gun:assignFromProperties(prop)
  -- We've got many properties, some of which are needed by movers.

  local dir = jlSplitKV(prop.direction)

  local dirVec = vector(tonumber(dir.x), tonumber(dir.y))

  local stdVec = vector(0, -1)

  self.angle = stdVec:angleTo(dirVec)

  self:makeFiringBehaviour()
  
  self:setState("active")
  
  self.bulletTextureSet = prop.textureset_bullet

  return true
end



-------------------------------------------------------------------------------
-- makeFiringBehaviour
--
-- Create and assign a closure that gets assigned to each bullet it creates.
-------------------------------------------------------------------------------
function gun:makeFiringBehaviour()
  local timeBetween = 2 -- one every 2 seconds
  local n
  
  local fb = function(dt)
    if self:getState() == "active" and self.timeLastBullet > timeBetween then
      
      -- fire a new bullet
      print("Firing bullet!", self.timeLastBullet, timeBetween)
      self.timeLastBullet = self.timeLastBullet - timeBetween
      
    end
    self.timeLastBullet = self.timeLastBullet + dt
  end
  
  self.firingBehaviour = fb
end



-------------------------------------------------------------------------------
-- createBullet
--
-- Create and return a bullet.
-------------------------------------------------------------------------------
function gun:createBullet()
  local b = bullet()
  b:setSize(vector(8, 8))
  b:setCollisionRectangle()
  b:setState("active")
  b:setInvisible(false)
  b:setPos(self.position:clone())
  b:setVel(self.bulletVel)
  
  b:setID(self:getID() .. "_bullet")
  b:setCategory("bullet")
  
  b:assignTextureSet(self.bulletTextureSet)
  
  local size = vector(g_blockSize, g_blockSize)
	b:setQuad(love.graphics.newQuad(0,
													0,
													b:getSize().x,
													b:getSize().y, 
													b:getSize().x,
													b:getSize().y))
	b:setCollisionRectangle()
  
  -- Hopefully, lua will give each bullet the SAME closure
  b:setFiringBehaviour(self.firingBehaviour)
  return b
end


-------------------------------------------------------------------------------
-- createSubObjects
--
-- Some objects, when initialised, can create sub objects (eg guns making
-- bullets). These objects exist should separately from their parent.
-------------------------------------------------------------------------------
function gun:createSubObjects()
  local bullets = {}
  for i = 1, 5 do
    bullets[i] = self:createBullet()
  end
  return bullets
end



-------------------------------------------------------------------------------
--	updateSound(dt)
--	
--
-------------------------------------------------------------------------------
function gun:updateSound(dt)
	--if self.firingBehaviour ~= nil then if self.firingBehaviour:isSoundReady(dt) then gameObject.playSound(self) end
	--else
	--	gameObject.updateSound(self, dt)
	--end
end



---------------------------------------------------------------------------------------------------
--	gun:update(number dt)
--	
--
---------------------------------------------------------------------------------------------------
function gun:update(dt)
	if "active" == self.state then

	end
end


