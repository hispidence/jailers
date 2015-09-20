require("src/jailerUtil")
require("src/collider")
vector = require("src/hump.vector")

	gameObject = {}

	newTexture = {
			  __newindex = function(t, k, v) 
				rawset(t, k, v)
				--t[k] = v
			end}


			--__index = function(t, k) 
			--	return t[k]
			--end}



	gameObject.__index = gameObject

	setmetatable(gameObject,
			{__call = function(cls, ...)
				return cls.new(...)
			end})

	function gameObject.new()
		local self = setmetatable({}, gameObject)
		self:init()
		return self
	end

	function gameObject:init()
		self.size = vector(1, 1)
		self.collisionSize = nil
		self.position = vector(0,0) 
		self.direction = vector(0,0)
		self.vel = vector(0,0)
		self.behaviour = nil
		self.resetBehaviour = nil
		self.bData = nil
		self.invisible = false
		self.state = "dormant"
		self.class = "object"
		self.shapeOffsetX = 0
		self.shapeOffsetY = 0
		self.quad = nil
		self.id = nil
		self.ignoredBullets = false
		self.sounds = setmetatable({}, newTexture)
		self.collisionBehaviour = nil
		self.collisionShape = nil
		self.category = nil
		self.textures = setmetatable({}, newTexture)
		self.anims = setmetatable({}, newTexture)
	end


	---------------------------
	--[[ Movement functions]]--
	---------------------------

	function gameObject:getPos()
		return self.position
	end

	function gameObject:getDir()
		return self.direction
	end

	function gameObject:getVel()
		return self.vel
	end

	function gameObject:getCentre(buf)
	  buf.x, buf.y = self.collisionShape:center()
	end

	function gameObject:getTopLeft(buf)
	  buf.x, buf.y, _, _ = self.collisionShape:bbox()	
	end

	function gameObject:getTopRight(buf)
    _, buf.y, buf.x, _ = self.collisionShape:bbox()
	end

	function gameObject:getBottomLeft(buf)
	  buf.x, _, _, buf.y = self.collisionShape:bbox()	
	end

	function gameObject:getBottomRight(buf)
	  _, _, buf.x, buf.y = self.collisionShape:bbox()	
	end

	function gameObject:setDir(dir)
		self.direction = dir
	end

	function gameObject:setPos(pos)
		self.position = pos
		if not self.invisible then
			self.collisionShape:moveTo(	self.position.x + (self.size.x/2) + self.shapeOffsetX,
						self.position.y + (self.size.y/2) + self.shapeOffsetY)
		end
	end

	function gameObject:setVel(vel)
		self.vel = vel
	end

	function gameObject:move(vec)
		self.position.x = self.position.x + vec.x
		self.position.y = self.position.y + vec.y
		if not self.invisible then
			self.collisionShape:moveTo(	self.position.x + (self.size.x/2) + self.shapeOffsetX,
				self.position.y + (self.size.y/2) + self.shapeOffsetY)
		end
	end


	-----------------------------------
	--[[State, size, and other data]]--
	-----------------------------------

	function gameObject:setIgnoresBullets(ig)
		self.ignoresBullets = true
	end

	function gameObject:ignoringBullets(ig)
		return self.ignoresBullets
	end

	function gameObject:setBehaviour(behav)
		self.behaviour = behav
	end

	function gameObject:setResetBehaviour(br)
		self.resetBehaviour = br
	end

	function gameObject:setBehaviourData(bd)
		self.bData = bd
	end

	function gameObject:setInvisible(invis)
		self.invisible = invis
	end

	function gameObject:getInvisible()
		return self.invisible
	end

	function gameObject:setSound(key, value, repeating, time)
		if 	self.sounds[key] == nil then
			self.sounds[key] = {} end
		self.sounds[key].data = value
		self.sounds[key].repeating = repeating
		self.sounds[key].wait = time
		self.sounds[key].elapsed = time
		self.sounds[key].done = false
	end

  function gameObject:setShapeOffsets(x, y)
    self:setShapeOffsetX(x); self:setShapeOffsetY(y)
  end

  function gameObject:setShapeOffsetX(x)
    self.shapeOffsetX = x
  end

  function gameObject:setShapeOffsetY(y)
    self.shapeOffsetY = y
  end

	function gameObject:setCategory(c)
		self.category = c
	end

	function gameObject:getCategory()
		return self.category
	end

	function gameObject:setID(id)
		self.id = id
	end

	function gameObject:getID()
		return self.id
	end

	function gameObject:setCollisionBehaviour(c)
		self.collisionBehaviour = c
	end

	function gameObject:getCollisionBehaviour()
		return self.collisionBehaviour
	end

	function gameObject:setState(s)
		self.state = s
	end

	function gameObject:getState()
		return self.state
	end

	function gameObject:getSize()
		return self.size
	end

	function gameObject:setSize(vec)
		self.size = vec
	end

	function gameObject:setClass(newClass)
		self.class = newClass
	end

	function gameObject:getClass()
		return self.class
	end

	function gameObject:setQuad(q)
		self.quad = q
	end


----------------------------
--[[Graphics and drawing]]--
----------------------------

function gameObject:update(dt)
	if self.state ~= "dead" and self.state ~= "dormant" and self.behaviour then self:behaviour(dt) end
end

function gameObject:updateAnim(dt)
	if self.anims[self.state] then self.anims[self.state]:update(dt) end
end

function gameObject:playSound()
	if self.sounds == nil then return end
	local s = self.sounds[self.state]
	if s then
		--TEsound.play(s.data)
	end
end

function gameObject:updateSound(dt)
	if self.sounds == nil then return end
	local s = self.sounds[self.state]
	if s then
		if (s.repeating == "false" or s.repeating == "once") and s.done then return end
		s.elapsed = s.elapsed + dt
		if s.elapsed > s.wait then
			--TEsound.play(s.data)
			s.elapsed = s.elapsed - s.wait
			if s.repeating == "false" or s.repeating == "once" then s.done = true end
		end
	end
end

function gameObject:resetSounds()
	for k, v in pairs(self.sounds) do
		v.elapsed = v.wait
		if v.repeating == "false" then v.done = false end
	end
end

function gameObject:drawQuad(debug)
	vec = self:getPos()
	if(debug) then
		self.collisionShape:draw("line")
	else
		love.graphics.draw(self:getTexture(self.state), self.quad, vec.x * scale, vec.y * scale, 0, scale, scale, 0, 0)
	end
end

function gameObject:draw(debug)
	if self.invisible then return end
	vec = self:getPos()
	if(debug) then
		if self.id == "player" then self.collisionShape:draw("fill") else self.collisionShape:draw("line") end
	else
		if self.anims[self.state] then 
			self.anims[self.state]:draw(vec.x * scale, vec.y * scale, 0, scale, scale)
		else
			love.graphics.draw(self:getTexture(self.state), vec.x * scale, vec.y * scale, 0, scale, scale, 0, 0)
		end
	end
end

function gameObject:freeResources(collider)
	collider:remove(self.collisionShape)
	--don't free textures or sounds - they're not unique per instance
end

function gameObject:setTexture(key, value, repeating)
	if self.textures[key] == nil then
		 self.textures[key] = {} end
	value:setFilter("nearest")
	self.textures[key].texture = value
	if repeating then
		self.textures[key].texture:setWrap("repeat", "repeat")	
	end 
end

function gameObject:getTextureFileName(key)
	return self.textures[key].fileName
end

function gameObject:getTexture(key)
	return self.textures[key].texture
end

function gameObject:setAnim(key, value)
	self.anims[key] = value
end

function gameObject:setAnimMode(key, m)
	self.anims[key]:setMode(m)
end

function gameObject:getAnim(key)
	return self.anims[key]
end

function gameObject:resetAnims()
	for k, a in pairs(self.anims) do
		a:reset()
		a:play()
	end
end

function gameObject:resetAnim(key)
	self.anims[key]:reset()
	self.anims[key]:play()
end

--------------------------------------
--[[Collisions, pathing and events]]--
--------------------------------------

function gameObject:processEvent(e)
	if e:getDesc() == "switchOff" then
		self.state = "off"
	elseif e:getID() == "changestate" then 
		self.state = e:getDesc()

	elseif e:getID() == "move" then 
		self:setPos(e:getData())
	elseif e:getID() == "removeblock" then
		self.state = "dead"
		local e = jlEvent(self.id, "main", "removeblock", "none")
		gm:sendEvent(e)
	elseif e:getID() == "addblock" then
		self.state = "dormant"
		local e = jlEvent(self.id, "main", "addblock", "none")
		gm:sendEvent(e)
	end
end

function gameObject:setCollisionRectangle()
	self.collisionShape = theCollider:addRectangle(0,0, self.size.x, self.size.y)
	self.collisionShape.object = self
end

function gameObject:setCollisionCircle()
	self.collisionShape = theCollider:addCircle(0,0, self.size.x/2)
	self.collisionShape.object = self
end

function gameObject:addToCollisionGroup(group) 
	theCollider:addToGroup(group, self.collisionShape)
end

function gameObject:getCollisionShape()
	return self.collisionShape
end

function gameObject:intersectsRay(sx, sy, dx, dy)
	return self.collisionShape:intersectsRay(sx, sy, dx, dy)
end

function gameObject:collidesRays(starts, dirs)
	for i = 1,4 do
		if self:intersectsRay(starts[i].x, starts[i].y, dirs[i].x, dirs[i].y) then
			if self:intersectsRay(starts[i+4].x, starts[i+4].y, dirs[i+4].x, dirs[i+4].y) then
				return true
			end
		end
	end
	return false
end

function gameObject:findNearest(blockSize)
	return jRound(self.position.x/blockSize) + 1, jRound(self.position.y/blockSize)+1
end
