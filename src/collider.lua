-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- collider.lua
--
-- Handles collision resolution; fires off events and repositions entities.
-------------------------------------------------------------------------------

HC = require("src/external/HC")

theCollider = HC.new(128)

local MAX_TESTS = 10



-------------------------------------------------------------------------------
-- resolveCollision
--
-- Repositions an object to the nearest point outside of the object with which
-- it has collided. i.e. We want object a to end up as close to object b as it
-- can be without actually being inside of it.
-------------------------------------------------------------------------------
function resolveCollision(a, b)
  
  -- Players and enemies get reposition precedence over static objects
	if b.object:getClass() == "player" then
		a, b = b, a
	elseif b.object:getClass() == "enemy" and
     b.object:getState() ~= "dormant" and
     b.object:getState() ~= "dead" then
		a, b = b, a
	end


  -- Store object a's old position; i.e. their position in the last update
  -- cycle when they hadn't yet collided with object b.
	local recentGood = a.object:getOldPos():clone()
  
  -- Variables for the testCollision function
  -- step:  how far along object a's movement vector should we (temporarily)
  --        position it for the next test?
  --
  -- nTests:  how many positions for object a have we tested?
  --
  -- res: did object a and object b collide during the last test? We set
  --      res to true here because it did just collide, which is why we're
  --      in this function
  --
  -- moveVec: how far did object a move since the last frame?
  --
  -- vec: vector to store the new movement vector for the next test
	local step = 1
	local nTests = 0
	local res = true
  local moveVec = a.object:getFrameMoveVec()
  local vec

  -- testCollision. Recursive. Horay for lexical scoping!
	function testCollision(nTests, a, b, step, res)
    
    -- Calculate a new movement vector
		vec = moveVec * step
    
    -- Set a's new position. This position might be wrong, but since collision
    -- detection is done entirely sequentially, this wrong position will be
    -- overwritten by the correct one before it gets used in any calculations.
    --
    -- Note that this will not change the contents of a.object:oldPos
    a.object:setPos(a.object:getOldPos() + vec)
    
    -- Are the objects still colliding after all that kerfuffle?
		res = a:collidesWith(b)
    
    -- Increment the number of tests
		nTests = nTests+1
    
    if nTests <= MAX_TESTS then
      -- Did we collide? If we did, calculate a new step to bring us slightly
      -- farther away from object b. If not, calculate one to bring us slightly
      -- closer.
      if res == false then
        -- store the last non-colliding position; this might be one we
        -- calculated in a previous step; see below.
        recentGood = a.object:getPos() 
        step = step + step/2
      else
        step = step - step/2
      end
      
      -- Make use of Lua's tail call optimisation because we can.
      -- (note: doesn't actually return a value)
      return testCollision(nTests, a, b, step, res)
    end
	end
  
  -- Actually call the function
  testCollision(nTests, a, b, step, res)

  -- Set the object's position to the one we've calculated, if any.
	a.object:setPos(recentGood)

end



-------------------------------------------------------------------------------
-- onCollide
--
-- Function passed to HC
-------------------------------------------------------------------------------
function onCollide(dt, objA, objB)
  print("Collision 'twixt "..objA.object:getID().." and "..objB.object:getID())
	if (objA.object:getCategory() == "trigger" and objA.object:getState() == "dormant")
		or (objB.object:getCategory() == "trigger" and objB.object:getState() == "dormant") then return end

	if objA.object:getState() == "dead" or objB.object:getState() == "dead" then return end

	if (objA.object:getCategory() == "bullet" and objB.object:ignoringBullets()) or
 		(objB.object:getCategory() == "bullet" and objA.object:ignoringBullets()) then return end

	local collides = true

	if	(objA.object:getCategory() == "bullet" and objB.object:getID() == "player") or
		(objB.object:getCategory() == "bullet" and objA.object:getID() == "player") then
		collides = false
		
		local pRad
		local bRad

		--do the radius bullets of player and bullet intersect?
		local rad1 = objA.object:getSize().x/2
		local rad2 = objB.object:getSize().x/2

		local cenA = vector(0, 0)

		local cenB = vector(0, 0)

		objB.object:getCentre(cenA)
		objA.object:getCentre(cenB)
		dist = cenA:dist(cenB)
		if dist < (rad1 + rad2) then
			collides = true
		end

	elseif 	objA.object:getCategory() ~= "bullet" and objB.object:getCategory() ~= "bullet" and
		objA.object:getCategory() ~= "trigger" and objB.object:getCategory() ~= "trigger" then resolveCollision(objA, objB) end

	if not collides then return end

	--There's certainly a collision so do all of the collision resolution things

	e1 = jlEvent(objA.object:getID(), objB.object:getID(), objA.object:getState() .. "_" .. objA.object:getCategory(), "collision")
	e2 = jlEvent(objB.object:getID(), objA.object:getID(), objB.object:getState() .. "_" .. objB.object:getCategory(), "collision")
	gm:sendEvent(e1)
	gm:sendEvent(e2)
	
	local playerInvolved = false
	
	local player = nil
	local nonPlayer = nil

	if objA.object:getID() == "player" then playerInvolved = true; player = objA.object; nonPlayer = objB.object elseif
	objB.object:getID() == "player" then playerInvolved = true; player = objB.object; nonPlayer = objA.object end
	
	local slideThresh = 0

	if playerInvolved then
		local trP = vector()
		local trN = vector()
		local tlP = vector()
		local tlN = vector()
		local brP = vector()
		local brN = vector()
		local blP = vector()
		local blN = vector()

		player:getTopRight(trP)
		player:getTopLeft(tlP)
		player:getBottomRight(brP)
		player:getBottomLeft(blP)
		nonPlayer:getTopRight(trN)
		nonPlayer:getTopLeft(tlN)
		nonPlayer:getBottomLeft(blN)
		nonPlayer:getBottomRight(brN)
		if trP:dist(blN) < slideThresh then
			if player:getDir().y < 0 and player:getDir().x == 0 then player:move(vector(-1, 0) * (dt * player:getSpeed()/3)) 
			elseif player:getDir().x > 0 and player:getDir().y == 0 then player:move(vector(0, 1) * (dt * player:getSpeed()/3)) end
		end
		if tlP:dist(brN) < slideThresh then	

			if player:getDir().y < 0 and player:getDir().x == 0 then player:move(vector(1, 0) * (dt * player:getSpeed()/3)) 
			elseif player:getDir().x < 0 and player:getDir().y == 0 then player:move(vector(0, 1) * (dt * player:getSpeed()/3)) end
		end
		if brP:dist(tlN) < slideThresh then 
			if player:getDir().y > 0 and player:getDir().x == 0 then player:move(vector(-1, 0) * (dt * player:getSpeed()/3)) 
			elseif player:getDir().x > 0 and player:getDir().y == 0 then player:move(vector(0, -1) * (dt * player:getSpeed()/3)) end
		end
		if blP:dist(trN) < slideThresh then 
			if player:getDir().y > 0 and player:getDir().x == 0 then player:move(vector(1, 0) * (dt * player:getSpeed()/3)) 
			elseif player:getDir().x < 0 and player:getDir().y == 0 then player:move(vector(0, -1) * (dt * player:getSpeed()/3)) end
		end
		local dir = player:getDir()
	end
	
	cbA = objA.object:getCollisionBehaviour()
	cbB = objB.object:getCollisionBehaviour()

	if  objA.object:getID() == "player" or objB.object:getID() == "player" or objA.object:getCategory() == "bullet" or objB.object:getCategory() == "bullet" then	
		if objA.object:getState() ~= "off" then
			if cbA ~= nil then
				for _, v in ipairs(cbA)	do v() end--(objA.object, objB.object)
			end
		end
		if objB.object:getState() ~= "off" then
			if cbB ~= nil then
				for _, v in ipairs(cbB)	do v() end--(objA.object, objB.object)
			end
		end
	end
end

