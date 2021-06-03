-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- gameObject.lua
--
-- Game objects; basis for enemies and turrets, etc.
-------------------------------------------------------------------------------

require("src.utils")
local textures = require("src.textures")
local vector = require("src.external.hump.vector")
local gameConf = require("src.gameConf")
local theCollider = require("src.collider")



-- A cheeky bit of object orientation.
local gameObject = {}

-- When looking for a gameObject "instance"'s members, look in gameObject.
gameObject.__index = gameObject

-- Give gameObject something resembling a C++-style constructor.
setmetatable(gameObject,
		{__call = function(cls, ...)
			return cls.new(...)
		end}
)



function gameObject.new()
	local self = setmetatable({}, gameObject)
	self:init()
	return self
end



-------------------------------------------------------------------------------
-- Object states
--
-- These possible states and what they mean for the object. They're mostly just
-- guidelines.
--
-- active   This object will do things until something changes its state.
--
-- dormant  This object is not "doing things", but another object may activate
--          it. It cannot activate itself.
--
-- dead     This object is removed from the game and its "update" function will
--          no longer be called.
--
-- used     Like "dead", but will persist on the map.
--
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- init
--
-- Sets default values.
-------------------------------------------------------------------------------
function gameObject:init()
	self.size = vector(1, 1)
	self.angle = 0
	self.position = vector(0,0)
	self.direction = vector(0,0)
	self.invisible = false
	self.state = "dormant"
	self.class = "object"
	self.canCollide = false
	self.shapeOffsetX = 0
	self.shapeOffsetY = 0
	self.id = nil
	self.collisionBehaviour = {}
	self.collisionShape = nil
	self.collisionShapeType = nil
	self.category = nil
	self.textures = {}
	self.anims = {}
end



-------------------------------------------------------------------------------
-- getPos
--
-- Return the object's world-space position; a HUMP vector.
-------------------------------------------------------------------------------
function gameObject:getPos()
	return self.position
end



-------------------------------------------------------------------------------
-- getDir
--
-- Return the object's direction vector.
-------------------------------------------------------------------------------
function gameObject:getDir()
	return self.direction
end



-------------------------------------------------------------------------------
-- getCanCollide
--
-- Return whether or not the object can collide with anything
-------------------------------------------------------------------------------
function gameObject:getCanCollide()
	return self.canCollide
end



-------------------------------------------------------------------------------
-- getCentre
-------------------------------------------------------------------------------
function gameObject:getCentre(buf)
	buf.x, buf.y = self.collisionShape:center()
end



-------------------------------------------------------------------------------
-- getTopLeft
-------------------------------------------------------------------------------
function gameObject:getTopLeft(buf)
	buf.x, buf.y, _, _ = self.collisionShape:bbox()
end



-------------------------------------------------------------------------------
-- getTopRight
-------------------------------------------------------------------------------
function gameObject:getTopRight(buf)
	_, buf.y, buf.x, _ = self.collisionShape:bbox()
end



-------------------------------------------------------------------------------
-- getBottomLeft
-------------------------------------------------------------------------------
function gameObject:getBottomLeft(buf)
	buf.x, _, _, buf.y = self.collisionShape:bbox()
end



-------------------------------------------------------------------------------
-- getBottomRight
-------------------------------------------------------------------------------
function gameObject:getBottomRight(buf)
	_, _, buf.x, buf.y = self.collisionShape:bbox()
end



-------------------------------------------------------------------------------
-- setDir
--
-- Set the object's direction angle (has no bearing on its velocity vector)
-------------------------------------------------------------------------------
function gameObject:setDir(dir)
	self.direction = dir
end



-------------------------------------------------------------------------------
-- setPos
--
-- Set the object's position as well as its collision shape's position
-------------------------------------------------------------------------------
function gameObject:setPos(pos)
  self.position = pos
  if "dead" ~= self.state and self.canCollide then
    if "rectangle" == self.collisionShapeType then
      self.collisionShape:moveTo( self.position.x + (self.size.x/2) + self.shapeOffsetX,
                                  self.position.y + (self.size.y/2) + self.shapeOffsetY)
    else
      self.collisionShape:moveTo( self.position.x + (self.size.x/2.8) + self.shapeOffsetX,
                                  self.position.y + (self.size.y/2.8) + self.shapeOffsetY)
    end
  end
end



-------------------------------------------------------------------------------
-- setCanCollide
--
-- Tell the object whether or not it should take part in collision resolution
-------------------------------------------------------------------------------
function gameObject:setCanCollide(c)
	self.canCollide = c
end



-------------------------------------------------------------------------------
-- move
--
-- Move the object along the provided vector.
-------------------------------------------------------------------------------
function gameObject:move(vec)
  self:setPos(self.position + vec)
end



-------------------------------------------------------------------------------
-- ignoringBullets
-------------------------------------------------------------------------------
function gameObject:ignoringBullets()
	return self.ignoresBullets
end



-------------------------------------------------------------------------------
-- setInvisible
-------------------------------------------------------------------------------
function gameObject:setInvisible(invis)
	self.invisible = invis
end



-------------------------------------------------------------------------------
-- getInvisible
-------------------------------------------------------------------------------
function gameObject:getInvisible()
	return self.invisible
end



-------------------------------------------------------------------------------
-- setShapeOffsets
-------------------------------------------------------------------------------
function gameObject:setShapeOffsets(x, y)
	self.shapeOffsetX = x
	self.shapeOffsetY = y
end



-------------------------------------------------------------------------------
-- setCategory
-------------------------------------------------------------------------------
function gameObject:setCategory(c)
	self.category = c
end



-------------------------------------------------------------------------------
-- getCategory
-------------------------------------------------------------------------------
function gameObject:getCategory()
	return self.category
end



-------------------------------------------------------------------------------
-- getID
-------------------------------------------------------------------------------
function gameObject:setID(id)
	self.id = id
end



-------------------------------------------------------------------------------
-- setID
-------------------------------------------------------------------------------
function gameObject:getID()
	return self.id
end



-------------------------------------------------------------------------------
-- addCollisionBehaviour
-------------------------------------------------------------------------------
function gameObject:addCollisionBehaviour(c)
	self.collisionBehaviour[#self.collisionBehaviour+1] = c
end



-------------------------------------------------------------------------------
-- getCollisionBehaviour
-------------------------------------------------------------------------------
function gameObject:getCollisionBehaviour()
	return self.collisionBehaviour
end



-------------------------------------------------------------------------------
-- setState
-------------------------------------------------------------------------------
function gameObject:setState(s)
	self.state = s
end



-------------------------------------------------------------------------------
-- getState
-------------------------------------------------------------------------------
function gameObject:getState()
	return self.state
end



-------------------------------------------------------------------------------
-- setSize
-------------------------------------------------------------------------------
function gameObject:setSize(vec)
	self.size = vec
end



-------------------------------------------------------------------------------
-- getSize
-------------------------------------------------------------------------------
function gameObject:getSize()
	return self.size
end



-------------------------------------------------------------------------------
-- setClass
-------------------------------------------------------------------------------
function gameObject:setClass(newClass)
	self.class = newClass
end



-------------------------------------------------------------------------------
-- getClass
-------------------------------------------------------------------------------
function gameObject:getClass()
	return self.class
end



-------------------------------------------------------------------------------
-- updateAnim
-------------------------------------------------------------------------------
function gameObject:updateAnim(dt)
	if self.anims[self.state] then self.anims[self.state]:update(dt) end
end



-------------------------------------------------------------------------------
-- draw
-------------------------------------------------------------------------------
function gameObject:draw(pixelLocked)
	if self.invisible then return end
	local drawPos = self:getPos():clone()

  if(pixelLocked) then
    drawPos.x = jRound(drawPos.x)
    drawPos.y = jRound(drawPos.y)
  end

  if self.anims[self.state] then
    self.anims[self.state]:draw(drawPos.x, drawPos.y, 0, 1, 1)
  else
    love.graphics.draw(self:getTexture(self.state),
                       drawPos.x + gameConf.blockSize/2,
                       drawPos.y + gameConf.blockSize/2,
                       self.angle,
                       1,
                       1,
                       gameConf.blockSize/2,
                       gameConf.blockSize/2)
  end
end



-------------------------------------------------------------------------------
-- drawDebug
--
-- Draws the object's debug shape
-------------------------------------------------------------------------------
function gameObject:drawDebug()
  if self.canCollide then self.collisionShape:draw("line") end
end



-------------------------------------------------------------------------------
-- freeResources
-------------------------------------------------------------------------------
function gameObject:freeResources(collider)
	collider:remove(self.collisionShape)
end



-------------------------------------------------------------------------------
-- assignTextureSet
--
-- Read the texture set and load in the textures it specifies
-------------------------------------------------------------------------------
function gameObject:assignTextureSet(textureSet)

  if textureSet then

    local t = textures.g_textureSets[textureSet]

    -- Does the textureset exist?
    if t then
      for state, tex in pairs(t) do

        --do the asked-for textures exist?
        if textures.rTextures[tex] then
          self:setTexture(state,
            textures.rTextures[tex].data,
            true)
        else
          print("Warning! Texture \"" .. tex .. "\" does not exist " ..
            "in the table of textures")
        end

      end
    else
      print("Warning! Textureset \"" .. textureSet ..
        "\" doesn't exist.")
    end

    else
      print("Warning! Block \"" .. self:getID() .. "\" has no textureset.")
    end

end



-------------------------------------------------------------------------------
-- setTexture
--
-- Give the object its textures and describe how to draw them
-------------------------------------------------------------------------------
function gameObject:setTexture(key, value, repeating)
	if self.textures[key] == nil then
		 self.textures[key] = {}
	end
	value:setFilter("nearest")
	self.textures[key].texture = value
	if repeating then
		self.textures[key].texture:setWrap("repeat", "repeat")
	end
end



-------------------------------------------------------------------------------
-- getTexture
-------------------------------------------------------------------------------
function gameObject:getTexture(key)
	return self.textures[key].texture
end



-------------------------------------------------------------------------------
-- setAnim
-------------------------------------------------------------------------------
function gameObject:setAnim(key, value)
	self.anims[key] = value
end



-------------------------------------------------------------------------------
-- resetAnims
-------------------------------------------------------------------------------
function gameObject:resetAnims()
	for k, a in pairs(self.anims) do
		a:reset()
		a:play()
	end
end



-------------------------------------------------------------------------------
-- resetAnim
-------------------------------------------------------------------------------
function gameObject:resetAnim(key)
	self.anims[key]:reset()
	self.anims[key]:play()
end



-------------------------------------------------------------------------------
-- processEvent
-------------------------------------------------------------------------------
function gameObject:processEvent(e)

	if e:getDesc() == "switchOn" then
		self.state = "used"

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



-------------------------------------------------------------------------------
-- setCollisionRectangle
-------------------------------------------------------------------------------
function gameObject:setCollisionRectangle()
	self.collisionShape = theCollider:rectangle(0,0, self.size.x, self.size.y)
  self.collisionShapeType = "rectangle"
	self.collisionShape.object = self
end



-------------------------------------------------------------------------------
-- setCollisionCircle
-------------------------------------------------------------------------------
function gameObject:setCollisionCircle()
	self.collisionShape = theCollider:circle(0, 0, self.size.x/2.8)
  self.collisionShapeType = "circle"
	self.collisionShape.object = self
end



-------------------------------------------------------------------------------
-- getCollisionShape
--
-- Get collision shape
-------------------------------------------------------------------------------
function gameObject:getCollisionShape()
	return self.collisionShape
end



-------------------------------------------------------------------------------
-- intersectsRay
-------------------------------------------------------------------------------
function gameObject:intersectsRay(sx, sy, dx, dy)
	return self.collisionShape:intersectsRay(sx, sy, dx, dy)
end

return gameObject
