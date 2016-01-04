-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- mover.lua
--
-- Movers. The big red moving blocks of death.
-------------------------------------------------------------------------------

-- The base class
require("src/gameObject")



mover = {}
-- mover is the metatable for all movers, and so will contain the methods
mover.__index = mover



-- Constructor
setmetatable(mover,
	{ __index = gameObject,
    __call = function(cls, ...)
      return cls.new(...)
		end
	}
)



-------------------------------------------------------------------------------
-- new
--
-- Invoked by constructor. Sets "mover" as its metatable.
-------------------------------------------------------------------------------
function mover.new()
	local self = setmetatable(gameObject(), mover)
	self:init()
	return self
end

function mover:tex_iter()
	local t = self.textures
	local i = nil
	local fn = nil
	local tex = nil
	return function()
		i = next(t, i)
		if i~= nil then
			fn = t[i].fileName
			tex = t[i].texture
			return i, fn, tex
		end
		return nil
	end
end



-------------------------------------------------------------------------------
-- init
--
-- Sets default values.
-------------------------------------------------------------------------------
function mover:init()
	gameObject.init(self)
	self.size = vector(14, 14)
	self.speed = 0
	self.dir = vector(0, 0)
	self.currentExtent = 1
	self.otherExtent = 2
	self.extentsDist = 0
	self.dist = 0
	self.extents = {vector(0, 0), vector(0, 0)}
	self.oldPos = vector(0, 0)
	self.rayToTarget = {x = 0, y = 0}
end



-------------------------------------------------------------------------------
-- assignFromProperties
--
-- Populate the mover's members with properties from its Tiled object.
-------------------------------------------------------------------------------
function mover:assignFromProperties(prop)
  -- We've got many properties, some of which are needed by movers.
  self.speed = tonumber(prop.speed)
  local extents = jlSplitKV(prop.extents)
  
  if(prop.extents) then
    -- If we've got only these extents then assume the mover will move from
    -- its original position to its first extent, and then back
    self.extents[1] = self.position:clone()
    self.extents[2] = self.position:clone()
    
    self.extents[2].x = self.extents[2].x + extents.x * self.size.x
    self.extents[2].y = self.extents[2].y + extents.y * self.size.y
    
    self:calcExtent(1)
  end
  
  local initDir = jlSplitKV(prop.initialdirection)
  self.dir.x = initDir.x
  self.dir.y = initDir.y
  
  return true
end



-------------------------------------------------------------------------------
-- setDist
--
-- Set the mover's distance from its target position ("extent").
-------------------------------------------------------------------------------
function mover:setDist(d)
	self.dist = d
end



-------------------------------------------------------------------------------
-- getDist
--
-- Get the mover's distance from its target position ("extent").
-------------------------------------------------------------------------------
function mover:getDist()
	return self.dist
end



-------------------------------------------------------------------------------
-- getOldPos
--
-- Get the mover's old position (its position in the prior update frame).
-------------------------------------------------------------------------------
function mover:getOldPos()
	return self.oldPos
end


-------------------------------------------------------------------------------
-- setDir
--
-- Set the mover's current direction.
-------------------------------------------------------------------------------
function mover:setDir(dir)
	self.dir = dir
end



-------------------------------------------------------------------------------
-- getDir
--
-- Get the mover's current direction.
-------------------------------------------------------------------------------
function mover:getDir()
	return self.dir
end



-------------------------------------------------------------------------------
-- setExtent
--
-- Set one of the mover's extents.
-------------------------------------------------------------------------------
function mover:setExtent(i, vec)
	self.extents[i] = vec;
end



-------------------------------------------------------------------------------
-- getExtent
--
-- Get one of the mover's extents.
-------------------------------------------------------------------------------
function mover:getExtent(i)
	return self.extents[i];
end



-------------------------------------------------------------------------------
-- getCurrentExtent
--
-- Get the index of the mover's current extent.
-------------------------------------------------------------------------------
function mover:getCurrentExtent()
	return self.currentExtent;
end



-------------------------------------------------------------------------------
-- getOtherExtent
--
-- Get the index of the mover's non-current extent.
-------------------------------------------------------------------------------
function mover:getOtherExtent()
	return self.otherExtent;
end



-------------------------------------------------------------------------------
-- setCurrentExtent
--
-- Set the index of the mover's current extent.
-------------------------------------------------------------------------------
function mover:setCurrentExtent(e)
	self.currentExtent = e
end



-------------------------------------------------------------------------------
-- setOtherExtent
--
-- Set the index of the mover's non-current extent.
-------------------------------------------------------------------------------
function mover:setOtherExtent(e)
	self.otherExtent = e
end



-------------------------------------------------------------------------------
-- calcExtent
--
-- Calculate the proper values of the mover's extents.
-------------------------------------------------------------------------------
function mover:calcExtent(block)
	self.extentsDist = self.extents[self.currentExtent]:dist(self.extents[self.otherExtent]) * block
	self.dist = self.position:dist(self.extents[1] * block)
	self.extents[1] = self.extents[1] * block
	self.extents[2] = self.extents[2] * block
end



-------------------------------------------------------------------------------
-- move
--
-- Move the mover.
-------------------------------------------------------------------------------
function mover:move(pos)
	self.oldPos.x, self.oldPos.y = self.position.x, self.position.y
	gameObject.move(self, pos)
end



-------------------------------------------------------------------------------
-- update
--
-- Updates the mover, reversing its direction and swapping its extents if it
-- hits a said extent.
-------------------------------------------------------------------------------
function mover:update(dt) 
	self.oldPos.x, self.oldPos.y = self.position.x, self.position.y
	self.position.x = self.position.x + (self.dir.x * dt * self.speed)
	self.position.y = self.position.y + (self.dir.y * dt * self.speed)
	self.dist = self.dist + self.oldPos:dist(self.position)
	if self.dist >= self.extentsDist then
		if self.sounds["stomp"] then
			--TEsound.play(self.sounds["stomp"].data)
		end
  
		self.dir.x, self.dir.y = -self.dir.x, -self.dir.y
		local tempVar = self.dist - self.extentsDist
		self.position.x = self.extents[self.otherExtent].x + (self.dir.x * tempVar)
		self.position.y = self.extents[self.otherExtent].y + (self.dir.y * tempVar)
		self.dist = tempVar 
		local temp = self.currentExtent
		self.currentExtent = self.otherExtent
		self.otherExtent = temp
	end
	gameObject.setPos(self, self.position)
end

