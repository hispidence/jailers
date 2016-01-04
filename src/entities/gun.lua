-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- gun.lua
--
-- Base class for guns.
-------------------------------------------------------------------------------

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
	self.bulletVel = vector(0, 0)
	self.bullets = {}
	self.ages = {}
	self.bulletCollisionBehaviour = nil
	self.bulletLife = 0
	self.bulletTime = 1
	self.mostRecentDead = "bullet1"
	self.bulletsMade = 0
	self.bulletOffset = vector(1, 0)
	self.timeLastBullet = 0
	self.bulletTextures = {}
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

  return true
end



-------------------------------------------------------------------------------
-- firingBehaviour
--
-- Create and return a closure that gets assigned to each bullet it creates.
-------------------------------------------------------------------------------
function gun:firingBehaviour()
	
  local bulletVelocity = 1
  local firingRate = 2 -- one every 2 seconds
  local firingDirection
  local n
  
  local fb = function(timeSinceLast)
    if timeSinceLast > firingRate then
      -- fire a new bullet
    end
  end
  
  return fb
end



---------------------------------------------------------------------------------------------------
--	updateSound(dt)
--	
--
---------------------------------------------------------------------------------------------------
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
	if self.state == "active" then
    --do stuff
	end
end
