-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- bullet.lua
--
-- Base class for bullets.
-------------------------------------------------------------------------------

-- OO stuff
require("src/gameObject")

bullet = {}
bullet.__index = bullet

setmetatable(bullet,
	{__index = gameObject,
	__call = function(cls, ...) 
		return cls.new(...)	
		end
	})

function bullet:new()
	local self = setmetatable(gameObject(), bullet)
	self:init()
	return self
end



-------------------------------------------------------------------------------
-- setFiringBehaviour
--
-- Sets firing behaviour.
-------------------------------------------------------------------------------
function bullet:setFiringBehaviour(fb)
	self.firingBehaviour = fb
end



---------------------------------------------------------------------------------------------------
--	update
--	
--
---------------------------------------------------------------------------------------------------
function bullet:update(dt)
	if "dormant" == self.state then
    local ready = self.firingBehaviour:updateBullet(dt)
    
    if(ready) then
      self.pos, self.vel = self.firingBehaviour:calcInitials(dt, vector(0,0), vector(0,0))
      self.state = "active"
      self.invisible = false
    end
  end
  if "active" == self.state then
    
    local vec = {}
    vec.x = self.vel.x * dt
    vec.y = self.vel.y * dt
    
    self:move(vec)
	end
end
