require("gameObject")


character = {}
for k,v in pairs(gameObject) do
	character[k]=v
end
character.__index = character

setmetatable(character,
	{__index = gameObject,
	__call = function(cls, ...)
		return cls.new(...)
		end
	})

function character.new(...)
	local self = setmetatable(gameObject(), character)
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
	self.path = nil
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
	--self.oldPos = pos:clone()
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

function character:setPath(p)
	if p == nil then self.currentPoint = 0; self.pathTarget = {r = 0, c = 0} end
	self.path = p
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
		return self.currentPoint == 1 
	else
		return false
	end
end

function character:startPath(blockSize)
	if #self.path > 1 then self.currentPoint = #self.path -1 else self.currentPoint = #self.path end
	for i,v in ipairs(self.path) do
		if v.col == self.pathTarget.c and v.row == self.pathTarget.r then
			self.currentPoint = i
			break
		end 
	end
	local x, y = self:toWorldSpace(self.path[self.currentPoint].col, self.path[self.currentPoint].row, blockSize)
	self.target = vector(x,y)
end
		
function character:setPathBox()
	self.pathBox = theCollider:addRectangle(0,0, 2, 2)
	theCollider:setGhost(self.pathBox)
	self.pathBox.object = self
end

function character:setFlatMap(p)
	self.flatMap = p
end

function character:getFlatMap()
	return self.flatMap
end

function character:pathCollision(blockSize)
	if self.pathBox:contains(self.target.x, self.target.y) then
		if(self.currentPoint > 1) then	
			self.currentPoint = self.currentPoint-1
			self.pathTarget.r = self.path[self.currentPoint].row
			self.pathTarget.c = self.path[self.currentPoint].col
			local x, y = self:toWorldSpace(self.pathTarget.c, self.pathTarget.r, blockSize)
			self.target = vector(x, y)
		else
			--print("whatever happened")
		end
	end
end


--Draw: adds a tiny box in the middle; the pathfinding box
function character:draw(debug)
	gameObject.draw(self, debug)
	if(debug) then self.pathBox:draw("line") end
end
