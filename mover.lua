require("gameObject")


mover = {}
for k,v in pairs(gameObject) do
	mover[k]=v
end
mover.__index = mover

setmetatable(mover,
	{__index = gameObject,
	__call = function(cls, ...)
		return cls.new(...)
		end
	})

function mover.new(...)
	local self = setmetatable(gameObject(), mover)
	self:init(...)
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

function mover:init(objType)
	gameObject.init(self)
	self:setClass(objType)
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

function mover:setDist(d)
	self.dist = d
end

function mover:getDist()
	return self.dist
end

function mover:getOldPos()
	return self.oldPos
end

function mover:setSpeed(s)
	self.speed = s
end

function mover:setDir(dir)
	self.dir = dir
end

function mover:getDir()
	return self.dir
end

function mover:setExtent(i, vec)
	self.extents[i] = vec;
end

function mover:getExtent(i)
	return self.extents[i];
end

function mover:getCurrentExtent()
	return self.currentExtent;
end

function mover:getOtherExtent()
	return self.otherExtent;
end

function mover:setCurrentExtent(e)
	self.currentExtent = e
end

function mover:setOtherExtent(e)
	self.otherExtent = e
end

function mover:calcExtent(block)
	self.extentsDist = self.extents[self.currentExtent]:dist(self.extents[self.otherExtent]) * block
	self.dist = self.position:dist(self.extents[1] * block)
	self.extents[1] = self.extents[1] * block
	self.extents[2] = self.extents[2] * block
end

function mover:setFirstExtent(ex)
	self.extents[1] = ex
end

function mover:setSecondExtent(ex)
	self.extents[2] = ex
end

function mover:move(pos)
	self.oldPos.x, self.oldPos.y = self.position.x, self.position.y
	gameObject.move(self, pos)
end

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

