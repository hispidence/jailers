-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- gameManager.lua
--
-- Uses global variables from main.lua even though it doesn't actually INCLUDE
-- main.lua WHAT THE HELL.
-------------------------------------------------------------------------------



require("src/jlEvent")

local ston = nil

gameManager = {}

gameManager.__index = gameManager
--[[MAKE INTO A SINGLETON!!!]]--
setmetatable(gameManager,
		{__call = function(cls, ...)
			return cls.new(...)
		end})

function gameManager.new()
	local self = setmetatable({}, gameManager)
	self:init()
	return self
end

function gameManager:init()
	self.events = {}
	self.currentLevel = 0
	self.numLevels = 0
	self.playerLives = 0
	self.gameState = "running"
	self.slowed	   = false		-- are we slowed down?
	self.slowTimeTotal 	    = 0
	self.slowTimeElapsed    = 0			-- for how long are we slowed?
	self.speedUpPoint		= 0.25		-- when should we start speeding up?
	self.slowFactorInitial = 0.2		-- how slow are we?
	self.slowFactorCurrent = 1
	self.deathTimer = 1.2
	
  self.fadeTimer = 1.2
 	self.fadeInTimer = 0
  self.fadeInMax = 0.4

	self.hasPad = false
	self.pad = nil

	self.currX = 0
	self.currY = 0
	self.toX = 0
	self.toY = 0
	self.cameraTime = 0
	self.elapsed = 0
	self.moving = false
  self.lastCamera = nil

	self.storedPlayerPos = vector(0, 0)
	self.storedFloorsPos = {}
	self.storedEnemiesPos = {}
	self.storedEnemiesState = {}
	self.storedMoversPos = {}
	self.storedMoversState = {}
	self.storedMoversDir = {}
	self.storedMoversDist = {}
	self.storedTranslateX = 0 
	self.storedTranslateY = 0

	self.storedMoversCurrentExtent = {}
	self.storedMoversOtherExtent = {}
	self.storedWallsPos = {}
	self.storedWallsState = {}
	self.storedGunsPos = {}
	self.storedGunsState = {}
	self.storedGunsBulletsMade = {}
	self.storedGunsBulletsState = {}
	self.storedGunsBulletsPos = {}
	self.storedGunsAges = {}

  self.padMapping = {}
--	==self.stored
end

function gameManager:getButtons()
	local buttons = {}
	for i = 0, self.pad:getButtonCount() do
		buttons[i] = self.pad:isDown(i)
	end
	return buttons
end

function gameManager:getMapping(button)
  return self.padMapping[button]
end

function gameManager:checkForPad()
	if love.joystick.getJoystickCount() > 0 then
		if self.hasPad then return end
		local pads = love.joystick.getJoysticks()
		self.pad = pads[1]
		local padID = self.pad:getGUID()
		_, self.padMapping["leftx"] = self.pad:getGamepadMapping("leftx")
		_, self.padMapping["lefty"] = self.pad:getGamepadMapping("lefty")
		_, self.padMapping["rightx"] = self.pad:getGamepadMapping("rightx")
		_, self.padMapping["righty"] = self.pad:getGamepadMapping("righty")		
		
		_, self.padMapping["b"] = self.pad:getGamepadMapping("b");
		_, self.padMapping["back"] = self.pad:getGamepadMapping("back");
		self.hasPad = true
	else
		self.pad = nil
		self.hasPad = false
	end
end

function gameManager:getLeftStickAxes()
	if self.hasPad then	return self.pad:getAxis(self.padMapping["leftx"]), self.pad:getAxis(self.padMapping["lefty"]) else return 0, 0 end
end

function gameManager:getRightStickAxes()
	if self.hasPad then	return self.pad:getAxis(self.padMapping["rightx"]), self.pad:getAxis(self.padMapping["righty"]) else return 0, 0 end
end

function gameManager:getBandedAxes(upStages, downStages)
	x, y = self:getLeftStickAxes()
	x2, y2 = self:getRightStickAxes()
	local bx, by = x, y

	x = math.abs(x) > math.abs(x2) and x or x2
	y = math.abs(y) > math.abs(y2) and y or y2

	for _, s in ipairs(downStages) do
		if x <= s then bx = s end
		if y <= s then by = s end
	end
	
	for _, s in ipairs(upStages) do
		if x >= s then bx = s end
		if y >= s then by = s end
	end
	return bx, by
end

function gameManager:moveCameraGradual(dt)
	if not self.moving then return end
	self.elapsed = self.elapsed + dt
	local extent = self.elapsed/self.cameraTime
	if self.elapsed < self.cameraTime then
		self.currX = self.currX + extent * (self.toX - self.currX)
		self.currY = self.currY + extent * (self.toY - self.currY)
	else
		self.currX = self.toX
		self.currY = self.toY
		self.moving = false
		self.elapsed = 0
	end 

end



function gameManager:moveCamera(camName, toX, toY, time)
	if camName ~= self.lastCamera then
    self.toX = toX
    self.toY = toY
    self.cameraTime = time
    self.elapsed = 0
    self.moving = true
    self.lastCamera = camName
  end
end

function gameManager:getCurrX()
	return self.currX
end

function gameManager:getCurrY()
	return self.currY
end

function gameManager:setCurrX(x)
	self.currX = x
end

function gameManager:setCurrY(y)
	self.currY = y
end

function gameManager:setToX(x)
	self.toX = x
end

function gameManager:setToY(y)
	self.toY = y
end

function gameManager:getFadeInMax()
  return self.fadeInMax
end



-------------------------------------------------------------------------------
-- startSlowing
--
-- Slow the action down; start modifying DT
--
--	Arguments:
--		slowFactor:	float between 0 and 1; the amount we should slow down by.
--		For example, a factor of 0.5 would cause the action to run at half
--		speed.
--
--		totalSlowTime: float; how long, in seconds, should the action be slowed?
--
--		speedUpPoint: float; How much time must have elapsed before we begin
--		to speed the game up back to normal? For example, a speedUpPoint of
--		0.5 with a totalSlowTime of 2 will cause time to begin to go back to
--		normal after 1 second.
-------------------------------------------------------------------------------
function gameManager:startSlowing(slowFactor, totalSlowTime, speedUpPoint)
	self.slowed = true
	self.slowFactorInitial = slowFactor
	self.slowFactorCurrent = slowFactor
	self.slowTimeTotal = totalSlowTime
	self.slowTimeElapsed = 0
	self.speedUpPoint = speedUpPoint
end



-------------------------------------------------------------------------------
-- getModifiedDT
--
-- Does what it says on the tin. (self.slowFactorCurrent is 1 if action isn't
-- being slowed down).
-------------------------------------------------------------------------------
function gameManager:getModifiedDT(dt)
	return dt * self.slowFactorCurrent
end



-------------------------------------------------------------------------------
-- update
--
-- Update gamestate timers with (unmodified!) dt. This lovely function controls
-- things like slowdown and the fade effect that happens when you die or finish
-- a level
-------------------------------------------------------------------------------
function gameManager:update(dt)
	self:checkForPad()
	if self.gameState == "running" then
    self.fadeInTimer = self.fadeInTimer + dt
    self.fadeInTimer = math.min(self.fadeInTimer, self.fadeInMax)
	end
  if self.gameState == "finishinglevel" then
		if self.fadeTimer > 0 then
			self.fadeTimer = self.fadeTimer - dt
		else
			self.gameState = "loading"
		end
	end
	if self.gameState == "finishinggame" then
		if self.fadeTimer > 0 then
			self.fadeTimer = self.fadeTimer - dt
		else
			self.gameState = "endsplash"
		end
	end
	if self.gameState == "dead" then
		if self.deathTimer > 0 then
			self.deathTimer = self.deathTimer - dt
		else
			self:loadState()
		end
	end
	if self.moving then
		self:moveCameraGradual(dt)
	end
	
	if self.slowed then
		self.slowTimeElapsed = self.slowTimeElapsed + dt
		local speedUpSeconds = self.slowTimeTotal * self.speedUpPoint
		if self.slowTimeElapsed > self.slowTimeTotal then
			self.slowFactorCurrent = 1
			self.slowed = false
		else
			if self.slowTimeElapsed > speedUpSeconds then
				-- How long will it take us to fully speed up back to normal?
				local totalSpeedUpTime = self.slowTimeTotal - speedUpSeconds
				-- how far are we into the speedup period?
				local difference = self.slowTimeElapsed - speedUpSeconds
				local progress = difference / totalSpeedUpTime
				self.slowFactorCurrent = self.slowFactorInitial +
					(1 - self.slowFactorInitial) * progress
			end
		end
	end
end

function gameManager:getDeathTimer()
	return math.min(self.deathTimer, 1)
end

function gameManager:getFadeTimer()
  return math.min(self.fadeTimer, 1)
end

function gameManager:getFadeInTimer()
  return self.fadeInTimer
end

function gameManager:saveState()
--	self.storedPlayerPos = g_thePlayer:getPos():clone()
--	self.storedTranslateX = self.toX
--	self.storedTranslateY = self.toY

--	for i, v in ipairs(g_entityEnemies) do
--		self.storedEnemiesPos[i] = v:getPos():clone()
--		self.storedEnemiesState[i] = v:getState()
--	end
--	for i, v in ipairs(g_entityMovers) do
--		self.storedMoversPos[i] = v:getPos():clone()
--		self.storedMoversState[i] = v:getState()
--		self.storedMoversDir[i] = v:getDir():clone()
--		self.storedMoversDist[i] = v:getDist()
--		self.storedMoversCurrentExtent[i] = v:getCurrentExtent()
--		self.storedMoversOtherExtent[i] = v:getOtherExtent()
--	end
--	for i, v in ipairs(g_entityBlocks) do
--		self.storedWallsPos[i] = v:getPos():clone()
--		self.storedWallsState[i] = v:getState()
--	end
--	for i, v in ipairs(g_entityGuns) do
--		self.storedGunsPos[i] = v:getPos():clone()
--		self.storedGunsState[i] = v:getState()
--		self.storedGunsBulletsMade[i] = v:getBulletsMade()
--	end
end


function gameManager:loadState()
	self:setState("running")
	self.deathTimer = 1.2
	self.fadeTimer = 1.2
	self.fadeInTimer = 0.0
	self.slowed = false
	self.slowFactorCurrent = 1
	g_thePlayer:setState("resting")
	g_thePlayer:resetAnim("dead")
	g_thePlayer:resetSounds()	
	g_thePlayer:setPos(self.storedPlayerPos:clone())
	self.currX = self.storedTranslateX
	self.currY = self.storedTranslateY
	self.toX = self.storedTranslateX
	self.toY = self.storedTranslateY
  self.lastCamera = nil
	
	self.moving = false
	for i, v in ipairs(g_entityScenery) do
		v:setPos(self.storedFloorsPos[i]:clone())
	end
	for i, v in ipairs(g_entityEnemies) do
		v:setPos(self.storedEnemiesPos[i]:clone())
		v:setState(self.storedEnemiesState[i])
		if v.resetBehaviour then v:resetBehaviour() end
		--if v:getState() ~= "dead" then v:resetAnim("dead") end
		v:copyPath(nil)
		if v:getState() ~= "dead" then
			v:resetAnims()--("dead")
			v:resetSounds()	
		end
		v:setPathTimer(1.1)
		--v:setFlatMap(nil)
	end
	for i, v in ipairs(g_entityMovers) do
		v:setPos(self.storedMoversPos[i]:clone())
		v:setState(self.storedMoversState[i])
		v:setDir(self.storedMoversDir[i]:clone())
		v:setDist(self.storedMoversDist[i])
		v:setCurrentExtent(self.storedMoversCurrentExtent[i])
		v:setOtherExtent(self.storedMoversOtherExtent[i])
	end
	for i, v in ipairs(g_entityBlocks) do
		v:setPos(self.storedWallsPos[i]:clone())
		v:setState(self.storedWallsState[i])
		if v:getState() ~= "off" then
			v:resetSounds()
		end
		if v:getState() ~= "dead" then youShallNotPass(pathMap, v:getPos(), v:getSize()) end
	end

	for i, v in ipairs(g_entityGuns) do
		v:setPos(self.storedGunsPos[i]:clone())
		v:setState(self.storedGunsState[i])
		v:setBulletsMade(self.storedGunsBulletsMade[i])
		v:resetFiringBehaviour()
		v:killBullets()
		v:resetTimeLastBullet()
		v:resetSounds()
		if v:getState() ~= "dead" and v:getInvisible() == false then youShallNotPass(pathMap, v:getPos(), v:getSize()) end
	end
end
	--	end

function gameManager:unload()
	self.events = {}
	self.deathTimer = 1.2
	self.fadeTimer = 1.2
	self.fadeInTimer = 0
	self.currX = 0
	self.currY = 0
	self.toX = 0
	self.toY = 0

	self.slowed = false
	self.slowFactorInitial = 0
	self.slowFactorCurrent = 1
	self.slowTimeTotal = 0
	self.slowTimeElapsed = 0
	self.speedUpPoint = 0

	self.moving = false

	self.storedPlayerPos = nil 
	
	self.storedTranslateX = {} 
	self.storedTranslateY = {}

	self.storedFloorsPos = {}

	self.storedEnemiesPos = {}
	self.storedEnemiesState = {}
	
	self.storedMoversPos = {} 
	self.storedMoversState = {}
	self.storedMoversDir = {}
	self.storedMoversDist = {}
	self.storedMoversCurrentExtent = {}
	self.storedMoversOtherExtent = {}

	self.storedWallsPos = {}
	self.storedWallsState = {}

	self.storedGunsPos = {} 
	self.storedGunsState = {}
	self.storedGunsBulletsMade = {}
end



-------------------------------------------------------------------------------
-- gameManager:targets
--
-- Factory for an iterator which traverses the event list for key 'a' (if it
-- exists) and returns the keys and values it finds.
-------------------------------------------------------------------------------
function gameManager:targets(a)
	local i = 0
  
	if self.events[a] then
    -- Set the index to the final element in the table. Note the "i = i - 1"
    -- in the iterator proper.
		i = #self.events[a] + 1
	end
  
  -- return the iterator itself
	return function()
		i = i - 1
		if self.events[a] and self.events[a][i] then
			return i, self.events[a][i]
		end
	end
  
end

function gameManager:setCurrentLevel(l)
	if l < self.numLevels or l > 0 then self.currentLevel = l end
end

function gameManager:getCurrentLevel()
	return self.currentLevel
end

function gameManager:setNextLevel(l)
	if self.currentLevel < self.numLevels then self.currentLevel = self.currentLevel + 1 end
end

function gameManager:setPrevLevel(l)
	if self.currentLevel > 0 then self.currentLevel = self.currentLevel - 1 end
end

function gameManager:setNumLevels(n)
	self.numLevels = n
end

function gameManager:getNumLevels()
	return self.numLevels
end

function gameManager:setState(s)
	self.gameState = s
end

function gameManager:getState()
	return self.gameState
end

function gameManager:sendEvent(e)
	if self.events[e:getTarget()] == nil then
		self.events[e:getTarget()] = {e}
	else
		self.events[e:getTarget()][#self.events[e:getTarget()] + 1] = e
	end
end

function gameManager:removeEvent(k, i) 
	table.remove(self.events[k], i)
end

function gameManager:showEvents()
	for i, v in pairs(self.events) do
			print(i, v)
			for g, j in ipairs(v) do
				print(g, j:getID())
			end
	end
end
  
  
function gameManager:pause()
	if self.gameState == "paused" then self.gameState = "running"
	elseif self.gameState == "running" then self.gameState = "paused"
	end
end


if ston == nil then
	ston = gameManager:new()
end

return ston
