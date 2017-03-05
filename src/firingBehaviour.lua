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
-- setFireFunc
--
-- Sets the firing function - i.e. what should get called when we call "fire"?
-------------------------------------------------------------------------------
function firingBehaviour:setFireFunc(fireFunc)
	self.fire = fireFunc
end

