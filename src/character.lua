-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2015
--
--
-- character.lua
--
-- Game objects which can move (player and enemies)
-------------------------------------------------------------------------------

require("src/gameObject")

-- OO inheritance, after a fashion: fill character with gameObject's functions
character = {}
for k,v in pairs(gameObject) do
	character[k]=v
end

-- character objects have character as their metatable. When looking for
-- something in a character object, look first in character.
character.__index = character

-- Set the metatable of character to gameObject. This means if we can't find
-- a function called on a character object's metatable, we look instead at its
-- metatable's metatable.
--
-- Give character a C++-style constructor.
setmetatable(character,
	{__index = gameObject,
	__call = function(cls, ...)
		return cls.new(...)
		end
	})

function character.new(...)
	local self = setmetatable({}, character)
	self:init(...)
	return self
end

function character:tex_iter()
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

function character:init(objType)
	gameObject.init(self)
	self:setClass(objType)
	self.size = vector(14, 14)
	self.speed = 0
	self.oldPos = vector(0,0)
	self.moveVec = vector(0,0)
	self.path = {}
	self.numPathNodes = {}
	self.currentPoint = 0
	self.pathTimer = 0
	self.pathTarget = {r = 0, c = 0}
	self.target = vector(0,0)
	self.wallMap = nil
	self.pathBox = nil
	self.deathBehaviour = nil
	self.flatMap = {}
	self.rayToTarget = {x = 0, y = 0}
end

function character:freeResources(collider)
	if pathBox then collider:remove(self.pathBox) end
	gameObject.freeResources(self, collider)
end


-------------------------------------------------
--[[Movement, collision detection and pathing]]--
-------------------------------------------------

function character:processEvent(e)
	gameObject.processEvent(self, e)
	if e:getID() == "collision" then
		if e:getDesc() == "active_mover" then
			if self.deathBehaviour ~= nil then 
				for _, v in ipairs(self.deathBehaviour)	do v() end
			end
			self.setState(self, "dead")
			if self.id == "player" then
				gm:setState("dead")
			end
		end
	if e:getDesc() == "dormant_bullet" and self.id == "player" then
		if self.deathBehaviour ~= nil then 
			for _, v in ipairs(self.deathBehaviour)	do v() end
		end
		self.setState(self, "dead")
		if self.id == "player" then
			gm:setState("dead")
		end
	elseif (e:getDesc() == "attacking_path_jailer_melee" or e:getDesc() == "attacking_direct_jailer_melee") and self.id == "player" then
		if self.deathBehaviour ~= nil then 
			for _, v in ipairs(self.deathBehaviour)	do v() end
		end
		self.setState(self, "dead")
		if self.id == "player" then
			gm:setState("dead")
		end
	end
	elseif e:getID() == "activate" then 
		if self.state ~= "dead" then self.state = e:getDesc() end
	end
end

function character:getOldPos()
	return self.oldPos
end

function character:getFrameMoveVec()
	return vector(self.position.x-self.oldPos.x, self.position.y-self.oldPos.y)
end

function character:move(pos)
	--gameObject.setDir(self, pos)
	self.oldPos.x, self.oldPos.y = self.position.x, self.position.y
	gameObject.move(self, pos)
	self.pathBox:moveTo(self.position.x + ((self.size.x/2)),
					self.position.y +((self.size.y/2)))
end

function character:setDeathBehaviour(b)
	self.deathBehaviour = b
end

function character:getDeathBehaviour()
	return self.deathBehaviour
end

function character:setPos(pos)
	gameObject.setPos(self, pos)
	self.pathBox:moveTo(self.position.x + ((self.size.x/2)),
					self.position.y +((self.size.y/2)))
end

function character:getMoveVec()
	return self.moveVec
end

function character:setMoveVec(v)
	self.moveVec = v
end

function character:getSpeed()
	return self.speed
end

function character:setSpeed(s)
	self.speed = s
end

function character:getTarget()
	return self.target
end

function character:setTarget(t)
	self.target = t
end

function character:setWallMap(w)
	self.wallMap = w
end

function character:getWallMap()
	return self.wallMap
end



-------------------------------------------------------------------------------
-- character:copyPath
--
-- Arguments
-- p - the Jumper path
--
-- Copies the nodes from a Jumper path to the character's internal path 
-------------------------------------------------------------------------------
function character:copyPath(p)
	if p == nil then
		-- If no path, then discard character's internal path
		self.currentPoint = 0; self.pathTarget = {r = 0, c = 0}
		self.numPathNodes = 0
		self.path = nil
	else
		-- Discard character's old path
		self.path = {}

		-- Copy node data from the Jumper path to the internal path.
		-- While writing this part I made the unfortunate discovery that
		-- Lua's length operator (#) is apparently implementation-dependent,
		-- meaning that I couldn't rely on it doing what I wanted it to do,
		-- which was to return the number of values up to the first nil.
		-- Discarding and recreating the path each time isn't the most
		-- elegant alternative, but whatever.
		local count = 1
		for node, _ in p:nodes() do
			self.path[count] = {}
			self.path[count].col = node.x
			self.path[count].row = node.y
			count = count + 1
		end
		self.path[count] = nil
		self.numPathNodes = count - 1
	end
end

function character:getPath()
	return self.path
end

function character:setPathTimer(t)
	self.pathTimer = t
end

function character:incPathTimer(dt)
	self.pathTimer = self.pathTimer + dt
end

function character:getPathTimer()
	return self.pathTimer
end

function character:testPathTimer(t)
	if self.pathTimer >= t then self.pathTimer = self.pathTimer - t; return true end
	return false
end

function character:toWorldSpace(col, row, blockSize)
	local x = (col - 1) * blockSize
	local y = (row - 1) * blockSize
	return x + (blockSize/2), y + (blockSize/2)
end

function character:isAtEndOfPath()
	if self.path then
		return self.currentPoint == self.numPathNodes 
	else
		return false
	end
end



-------------------------------------------------------------------------------
-- character:startPath
--
-- Arguments
-- blockSize - the size of a single square tile in standard LÖVE units
--			   (I'm not actually sure what said units are)
--
-- Starts the character on its path, copied in at character:copyPath
-------------------------------------------------------------------------------
function character:startPath(blockSize)

	-- Set the character's point along the path to the start point
	self.currentPoint = 1
	
	-- The character's current target coordinates (from its previous path)
	-- might correspond to a node in its new path. If so, its current point
	-- along the new path (i.e. the index of the next node it needs to get to)
	-- will be set to the index of the node corresponding to the target
	-- coordinates.
	for i,v in ipairs(self.path) do
		if v.col == self.pathTarget.c and v.row == self.pathTarget.r then
			self.currentPoint = i
			break
		end 
	end
	
	-- Get the coordinates of the next target. 
	-- self.target is like self.pathTarget, but is in world space,
	-- and is used in character:testPathCollision to to determine
	-- whether or not the character has hit its target node.
	local x, y = self:toWorldSpace(self.path[self.currentPoint].col, 
				       	self.path[self.currentPoint].row,
				       	blockSize)
	
	self.target = vector(x,y)
end


	
-------------------------------------------------------------------------------
-- character:setPathBox
--
-- Sets up the path box. This invisible box exists in the centre of the
-- character, and is used to test whether or not the character  has reached its
-- current target node (i.e. whether the centre of the target is within the
-- path box.
-------------------------------------------------------------------------------
function character:setPathBox()
	self.pathBox = theCollider:addRectangle(0, 0, 2, 2)
	theCollider:setGhost(self.pathBox)
	self.pathBox.object = self
end



-------------------------------------------------------------------------------
-- character:testPathCollision
--
-- Arguments
-- blockSize - the size of a single square tile in standard LÖVE units
--			   (I'm not actually sure what said units are)
--
-- Checks whether the character has hit the next node in its path, and sets
-- a new target if it has
-------------------------------------------------------------------------------
function character:testPathCollision(blockSize)
	if self.pathBox:contains(self.target.x, self.target.y) then
		if(self.currentPoint < self.numPathNodes) then
			-- Set the target node to the next one
			self.currentPoint = self.currentPoint + 1
			-- Set the grid-space target
			self.pathTarget.r = self.path[self.currentPoint].row
			self.pathTarget.c = self.path[self.currentPoint].col
			-- Set the world-space target
			local x, y = self:toWorldSpace(self.pathTarget.c, self.pathTarget.r, blockSize)
			self.target = vector(x, y)
		end
	end
end


-------------------------------------------------------------------------------
-- character:draw
--
-- Arguments
-- debug -	if true, draws the character's outline and the outline of its
-- 		   	pathbox instread of the graphic for the character itself
--
-- Draws either the character or its and its path box's bounding boxes
-------------------------------------------------------------------------------
function character:draw(debug)
	gameObject.draw(self, debug)
	if(debug) then self.pathBox:draw("line") end
end
