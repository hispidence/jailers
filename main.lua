require("mover")
require("gun")
require("character")
require("uiData")
require("collider")
currentLevel = require "level1"
require("sounds")
require("textures")
require("AnAL")
require("astar_good")
require("flatten")
require("TEsound")
require("shaders")
gm = require("gameManager")


require("jlEvent")

local gui = require "Quickie"

debug = not debug
DEBUG_ENABLED = false
numbers = false

thePad = nil

PAD_BACK = 2
PAD_B = 1

nextLevel = "level2"
menuRefreshed = false
menuBGtex = nil 
blocks = {}
scenery = {}
movers = {}
enemies = {}
guns = {}
triggers = {}
fonts = {}

thePlayer = nil

local pathCount = 0

function buildMap(width, height)
	local map = {}
	for y = 1, height do
		map[y] = {}
		for x = 1, width do
			map[y][x] = {}
		end
	end
	return map
end

function youShallNotPass(theMap, wallPos, wallSize)
	local tempSize = vector(0,0)--wallSize:clone()
	local blockSize = currentLevel.levelAttribs.blockSize 
	local tablePosX, tablePosY
	while tempSize.y < wallSize.y do
		tempSize.x = 0
		while tempSize.x < wallSize.x do
			tablePosX = 1 + (wallPos.x + tempSize.x)/(blockSize)
			tablePosY = 1 + (wallPos.y + tempSize.y)/(blockSize)
			theMap[tablePosY][tablePosX].wall = true
			tempSize.x = tempSize.x + blockSize
		end
		tempSize.y = tempSize.y + blockSize
	end
end

function youCanPass(theMap, wallPos, wallSize)
	local tempSize = vector(0,0)
	local blockSize = currentLevel.levelAttribs.blockSize 
	local tablePosX, tablePosY
	while tempSize.y < wallSize.y do
		tempSize.x = 0
		while tempSize.x < wallSize.x do
			tablePosX = 1 + (wallPos.x + tempSize.x)/(blockSize)
			tablePosY = 1 + (wallPos.y + tempSize.y)/(blockSize)
			theMap[tablePosY][tablePosX].wall = false
			tempSize.x = tempSize.x + blockSize
		end
		tempSize.y = tempSize.y + blockSize
	end
end

function toWorldSpace(col, row, ww, wh)
	local x = (col - 1) * ww
	local y = (row - 1) * wh
	return x, y
end

function setupUI()
	menuBGtex = love.graphics.newImage(uiData.menuBackGround)
	
	fonts[3] = love.graphics.newFont("Prociono-Regular.ttf", 10 * scale)
	fonts[1] = love.graphics.newFont("Prociono-Regular.ttf", 20 * scale)
	fonts[4] = love.graphics.newFont("Prociono-Regular.ttf", 4 * scale)
	fonts[2] = love.graphics.newFont("Prociono-Regular.ttf", 25 * scale)
	love.graphics.setFont(fonts[1])
	gui.keyboard.disable()
	gui.group.default.size[1] = uiData.btnMenuWidth * scale;
	gui.group.default.size[2] = uiData.btnMenuHeight * scale;
	gui.group.default.spacing = 0

	gui.core.style.color.normal.bg = {0, 0, 0}
	gui.core.style.color.normal.fg = {140, 140, 140}
	gui.core.style.color.normal.border = {0, 0, 0}
	gui.core.style.color.hot.bg = {0, 0, 0}
	gui.core.style.color.hot.fg = {37, 184, 233}
	gui.core.style.color.hot.border = {0, 0, 0}
	gui.core.style.color.active.bg = {0, 0, 0}
	gui.core.style.color.active.fg = {255, 255, 255}
	gui.core.style.color.active.border = {0, 0, 0}
end

function loadResources()
	for _, v in ipairs(lSounds) do
		v.soundData = love.sound.newSoundData(v.fname)
	end

	for _, v in ipairs(rTextures) do
		v.data = love.graphics.newImage(v.fname)
	end
end

function unloadLevel()
	menuRefreshed = false
	gm:unload()

	pathMap = nil
  
	thePlayer:freeResources(theCollider)
	thePlayer = nil;

	for k, v in ipairs(blocks) do
		v:freeResources(theCollider)
		blocks[k] = nil	
	end	
--	blocks = {}
	
	for k, v in ipairs(scenery) do
		v:freeResources(theCollider)
		scenery[k] = nil
	end	
--	scenery = {}

	for k, v in ipairs(enemies) do
		v:freeResources(theCollider)
		enemies[k] = nil
	end
--	enemies = {}

	for k, v in ipairs(guns) do
		v:freeResources(theCollider)
		guns[k] = nil
	end
--	guns = {}

	for k, v in ipairs(movers) do
		v:freeResources(theCollider)
		movers[k] = nil
	end
---	movers = {}

	for k, v in ipairs(triggers) do
		v:freeResources(theCollider)
		triggers[k] = nil
	end
--	triggers = {}

end

function loadLevel()
  	gm:setCurrX(currentLevel.levelAttribs.initialCamera.x * currentLevel.levelAttribs.blockSize)
  	gm:setCurrY(currentLevel.levelAttribs.initialCamera.y * currentLevel.levelAttribs.blockSize)
  	gm:setToX(gm:getCurrX())
  	gm:setToY(gm:getCurrY())
	
	local levelWidth, levelHeight = currentLevel.levelAttribs.width, currentLevel.levelAttribs.height

	local blockSize = currentLevel.levelAttribs.blockSize
	pathMap = buildMap(levelWidth, levelHeight)	

	local pSize = vector(10, 10)
	
	thePlayer = character("player")
	thePlayer:setTexture("resting", love.graphics.newImage("/textures/playerrest.png"), false)
	thePlayer:setTexture("moving_vertical", love.graphics.newImage("/textures/playermoveup.png"),false)
	thePlayer:setTexture("moving_horizontal", love.graphics.newImage("/textures/playermove.png"),false)
	thePlayer:setTexture("dead", love.graphics.newImage("/textures/playerdeath.png"),false)
	thePlayer:setSize(pSize)
	thePlayer:setShapeOffsets(2, 2)
	local pPos = vector(currentLevel.levelAttribs.playerStart.x*blockSize, currentLevel.levelAttribs.playerStart.y*blockSize)

	thePlayer:setCollisionRectangle()	

	thePlayer:setID("player")
	thePlayer:setCategory("player")
	thePlayer:setState("resting")
	thePlayer:setPathBox()
	thePlayer:setSpeed(currentLevel.levelAttribs.playerSpeed)	
	
	local anim = newAnimation(thePlayer:getTexture("dead"), 14, 14, 0.08, 6)
	anim:setMode("once")
	thePlayer:setAnim("dead", anim)

	anim = newAnimation(thePlayer:getTexture("resting"), 14, 14, 0.15,4)
	thePlayer:setAnim("resting", anim)

	anim = newAnimation(thePlayer:getTexture("moving_horizontal"), 14, 14, 0.05, 12)
	thePlayer:setAnim("moving_horizontal", anim)

	anim = newAnimation(thePlayer:getTexture("moving_vertical"), 14, 14, 0.05, 12)
	thePlayer:setAnim("moving_vertical", anim)


	local sound = currentLevel.levelAttribs.playerSounds["dead"]
	thePlayer:setSound("dead", 
	lSounds[getSoundByID(sound.id)].soundData,
	 sound.repeating, 
	 sound.time)

	sound = currentLevel.levelAttribs.playerSounds["moving_horizontal"]
	thePlayer:setSound("moving_horizontal", 
	lSounds[getSoundByID(sound.id)].soundData,
	 sound.repeating, 
	 sound.time)

	sound = currentLevel.levelAttribs.playerSounds["moving_vertical"]
	thePlayer:setSound("moving_vertical", 
	lSounds[getSoundByID(sound.id)].soundData,
	 sound.repeating, 
	 sound.time)

	thePlayer:move(pPos)

	local g = 1
	for n, v in ipairs(currentLevel.guns) do
		guns[g] = gun()
	
		guns[g]:setInvisible(v.invisible)
	

		if not v.invisible then
		
			local size = vector(v.size.x*blockSize, v.size.y*blockSize)
			guns[g]:setSize(size)
			guns[g]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
			if v.shape == nil or v.shape == "quad" then
				guns[g]:setCollisionRectangle()
			else
				guns[g]:setCollisionCircle()
			end
			guns[g]:addToCollisionGroup("world")

			for s, t in pairs(v.texture) do
				guns[g]:setTexture(s, rTextures[getTextureByID(t)].data, true)
			end

			local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
	
			guns[g]:move(pos)


			guns[g]:setInvisible(false)
			youShallNotPass(pathMap, guns[g]:getPos(), guns[g]:getSize())
		else
			local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)

			guns[g]:move(pos)
		end
		if v.state ~= nil then guns[g]:setState(v.state) else guns[g]:setState("dormant") end
	
			
		guns[g]:setFiringBehaviour(v.shootingBehaviour)
		
		if v.id then 
			guns[g]:setID(v.id)
		else
			guns[g]:setID("gun")
		end
		guns[g]:setBulletOffset(v.bulletOffset * blockSize)
		guns[g]:setCategory("gun")

		for s, t in pairs(v.bulletTexture) do
			guns[g]:setBulletTexture(s, rTextures[getTextureByID(t)].data, false)
		end

		if v.sound then
			for i, t in pairs(v.sound) do
				guns[g]:setSound(i, 
				lSounds[getSoundByID(t.id)].soundData, 
				t.repeating, t.time)
			end
		end
	
		if v.ignoresBullets then guns[g]:setIgnoresBullets(true) end

		guns[g]:setBulletVel(v.bulletVel)
		guns[g]:setBulletLife(v.bulletLife)
		guns[g]:setBulletTime(v.bulletTime)
		g = g + 1
	end	

	local k = 1
	for n, v in ipairs(currentLevel.walls) do
		blocks[k] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		blocks[k]:setSize(size)
		if v.state ~= nil then blocks[k]:setState(v.state) else blocks[k]:setState("dormant") end
		blocks[k]:setCollisionBehaviour(v.behaviour)
		local qX, qY = 16, 16
		if v.imageSizeX and v.imageSizeY then qX = v.imageSizeX; qY = v.imageSizeY end
		blocks[k]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, qX, qY))
		if v.shape == nil or v.shape == "quad" then
			blocks[k]:setCollisionRectangle()
		else
			blocks[k]:setCollisionCircle()
		end
		
		if v.id then 
			blocks[k]:setID(v.id)
		else
			blocks[k]:setID("wall")
		end
		blocks[k]:setCategory("wall")
		blocks[k]:addToCollisionGroup("world")
		blocks[k]:move(pos)
		for s, t in pairs(v.texture) do
			blocks[k]:setTexture(s, rTextures[getTextureByID(t)].data, true)
		end



		if v.sound then
			for i, t in pairs(v.sound) do
				blocks[k]:setSound(i, 
				lSounds[getSoundByID(t.id)].soundData, 
				t.repeating, t.time)
			end
		end

		if v.ignoresBullets then blocks[k]:setIgnoresBullets(true) end
		youShallNotPass(pathMap, blocks[k]:getPos(), blocks[k]:getSize())
		k = k + 1
	end

	k = 1
	for n, v in ipairs(currentLevel.triggers) do
		triggers[k] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
		triggers[k]:setSize(size)
		if v.state ~= nil then triggers[k]:setState(v.state) else triggers[k]:setState("dormant") end
		triggers[k]:setCollisionBehaviour(v.behaviour)
		triggers[k]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		triggers[k]:setCollisionRectangle()
		
		if v.id then 
			triggers[k]:setID(v.id)
		else
			triggers[k]:setID("trigger")
		end
		triggers[k]:setCategory("trigger")
		triggers[k]:addToCollisionGroup("world")
		triggers[k]:move(pos)


		if v.ignoresBullets then triggers[k]:setIgnoresBullets(true) end

		k = k + 1
	end

	for n, v in ipairs(pathMap) do
		local s = "";
		for i, p in ipairs(v) do
			if pathMap[n][i].wall then s = s.."1" else s =s .."0" end
		end
	end

	local i = 1
	for n, v in ipairs(currentLevel.floors) do
		scenery[i] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		scenery[i]:setSize(size)
		scenery[i]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		scenery[i]:setCollisionRectangle()
		scenery[i]:addToCollisionGroup("world")
		theCollider:setGhost(scenery[i]:getCollisionShape())

		scenery[i]:move(pos)
		scenery[i]:setTexture("dormant", rTextures[getTextureByID(v.texture)].data, true)
		i = i + 1
	end
	
	local j = 1
	for n, v in ipairs(currentLevel.enemies) do
		enemies[j] = character("enemy")
		local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
		enemies[j]:setSize(vector(currentLevel.levelAttribs.enemySize, currentLevel.levelAttribs.enemySize))
		enemies[j]:setCollisionRectangle(14, 14)
		enemies[j]:setPathBox()

		if v.ignoresBullets then enemies[j]:setIgnoresBullets(true) end

		if v.behaviour then enemies[j]:setBehaviour(v.behaviour); enemies[j]:setBehaviourData(v.bData); enemies[j]:setResetBehaviour(v.resetBehaviour) end

		if v.id then 
			enemies[j]:setID(v.id)
		else
			enemies[j]:setID("character")
		end
		if v.category then
			enemies[j]:setCategory(v.category)
		end
		enemies[j]:move(pos)
		enemies[j]:setSpeed(v.speed)
		for s, t in pairs(v.texture) do
			enemies[j]:setTexture(s, rTextures[getTextureByID(t)].data, false)

		end
		for s, t in pairs(currentLevel.anims[v.category]) do
			local anim = newAnimation(enemies[j]:getTexture(s), t[1], t[2], t[3], t[4])
			enemies[j]:setAnim(s, anim)
			enemies[j]:setAnimMode(s, t[5])
		end
		enemies[j]:setState(v.state)
		enemies[j]:setPathTimer(1.1)
		enemies[j]:setDeathBehaviour(v.deathBehaviour)
		--enemies[j]:setTexture("dormant", rTextures[getTextureByID(v.texture["dormant"])].data, false)
		--enemies[j]:setTexture("attacking", rTextures[getTextureByID(v.texture["attacking"])].data, false)
		
		if v.sound then
			for k, t in pairs(v.sound) do
				enemies[j]:setSound(k, lSounds[getSoundByID(t.id)].soundData, t.repeating, t.time)
			end
		end

		enemies[j]:setState(v.state)

		j = j + 1
	end

	local m = 1
	for n, v in ipairs(currentLevel.movers) do
		movers[m] = mover()
		movers[m]:setState(v.status)
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		movers[m]:setSize(size)
		movers[m]:setCollisionBehaviour(v.behaviour)
		movers[m]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		if v.shape == nil or v.shape == "quad" then
			movers[m]:setCollisionRectangle()
		else
			movers[m]:setCollisionCircle()
		end

		if v.id then 
			movers[m]:setID(v.id)
		else
			movers[m]:setID("wall")
		end
		local dir = vector(0,0)

		movers[m]:setCategory(v.category)
		dir.x, dir.y = v.dir.x, v.dir.y
		movers[m]:setDir(dir)
		movers[m]:setSpeed(v.speed)
		local x1, x2 = vector(0, 0), vector(0, 0)
		x1.x, x1.y = v.moveExtents[1].x, v.moveExtents[1].y
		x2.x, x2.y = v.moveExtents[2].x, v.moveExtents[2].y

		movers[m]:setFirstExtent(x1)
		movers[m]:setSecondExtent(x2)	

		movers[m]:move(pos)
		movers[m]:calcExtent(blockSize)
		movers[m]:addToCollisionGroup("world")
		for s, t in pairs(v.texture) do
			movers[m]:setTexture(s, rTextures[getTextureByID(t)].data, true)
		end

		if v.sound then
			for k, t in pairs(v.sound) do
				movers[m]:setSound(k, lSounds[getSoundByID(t.id)].soundData, t.repeating, t.time)
			end
		end

		if v.ignoresBullets then movers[m]:setIgnoresBullets(true) end

		m = m + 1
	end
end

function love.load()
	love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale)
	gameLogo = love.graphics.newImage(rTextures[getTextureByID("gamelogo")].fname)
	love.window.setIcon(love.image.newImageData("/textures/meleejailer_red.png"))
	gm:setState("splash")
 	fadeShader = love.graphics.newShader(fadeShaderSource)
 	invisShader = love.graphics.newShader(invisShaderSource)
	love.graphics.setShader(fadeShader)
	setupUI()
	loadResources()
	loadLevel()
	gm:saveState()
end

function love.draw()
	if gm:getState() == "loading" or gm:getState() == "splash" or gm:getState() == "endsplash" then 
		love.graphics.setShader()
		if gm:getState() == "splash" then
			love.graphics.draw(gameLogo, love.graphics.getWidth()/2-(gameLogo:getWidth() * scale/2), love.graphics.getHeight()/4 - (gameLogo:getHeight()*scale/2), 0, scale, scale, 0, 0)
		end
		gui.core.draw()	
		return
	end
	love.graphics.setShader(fadeShader)
	fadeShader:send("fadeFactor", 1-(gm:getFadeInTimer()/gm:getFadeInMax()))
	love.graphics.translate(gm:getCurrX() * scale, gm:getCurrY() * scale)
	if gm:getState() == "dead" then
	   fadeShader:send("fadeTo", {0.0, 0.0, 0.0})
	   fadeShader:send("fadeFactor", 1-gm:getDeathTimer())
	elseif gm:getState() == "finishinglevel" or gm:getState() == "finishinggame" then
		gui.core.draw()	
	   fadeShader:send("fadeTo", {0.0, 0.0, 0.0})
	   fadeShader:send("fadeFactor", 1-gm:getFadeTimer())
	end
	--local alpha = 0 + ((gm:getDeathTimer()/1) * 255)
	--love.graphics.setDefaultFilter("nearest", "nearest")
	--love.graphics.setColor(255, 255, 255, alpha)
	for i, v in ipairs(scenery) do
		if(not debug) then scenery[i]:drawQuad(debug) end
	end
	for i, v in ipairs(blocks) do
		if blocks[i]:getState() ~= "dead" then
			blocks[i]:drawQuad(debug)
		end
	end
	
	thePlayer:draw(debug)
	
	for i, v in ipairs(triggers) do
		if v:getState() ~= "dead" and debug then
			v:getCollisionShape():draw("line")
		end
	end

	for i, v in ipairs(movers) do
		if v:getState() ~= "dead" then
			v:drawQuad(debug)
		end
	end
	
	for i, v in ipairs(guns) do
		v:draw(debug)
	end
	
	for i, v in ipairs(enemies) do
		enemies[i]:draw(debug)
	end

	for i, v in ipairs(guns) do
		v:draw(debug)
	end
	--
	love.graphics.setShader()
	if(numbers) then
		love.graphics.setColor(128, 128, 128)
		love.graphics.setFont(fonts[3])
		local xPos, yPos
		for i = 0, 60 do
			xPos = i * currentLevel.levelAttribs.blockSize * scale
			love.graphics.print(i, xPos, 0)
			love.graphics.line(xPos, 0, xPos, 1000)
		end
		for i = 0, 60 do
			yPos = i * currentLevel.levelAttribs.blockSize * scale
			love.graphics.print(i, 0, yPos)
			love.graphics.line(0, yPos, 1000, yPos)
		end
	end
	
	if gm:getState() == "paused" then
 		love.graphics.translate(-gm:getCurrX() * scale, -gm:getCurrY() * scale)
 		love.graphics.translate(0, 0)
		love.graphics.draw(menuBGtex, love.graphics.getWidth()/2-(menuBGtex:getWidth() * scale/2), love.graphics.getHeight()/2 - (menuBGtex:getHeight()*scale/2), 0, scale, scale, 0, 0)

		if not menuRefreshed then love.graphics.setShader(invisShader); menuRefreshed = true end
		gui.core.draw()		
	end
	love.graphics.setShader(fadeShader)
end


local playerInc = vector(0, 0)
local pIncX = vector(0, 0)
local pIncY = vector(0, 0)
local pPos = vector(0,0)

function getBlockByID(id)
	for i, v in ipairs(blocks) do
		if v:getID() == id then return i end
	end
	return 0
end

function processEvent(e)
	if e:getDesc() == "removeblock" then
		local i = getBlockByID(e:getSender())
		if i ~= 0 then
			youCanPass(pathMap, blocks[i]:getPos(), blocks[i]:getSize())
		end
	elseif e:getDesc() == "addblock" then
		local i = getBlockByID(e:getSender())
		if i ~= 0 then
			youShallNotPass(pathMap, blocks[i]:getPos(), blocks[i]:getSize())
		end
	elseif e:getID() == "movecamera" then
		gm:moveCamera(
				e:getData()[1].x*currentLevel.levelAttribs.blockSize,
				e:getData()[1].y*currentLevel.levelAttribs.blockSize,
				e:getData()[2])	
	elseif e:getID() == "endlevel" then
		nextLevel = e:getDesc();
    	gm:setState("finishinglevel");
	elseif e:getID() == "endgame" then
    	gm:setState("finishinggame");
	end
	if e:getID() == "save" then
		gm:saveState();
	end
end

function love.update(dt)
	if (not love.window.hasFocus())and gm:getState() ~= "paused" and gm:getState() ~= "splash" and gm:getState() ~= "endsplash" then return end
	dt = math.min(dt, 0.07)
	gm:update(dt)
  	if(gm:getState() == "finishinglevel") then return end
  	if(gm:getState() == "finishinggame") then return end
	if(gm:getState() == "loading") then 
		love.graphics.setFont(fonts[1])
			gui.group.push{grow = "down", pos = {love.graphics.getWidth()/2 - uiData.btnMenuWidth/2, love.graphics.getHeight()/2 - uiData.btnMenuHeight*0.75}}
			gui.Label{size = {"tight", "tight"}, text = "Loading..."}
      unloadLevel()
      currentLevel = nil
      gm:unload()
      currentLevel = require(nextLevel)
      loadLevel()
      gm:saveState()
      gm:setState("running")
		return
	end

	if gm:getState() == "splash" then
		love.graphics.setFont(fonts[1])
		gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - uiData.btnMenuWidth), (love.graphics.getHeight()/2 - uiData.btnMenuHeight*0.5)}, spacing = scale/2}
		if gui.Button{size = {"tight", "tight"}, id = "btn_start", text = "Press space or push any button to begin"} then gm:setState("running") end		
		
		love.graphics.setFont(fonts[3])
    gui.Label{size = {"tight", "tight"}, pos= {1, 200}, text="Copyright (C) Brad Ellis"}

		return
	elseif gm:getState() == "endsplash" then
		love.graphics.setFont(fonts[1])
		gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/3 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/3 - (scale * 0.5 * uiData.btnMenuHeight)*3)},}
		gui.Label{size = {"tight", "tight"}, text="THE END"}
		love.graphics.setFont(fonts[3])
		gui.Label{size = {"tight", "tight"}, text="You've escaped!\n\n" ..
						"Or perhaps you haven't. Perhaps the polished-wood door at the end of the tunnel only\n"
						.. "looks familiar because you remember the chamber beyond. You've been there before.\n"
						.. "There'll be nothing there. No exits, no weak bricks, no loose floorboards. And you'll\n"
						.. "turn around to go back the way you came, but that polished-wood door won't be there\n"
						.. "any longer. And you'll be left there, left with nothing but the sense of satisfaction\n"
						.. "at having avoided the jailers - and let's not forget all those bullets you dodged.\n\n"
						.. "Hold tightly onto this feeling, because before long the whole thing will start to feel\n"
						.. "like a distant dream. \n\n"
						.. "Perhaps this whole experience has been a metaphor; but if it is, you can't think of\n"
						.. "what it might represent.\n\n"
						.. "...\n\n"
						.. "(I'm just being dramatic. You've escaped. Give yourself a pat on the back and make\n"
						.. "yourself a cup of tea.)\n\n\n"
						.. "blah blah Jailers blah blah Brad Ellis\n".. "blah blah Lua blah blah LÖVE blah etc.\n"
						.. "See the readme for actual details. Thanks for playing."}	
		return
	elseif gm:getState() == "paused" then 
	fonts[3] = love.graphics.newFont("Prociono-Regular.ttf", 10 * scale)
	fonts[1] = love.graphics.newFont("Prociono-Regular.ttf", 17.5 * scale)
	fonts[4] = love.graphics.newFont("Prociono-Regular.ttf", 4 * scale)
	fonts[2] = love.graphics.newFont("Prociono-Regular.ttf", 25 * scale)
		gui.group.default.spacing = scale	
		love.graphics.setFont(fonts[1])
		if uiData.menuState == "paused" then
			gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			if gui.Button{size = {"tight", "tight"}, id = "btn_resume", text = "Back to Game (P)"} then uiData.menuState = "resume" end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_settings", text = "Settings (S)"} then uiData.menuState = "settings" end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_levels", text = "Level Select (L)"} then uiData.menuState = "levels" end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_about", text = "About Jailers (J)"} then uiData.menuState = "about" end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_quit", text = "Quit (Q)"} then uiData.menuState = "exit" end
		elseif uiData.menuState == "settings" then
			gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			gui.Label{size = {"tight", "tight"}, text="Set Graphical Scale"}
			if gui.Button{size = {"tight", "tight"}, id = "btn_1", text = "1 (key 1)"} then scale = 1; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end
			if gui.Button{size = {"tight", "tight"}, id = "btn_1p5", text = "1.5 (key 2)"} then scale = 1.5; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_2", text = "2 (key 3) - default"} then scale = 2; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale)  end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_2p5", text = "2.5 (key 4)"} then scale = 2.5; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
		elseif uiData.menuState == "exit" then
			gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			gui.Label{size = {"tight", "tight"}, text="Are you sure?"}
			gui.group.push{grow = "right", pos = {0, (scale * 0.5 * uiData.btnMenuHeight/2)}}
			if gui.Button{size = {"tight", "tight"}, text = "", size = {[1] = 1, [2] = 1}} then end	
			if gui.Button{size = {"tight", "tight"}, text = "Yes (Y)", size = {[1] = scale * 0.5 * uiData.btnMenuWidth/2, [2] = scale * 0.5 * uiData.btnMenuHeight}} then love.event.push("quit") end	
			if gui.Button{size = {"tight", "tight"}, text = "No (N)",  size = {[1] = scale * 0.5 * uiData.btnMenuWidth/2, [2] = scale * 0.5 * uiData.btnMenuHeight}} then uiData.menuState="paused" end	
		elseif uiData.menuState == "levels" then
			gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			gui.Label{size = {"tight", "tight"}, text="Choose a level"}
			if gui.Button{size = {"tight", "tight"}, text = "", size = {[1] = 1, [2] = 1}} then end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_settings", text = "Library I (1)"} then nextLevel = "level1"; gm:setState("finishinglevel") end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_levels", text = "Library II (2)"} then  nextLevel = "level2"; gm:setState("finishinglevel") end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_about", text = "Depths I (3)"} then nextLevel = "level3"; gm:setState("finishinglevel") end	
			if gui.Button{size = {"tight", "tight"}, id = "btn_quit", text = "Depths II (4)"} then  nextLevel = "level4"; gm:setState("finishinglevel") end
		elseif uiData.menuState == "about" then
			love.graphics.setFont(fonts[3])
			gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/3)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2)},}

			gui.Label{size = {"tight", "tight"}, text="Oh dear! You've only gone and trapped yourself\n" .. "in your own interdimensional prison.\n"
							.. "Avoid your traps and your jailers. After all,\n" .. "you're just another prisoner to them. \n\n"
							.. "Jailers was made by Brad Ellis.\n".. "It uses Lua and the awesome LÖVE engine.\n"
							.. "For acknoledgements and more, see the readme.\n" }
		elseif uiData.menuState == "resume" then gm:pause() end

	return end

	for i, e in gm:targets("player") do
		thePlayer:processEvent(e)
		gm:removeEvent("player", i)
	end


	for i, e in gm:targets("main") do
		if e:getTimer() == nil or e:getTimer() <= 0 then
			processEvent(e)
			gm:removeEvent("main", i)
		end
	end

	for _, v in ipairs(triggers) do
		for i, e in gm:targets(v:getID()) do
			if e:getTimer() == nil or e:getTimer() <= 0 then
				result = v:processEvent(e)
				gm:removeEvent(v:getID(), i)
			end
		end
	end

	for _, v in ipairs(enemies) do
		for i, e in gm:targets(v:getID()) do
			if e:getTimer() == nil or e:getTimer() <= 0 then
				result = v:processEvent(e)
				gm:removeEvent(v:getID(), i)
			end
		end
	end
	
	for _, v in ipairs(blocks) do
		for i, e in gm:targets(v:getID()) do
			if e:getTimer() == nil or e:getTimer() <= 0 then
				result = v:processEvent(e)
				gm:removeEvent(v:getID(), i)
			elseif e:getTimer() > 0 then
				e:setTimer(e:getTimer()-dt)
			end
		end
	end

	for _, v in ipairs(movers) do
		for i, e in gm:targets(v:getID()) do
			if e:getTimer() == nil or e:getTimer() <= 0 then
				result = v:processEvent(e)
				gm:removeEvent(v:getID(), i)
			elseif e:getTimer() > 0 then
				e:setTimer(e:getTimer()-dt)
			end
		end
	end
	
	for _, v in ipairs(guns) do
		for i, e in gm:targets(v:getID()) do
			if e:getTimer() == nil or e:getTimer() <= 0 then
				result = v:processEvent(e)
				gm:removeEvent(v:getID(), i)
			elseif e:getTimer() > 0 then
				e:setTimer(e:getTimer()-dt)
			end
		end
	end

	for i, e in gm:targets("mainwait") do
		if e:getTimer() == nil or e:getTimer() <= 0 then
			processEvent(e)
			gm:removeEvent("mainwait", i)
		end
	end
	--Prepare to move player

	downStages = {0, -0.3, -0.6, -0.9}
	upStages = {0, 0.3, 0.6, 0.9}
	local stickX, stickY = gm:getBandedAxes(upStages, downStages)
	playerInc.x, playerInc.y = 0, 0
	if thePlayer:getState() ~= "dead" then
		
		if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
			playerInc.y = -0.9
		elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
			playerInc.y = 0.9
		else
			playerInc.y = stickY
		end

		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			playerInc.x = -0.9
		elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
			playerInc.x = 0.9
		else
			playerInc.x = stickX
		end
	end

	if math.abs(playerInc.x) > 0.8 and math.abs(playerInc.y) > 0.8 then
		if playerInc.x < 0 then playerInc.x = -0.6 end
		if playerInc.y < 0 then playerInc.y = -0.6 end

		if playerInc.x > 0 then playerInc.x = 0.6 end
		if playerInc.y > 0 then playerInc.y = 0.6 end
	end

	if thePlayer:getState() ~= "dead" and thePlayer:getState() ~= "stopped" then
		if playerInc.x == 0 and playerInc.y == 0 then thePlayer:setState("resting")
			elseif math.abs(playerInc.x) > math.abs(playerInc.y) then
				thePlayer:setState("moving_horizontal")
			else
				thePlayer:setState("moving_vertical")
			end
	end
--		playerInc = playerInc:normalized()
		playerInc = playerInc * dt * thePlayer:getSpeed()
		pIncX.x = playerInc.x
		pIncY.y = playerInc.y

    thePlayer:setDir(vector(pIncX.x, pIncY.y))
	--Prepare to move enemy
	for i,v in ipairs(enemies) do
		if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
			local moveVec = v:getMoveVec()
			local enemyPos = v:getPos()
			v:pathCollision(currentLevel.levelAttribs.blockSize)
			local target = v:getTarget()
			local size = v:getSize()
			moveVec.x = target.x - (enemyPos.x + (size.x/2))
			moveVec.y = target.y - (enemyPos.y + (size.y/2))
		
			moveVec = moveVec:normalized()
			moveVec = dt * v:getSpeed() * moveVec
			
			v:setMoveVec(moveVec)	
		end
	end		

	thePlayer:updateAnim(dt)

	thePlayer:updateSound(dt)

	for i,v in ipairs(enemies) do
		v:update(dt)
		v:updateAnim(dt)
		v:updateSound(dt)
	end

	for i, v in ipairs(blocks) do
		v:updateSound(dt)
	end

	for i,v in ipairs(movers) do
		v:updateSound(dt)
	end

	for i,v in ipairs(guns) do
		v:updateSound(dt)
	end

	--Move player and enemy on X

	thePlayer:move(pIncX)
	
	for i,v in ipairs(enemies) do
		if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
			local moveVec = v:getMoveVec()
			local moveVecX = vector(moveVec.x, 0)
			v:move(moveVecX)
		end
	end
	theCollider:update(dt)
	

	--Move player and enemy on Y

	thePlayer:move(pIncY)
	
	for i,v in ipairs(enemies) do
		if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
			local moveVec = v:getMoveVec()
			local moveVecY = vector(0, moveVec.y)
			v:move(moveVecY)
		end
	end
	theCollider:update(dt)
	for i,v in ipairs(guns) do
		v:update(dt)
	end
	for i,v in ipairs(movers) do
		if v:getState() == "active" then v:update(dt) end
	end
	theCollider:update(dt)


	--PATHFINDING: prepare view rays

	thePlayer:getCentre(pPos)
	
	local rayStarts = {	vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0)	}
	local rayDirs = {	vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0),
						vector(0,0)	}

	thePlayer:getTopLeft(rayStarts[1])
	thePlayer:getTopRight(rayStarts[2])
	thePlayer:getBottomLeft(rayStarts[3])
	thePlayer:getBottomRight(rayStarts[4])

	for i,v in ipairs(enemies) do
		if v:getState() ~= "dead" and v:getState() ~= "dormant" then 
			v:getTopLeft(rayStarts[5])
			v:getTopRight(rayStarts[6])
			v:getBottomLeft(rayStarts[7])
			v:getBottomRight(rayStarts[8])
			for k, r in ipairs(rayDirs) do
				if k < 5 then
					r.x = rayStarts[k+4].x - rayStarts[k].x
					r.y = rayStarts[k+4].y - rayStarts[k].y
				else
					r.x = -rayDirs[k-4].x
					r.y = -rayDirs[k-4].y
				end
			end

			--Is there a direct line of sight to the player? If so forget the path and go straight there
			local readyToPath = false
			local directRoute = true
			for j,o in ipairs(blocks) do
				if o:getState() ~= "dead" then
					
					if o:collidesRays(rayStarts, rayDirs) then
							if v:getState() == "attacking_direct" then readyToPath = true end
							directRoute = false
							v:setState("attacking_path")
					end
				end
			end
			if directRoute then
				v:setState("attacking_direct")
				v:setTarget(pPos)
			end	
			v:incPathTimer(dt)
			
			--Enemy generates a new path if player goes or out of line of sight,
			--or if enemy is at end of current path or has been following it for more than 1 second
			if not readyToPath then readyToPath = v:testPathTimer(1) or v:isAtEndOfPath()  end	
			if readyToPath and v:getState() == "attacking_path" then
				local startX, startY = v:findNearest(currentLevel.levelAttribs.blockSize)
				local endX, endY = thePlayer:findNearest(currentLevel.levelAttribs.blockSize)
				local startPos = {r = startY, c = startX}
				local endPos = {r = endY, c = endX}

				v:setFlatMap(flattenMap(pathMap, endPos, v:getFlatMap()))
				v:setPath(startPathing(v:getFlatMap(),
							 	((startPos.r - 1) * currentLevel.levelAttribs.height) + startPos.c,
								((endPos.r - 1) * currentLevel.levelAttribs.height) + endPos.c))
				currentPath = v:getPath()
				
				v:startPath(currentLevel.levelAttribs.blockSize)
			end
		end
	end

	TEsound.cleanup()
end

function love.keypressed(key)
	if gm:getState() == "splash" then
	
		if key == " " then gm:setState("running") end
		if key == "return" then gm:setState("running") end
		if key == "q" then love.event.push("quit") end
		if key == "escape" then love.event.push("quit") end
		return
	end
	if gm:getState() == "paused" then
		if uiData.menuState == "paused" then
			if key == "q" then uiData.menuState = "exit" end
			if key == "l" then uiData.menuState = "levels" end
			if key == "s" then uiData.menuState = "settings" end
			if key == "j" then uiData.menuState = "about" end
	    if key == "escape" or key == "p" then gm:pause(); uiData.menuState = "paused" end
		elseif uiData.menuState == "exit" then
			if key == "y" then love.event.push("quit")--[[exit]] else uiData.menuState = "paused" end
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "levels" then
			if key == "1" then nextLevel = "level1" gm:setState("finishinglevel") end
			if key == "2" then nextLevel = "level2" gm:setState("finishinglevel") end
			if key == "3" then nextLevel = "level3" gm:setState("finishinglevel") end
			if key == "4" then nextLevel = "level4" gm:setState("finishinglevel") end
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "about" then
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "settings" then
			if key == "1" then scale = 1; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
			if key == "2" then scale = 1.5; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
			if key == "3" then scale = 2; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
			if key == "4" then scale = 2.5; love.window.setMode(40 * currentLevel.levelAttribs.blockSize * scale, 30 * currentLevel.levelAttribs.blockSize * scale) end	
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		end
	elseif gm:getState() == "running" then
		  if key == "escape" or key == "p" then gm:pause(); uiData.menuState = "paused" end
	end
	if DEBUG_ENABLED then
		if key == "`" then debug = not debug end
		if key == "m" then numbers = not numbers end
		if key == "f5" then gm:saveState() end
		if key == "f9" then gm:loadState() end
		if key == "f1" then
			if gm:getState() == "loading" then
				currentLevel = require "level1"
				loadLevel()
				gm:setState("running")
			else
			 	gm:setState("loading")
			end--unloadLevel() end
		end
	end
	
	end

function love.joystickpressed(joystick, button)	
	if gm:getState() == "paused" then
    if uiData.menuState == "paused" then
      gm:pause(); uiData.menuState = "paused"
    elseif uiData.menuState == "exit" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "levels" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "about" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "settings" then
      uiData.menuState = "paused"
    end
  elseif gm:getState() == "running" then
        gm:pause(); uiData.menuState = "paused"
  elseif gm:getState() == "splash" then
        gm:setState("running")
  end
end

function img_iter(img)
	local x, y = 0,0
	local w = img:getWidth()
	local h = img:getHeight()
	local pixel = {}
	return function()
		if x >= w then
			x = 0
			y = y + 1
		end
		if y >= h then
			return nil
		else
			pixel.r, pixel.g, pixel.b = img:getPixel(x,y)
			tx = x
			x = x + 1
			return tx, y, pixel
		end
	end
end
