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
-- init
--
-- Sets default values.
-------------------------------------------------------------------------------
function bullet:init()
	gameObject.init(self)
	gameObject.init(self)
end