collider = require("src/hardoncollider")

local MAX_TESTS = 4

function resolveCollision(a, b, dt)
	if b.object:getClass() == "player" then
		a,b = b,a
	end

	if b.object:getClass() == "enemy" and b.object:getState() ~= "dormant" and b.object:getState() ~= "dead" then
		a,b = b,a
	end

	recentGood = a.object:getOldPos():clone()
	step = 1
	nTests = 0
	res = true
	function testCollision(nTests, a, b, step, res)
		if res == false then
			recentGood = posHolder:clone() 
			if nTests == MAX_TESTS then return else step = step + step/2 end
		else
			if nTests == MAX_TESTS then return else step = step - step/2 end
		end
		
		vec = a.object:getFrameMoveVec();
		
		vec = vec:normalized();
		
		vec = vec * step * 50;
	
		res = a:collidesWith(b)
		nTests = nTests+1
	end
	testCollision(nTests, a, b, step, res)
	a.object:setPos(recentGood)
end

function onCollide(dt, objA, objB)

	--print(objA.object:getCategory() .. " " .. objA.object:getState(), objB.object:getCategory() .. " " .. objB.object:getState())
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
		objA.object:getCategory() ~= "trigger" and objB.object:getCategory() ~= "trigger" then resolveCollision(objA, objB, dt) end

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
	
	local slideThresh = 3 * scale;

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

theCollider = collider(100, onCollide)
