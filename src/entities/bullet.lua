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
	--if "active" == self.state then
    self.firingBehaviour()
	--end
end
