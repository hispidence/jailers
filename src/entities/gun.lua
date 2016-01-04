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

function gun:bulletCollisionBehaviour(sender, target, desc, timer)
	return function(o1, o2)
		e1 = jlEvent(sender, target, "dead", "changestate_bullet");
		gm:sendEvent(e1)
	end	
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

function gun:revIter(b)
	local i = 0
	if b then
		i = #b + 1
	end
	return function()
		i = i - 1
		if b and b[i] then
			return i, b[i]
		end
	end
end

function gun:setFiringBehaviour(fb)
	self.firingBehaviour = fb
end

function gun:getBulletByID(id)
	for i, v in ipairs(self.bullets) do
		if v:getID() == id then return i end
	end
	return 0
end

function gun:processEvent(e)
	gameObject.processEvent(self, e)
	if e:getID() == "changestate_bullet" then
		if e:getDesc() == "dead" then
			if self.deathBehaviour ~= nil then 
				for _, v in ipairs(self.deathBehaviour)	do v() end
			end
			local bulletIndex;
			bulletIndex = self:getBulletByID(e:getSender())

			if bulletIndex ~= 0 then self:removeBullet(bulletIndex) end
		end
	end
end
	
function gun:listBullets()
	print("\n")
		for i, v in ipairs(self.bullets) do
		print("index: " .. i .. ", id: " .. v:getID())
		end
	print("\n")
end

function gun:resetTimeLastBullet()
	self.timeLastBullet = self.bulletTime
end

function gun:setBulletTexture(key, value, repeating)
	if self.bulletTextures[key] == nil then
		 self.bulletTextures[key] = {} end
	self.bulletTextures[key].texture = value
	if repeating then
		self.bulletTextures[key].texture:setWrap("repeat", "repeat")	
	end 
end

function gun:freeResources(collider)
	self:killBullets()
	if self.firingBehaviour then self.firingBehaviour:reset() end
	gameObject.freeResources(self, collider)
end

function gun:killBullets()
	self:resetTimeLastBullet()
	for k, v in self:revIter(self.bullets) do
		self:removeBullet(k)
	end
end

function gun:getBullets()
	return self.bullets
end

function gun:setBullets(b)
	self.bullets = b
end

function gun:setBulletState(i, s)
	self.bullets[i]:setState(s)
end

function gun:setBulletPos(i, p)
	self.bullets[i]:setPos(p)
end

function gun:getAges()
	return self.ages
end

function gun:setAges(a)
	self.ages = a
end

function gun:setAge(i, b)
	self.ages[i] = b
end

function gun:resetFiringBehaviour()
	if self.firingBehaviour then self.firingBehaviour:reset() end
end

function gun:getBulletsMade()
	return self.bulletsMade
end

function gun:setBulletsMade(b)
	self.bulletsMade = b
end

function gun:getBulletOffset()
	return self.bulletOffset
end

function gun:setBulletOffset(b)
	self.bulletOffset = b
end

function gun:getBulletTexture()
	return self.bulletTexture
end

function gun:setBulletVel(vel)
	self.bulletVel = vel
end

function gun:getBulletVel()
	return self.bulletVel
end

function gun:setBulletLife(l)
	self.bulletLife = l
end

function gun:getBulletLife()
	return self.bulletLife
end

function gun:setBulletTime(t)
	self.bulletTime = t
	self.timeLastBullet = t
end

function gun:getBulletTime()
	return self.bulletTime
end

function gun:removeBullet(i)
	self.bullets[i]:freeResources(theCollider)
	table.remove(self.bullets, i)
	table.remove(self.ages, i)		
end

function gun:addBullet(pos, vel)
	local index = 0
	--TODO: possible wrapover issues
	self.bulletsMade = self.bulletsMade + 1
	index = #(self.bullets) + 1
	self.bullets[index] = gameObject()
	self.bullets[index]:setState("dormant")
	local bulletState = self.bullets[index]:getState()
	self.bullets[index]:setSize(vector(6, 6))
	self.bullets[index]:setQuad(love.graphics.newQuad(0, 0, 6, 6, 6, 6))
	self.bullets[index]:setCollisionRectangle()
	self.bullets[index]:setTexture(bulletState, self.bulletTextures[bulletState].texture, false)
	self.bullets[index]:addToCollisionGroup("bullet")
	self.bullets[index]:setID("bullet"..self.bulletsMade)
	self.bullets[index]:setCollisionBehaviour({self:bulletCollisionBehaviour(self.bullets[index]:getID(), self.getID(self), "bulletcollision", 0)})
	self.bullets[index]:setCategory("bullet")
	self.bullets[index]:setPos(pos)
	self.bullets[index]:setVel(vel)
	self.ages[index] = 0
end

function gun:updateSound(dt)
	if self.firingBehaviour ~= nil then if self.firingBehaviour:isSoundReady(dt) then gameObject.playSound(self) end
	else
		gameObject.updateSound(self, dt)
	end
end

---------------------------------------------------------------------------------------------------
--	gun:update(number dt)
--	
--	Fires the gun and moves the bullets.
---------------------------------------------------------------------------------------------------
function gun:update(dt)
--	if self.state == "active" then
--		if self.firingBehaviour ~= nil then self.firingBehaviour:fire(dt, self) else
--			if self.timeLastBullet > self.bulletTime then
--				-- Make up for any "missed time": if the bullet fires late due to low framerate, make up for the intervening
--				-- time by moving the bullet forward
--				local timeDifference = self.timeLastBullet - self.bulletTime
--				extraOffset = self.bulletVel * timeDifference
--				self:addBullet(self.position+self.bulletOffset+extraOffset, self.bulletVel)
--				self.timeLastBullet = self.timeLastBullet - self.bulletTime
--			end
--			self.timeLastBullet = self.timeLastBullet + dt
--		end
--	end
--	for i, v in self:revIter(self.bullets) do
--		if v:getState() ~= "dead" then
--		v:move(v:getVel() * dt)
--		end
--		self.ages[i] = self.ages[i] + dt
--
--		if self.ages[i] > self.bulletLife then self:removeBullet(i) end
--	end
end



-------------------------------------------------------------------------------
-- drawQuad
--
-- Arguments
-- debug -	if true, draws the object's outline instread of the graphic for
-- the object itself
--
-- pixelLocked -  Are the graphics aligned to the 'pixel' grid?
--
-- Draws an object
-------------------------------------------------------------------------------
function gun:drawQuad(debug, pixelLocked)
  gameObject.drawQuad(self, debug, pixelLocked)

	--for i, v in self:revIter(self.bullets) do
	--	if v:getState() ~= "dead" then
	--		v:drawQuad(debug)	
	--	end
	--end
end
