-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- gameMain.lua
--
-- Gamestate, game loops, initialisation, 'n' that.
-------------------------------------------------------------------------------


local windowWidth = 0
local windowHeight = 0

require("src/entities/objectFauxFactory")
require("src/character")
require("src/uiData")
require("src/collider")
require("src/sounds")
require("src/textures")
require("src/shaders")
require("src/jlEvent")
require("src/utils")
require("src/levelFunctions")

require("src/external/AnAL")
require("src/external/TEsound")


local g_usingTiled = true

local sti
local tiledMap
if g_usingTiled then
sti = require("src/external/sti")
end



-------------------------------------------------------------------------------
-- Classes from Jumper 
-------------------------------------------------------------------------------
local Grid = require("src/external/jumper.grid")
local PathFinder = require("src/external/jumper.pathfinder")
local jumperGrid
local jumperFinder



-------------------------------------------------------------------------------
-- Set debugging variables
-------------------------------------------------------------------------------
local DEBUG_ENABLED = true
local g_showGrid = false
local g_showBoxes = false



-------------------------------------------------------------------------------
-- Set game manager, GUI, and gamestate variables 
-------------------------------------------------------------------------------
local g_gui = require("src/external/Quickie")
local g_gm = require("src/gameManager")
if g_usingTiled then
	local g_currentLevel = "tiledLevel"
else
	local g_currentLevel = nil
end
local g_nextLevel = "level2"
local g_menuRefreshed = false
local g_blockSize = 16
local g_config = nil
local g_pixelLocked = true
local FONT_PROCIONO_REGULAR = "resources/Prociono-Regular.ttf"



-------------------------------------------------------------------------------
-- Make variables to hold GUI resources 
-------------------------------------------------------------------------------
local g_menuBGtex = nil 
local g_fonts = {}



-------------------------------------------------------------------------------
-- Create tables to hold game entities 
-------------------------------------------------------------------------------
local g_entityWalls = {}
local g_entityBlocks = {}
local g_entityTriggers = {}
local g_cameras = {}
g_thePlayer = nil


-------------------------------------------------------------------------------
-- Build the map. 
-------------------------------------------------------------------------------
function buildMap(width, height)
	local map = {}
	for y = 1, height do
		map[y] = {}
		for x = 1, width do
			map[y][x] = 0
		end
	end
	return map
end

function youShallNotPass(theMap, wallPos, wallSize)
	local tempSize = vector(0,0)--wallSize:clone()
	local blockSize = g_currentLevel.levelAttribs.blockSize 
	local tablePosX, tablePosY
	while tempSize.y < wallSize.y do
		tempSize.x = 0
		while tempSize.x < wallSize.x do
			tablePosX = 1 + (wallPos.x + tempSize.x)/(blockSize)
			tablePosY = 1 + (wallPos.y + tempSize.y)/(blockSize)
			--theMap[tablePosY][tablePosX].wall = true
			theMap[tablePosY][tablePosX] = 1
			tempSize.x = tempSize.x + blockSize
		end
		tempSize.y = tempSize.y + blockSize
	end
end

function youCanPass(theMap, wallPos, wallSize)
	local tempSize = vector(0,0)
	local blockSize = g_currentLevel.levelAttribs.blockSize 
	local tablePosX, tablePosY
	while tempSize.y < wallSize.y do
		tempSize.x = 0
		while tempSize.x < wallSize.x do
			tablePosX = 1 + (wallPos.x + tempSize.x)/(blockSize)
			tablePosY = 1 + (wallPos.y + tempSize.y)/(blockSize)
			--theMap[tablePosY][tablePosX].wall = false
			theMap[tablePosY][tablePosX] = 0
			tempSize.x = tempSize.x + blockSize
		end
   		tempSize.y = tempSize.y + blockSize
	end
end



-------------------------------------------------------------------------------
-- toWorldSpace
--
-- Get world space coordinates of grid position
-------------------------------------------------------------------------------
function toWorldSpace(col, row, ww, wh)
	local x = (col - 1) * ww
	local y = (row - 1) * wh
	return x, y
end



-------------------------------------------------------------------------------
-- setupUI
--
-- Set menu texture and font sizes 
-------------------------------------------------------------------------------
function setupUI()
	g_menuBGtex = love.graphics.newImage(uiData.menuBackGround)
	g_fonts[1] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 20 * g_config.scale)
	g_fonts[2] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 25 * g_config.scale)
	g_fonts[3] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 10 * g_config.scale)
	g_fonts[4] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 4 * g_config.scale)
	love.graphics.setFont(g_fonts[1])
	g_gui.keyboard.disable()
	g_gui.group.default.size[1] = uiData.btnMenuWidth * g_config.scale
	g_gui.group.default.size[2] = uiData.btnMenuHeight * g_config.scale
	g_gui.group.default.spacing = 0

	g_gui.core.style.color.normal.bg = {0, 0, 0}
	g_gui.core.style.color.normal.fg = {140, 140, 140}
	g_gui.core.style.color.normal.border = {0, 0, 0}
	g_gui.core.style.color.hot.bg = {0, 0, 0}
	g_gui.core.style.color.hot.fg = {37, 184, 233}
	g_gui.core.style.color.hot.border = {0, 0, 0}
	g_gui.core.style.color.active.bg = {0, 0, 0}
	g_gui.core.style.color.active.fg = {255, 255, 255}
	g_gui.core.style.color.active.border = {0, 0, 0}
end



-------------------------------------------------------------------------------
-- loadResources
--
-- Load the sounds and textures
-------------------------------------------------------------------------------
function loadResources()
	for _, v in ipairs(lSounds) do
		v.soundData = love.sound.newSoundData(v.fname)
	end

	for _, v in ipairs(rTextures) do
		v.data = love.graphics.newImage(v.fname)
		v.data:setFilter("nearest")
	end
end



-------------------------------------------------------------------------------
-- unloadLevel
--
-- Clear all of the level's entities 
--
-- This needs to be looked over.
-------------------------------------------------------------------------------
function unloadLevel()
	g_menuRefreshed = false
	g_gm:unload()

	pathMap = nil
  
	g_thePlayer:freeResources(theCollider)
	g_thePlayer = nil

	for k, v in ipairs(g_entityBlocks) do
		v:freeResources(theCollider)
		g_entityBlocks[k] = nil	
	end
  
  for k, v in ipairs(g_entityWalls) do
		v:freeResources(theCollider)
		g_entityWalls[k] = nil	
	end	

	for k, v in ipairs(g_entityTriggers) do
		v:freeResources(theCollider)
		g_entityTriggers[k] = nil
	end
  
  for k, v in pairs(g_cameras) do
    g_cameras[k] = nil
  end
end



-------------------------------------------------------------------------------
-- registerBehaviours
--
-- Populate object behaviours.
-------------------------------------------------------------------------------
function registerBehaviours(object, prop)
  if prop.collision_behaviours then 
    local behaviourTable = jlSplit(prop.collision_behaviours)
    for k, v in ipairs(behaviourTable) do
      -- Does the level data contain the collision behaviour in question?
      if prop[v] then
        local b = jlSplitKV(prop[v])
        
        -- If the collision behaviour exists in the script, we can go ahead
        if g_collisionBehaviours[b["type"]] ~= nil then
          local args =  b
          args.timer = args.timer and tonumber(args.timer) or 0
          args["sender"] = object:getID()
          
          object:addCollisionBehaviour(
            g_collisionBehaviours[b["type"]](args)
          )
        else
          print("Warning! Collison behaviour tables " ..
            "hold no data for \"" .. v .. "\"")
        end
        
      else
        print("Warning! Object contains no behaviour for \"" .. 
          behaviourType .."\"")
      end
      
    end
  end
end



-------------------------------------------------------------------------------
-- addCamera
--
-- Add cameras to the g_cameras table.
--
-- A camera comprises only a position, a name, and a state.
-------------------------------------------------------------------------------
function addCamera(camera)
  local newCamera = gameObject()
  
  if not camera.name or "" == camera.name then
    camera.name = "nameless_camera_FIX_THIS_NOW_" .. camID
	end
  local theName = camera.name;
  
 
  
  newCamera:setID(theName)
  
  newCamera:setInvisible(true)
  local pos = vector(camera.x, camera.y)
  newCamera:move(pos)
  newCamera:setState("active")
  
  g_cameras[theName] = newCamera
end



-------------------------------------------------------------------------------
-- addEntityTrigger
--
-- Add triggers to the g_entityTriggers table.
-------------------------------------------------------------------------------
function addEntityTrigger(trig)
  local trigID = #g_entityTriggers + 1
  local theTrigger = gameObject()
  
  
  if trig.name and trig.name ~= "" then
		theTrigger:setID(trig.name)
	else
		print("Warning! A trigger has no name.")
    block.name = "nameless_trigger_FIX_THIS_NOW_" .. trigID
	end
  
  theTrigger:setCategory("trigger")
  theTrigger:setState("active")
  
  -- Happily, the data from tiled is already aligned to the game size
  local size = vector(trig.width, trig.height)
  theTrigger:setSize(size)
  theTrigger:setCollisionRectangle()
  
  registerBehaviours(theTrigger,
                     trig.properties)
  

  local pos = vector(trig.x, trig.y)
	pos.x = pos.x
	pos.y = pos.y
	theTrigger:move(pos)
  
  g_entityTriggers[trigID] = theTrigger
end



-------------------------------------------------------------------------------
-- addEntityWall
--
-- Add walls to the g_entityWalls table. 
-------------------------------------------------------------------------------
function addEntityWall(block, x, y)
	local blockID = #g_entityWalls+ 1
	local theBlock = gameObject()

	local size = vector(g_blockSize, g_blockSize)
	theBlock:setSize(size)
	
	theBlock:setCollisionRectangle()
	
	theBlock:setID("wall")
	
	theBlock:setCategory("wall")
	
	theBlock:addToCollisionGroup("world")

	local pos = vector(x * g_blockSize, y * g_blockSize)
	pos.x = pos.x - size.x
	pos.y = pos.y - size.y
	theBlock:move(pos)

  g_entityWalls[blockID] = theBlock
  
	--	if v.ignoresBullets then g_entityWalls[blockID]:setIgnoresBullets(true) end
	-- youShallNotPass(pathMap, g_entityWalls[blockID]:getPos(), g_entityWalls[blockID]:getSize())
end



-------------------------------------------------------------------------------
-- addEntityBlock
--
-- Add block-based objects (e.g. switches, doors) to the g_entityBlocks table. 
-------------------------------------------------------------------------------
function addEntityBlock(block)
	local blockID = #g_entityBlocks + 1
  
  local prop = block.properties
  
  if not block.name or "" == block.name then
    print("Warning! A block has no name.")
    block.name = "nameless_block_FIX_THIS_NOW_" .. blockID
	end

	if not block.type or "" == block.type then	
		print("Warning! Block \"" .. block.name .. "\" has no type.")
    block.type = "typeless"
	end

  local theBlock = buildByType(block.type)
  if not theBlock then
    print("Warning! Block \"" .. block.name .. "\" has an invalid type; " ..
      "reverting to gameObject")
    theBlock = gameObject()
  end
  theBlock:setID(block.name)
  theBlock:setCategory(block.type)

	

	local size = vector(g_blockSize, g_blockSize)
	theBlock:setSize(size)
	theBlock:setQuad(love.graphics.newQuad(0,
													0,
													size.x,
													size.y, 
													size.x,
													size.y))
	theBlock:setCollisionRectangle()
	
	
	
  -- Does the entity specify a textureset?
	if prop.textureset then

		local t = g_textureSets[prop.textureset]
    
    -- Does the textureset exist?
    if t then
      for state, tex in pairs(t) do
        
        --do the asked-for textures exist?
        if rTextures[tex] then
          theBlock:setTexture(state,
            rTextures[tex].data,
            true)
        else
          print("Warning! Texture \"" .. tex .. "\" does not exist " ..
            "in the table of textures")
        end
        
      end
    else
      print("Warning! Textureset \"" .. prop.textureset ..
        "\" doesn't exist.")
    end
    
	else
    print("Warning! Block \"" .. block.name .. "\" has no textureset.")
  end

  registerBehaviours(theBlock, prop)

	if prop.state and prop.state ~= "" then	
		theBlock:setState(prop.state)
	else
		theBlock:setState("dormant");
	end

	theBlock:addToCollisionGroup("world")

	local pos = vector(block.x, block.y)

	pos.y = pos.y - size.y;
	theBlock:move(pos)
  
  -- property assignment should not depend on anything other than the entity
  -- existing, but movers need to know their position beforehand for now
  theBlock:assignFromProperties(prop)
  
  g_entityBlocks[blockID] = theBlock
  
  local subObjects = theBlock:createSubObjects()
  
  if subObjects then
    for i, o in ipairs(subObjects) do
      g_entityBlocks[blockID + i] = o;
    end
  end
  
end



-------------------------------------------------------------------------------
-- loadLevel
--
--  
-------------------------------------------------------------------------------
function loadLevel()
  	if g_usingTiled then
		tiledMap = sti.new("src/tiledlevel.lua")

		tiledMap:setDrawRange(0, 0, windowWidth, windowHeight)

		world = love.physics.newWorld(0, 0)
	
	-- No entities from the "objects" layer get drawn through the STI Tiled
	-- library. Instead, we create entities based on them, and where draw
   -- those instead (where applicable).
	--
	-- Entities from the objects layer are put into one of the global tables
	-- defined above.
	tiledMap.layers["objects"].visible = false;

  local sLayer = tiledMap.layers["statics"];
  pathMap = buildMap(sLayer.width, sLayer.height)

	local pSize = vector(10, 10)
	local playerObj = tiledMap.objects["player"]
	local pPos = vector(playerObj.x, playerObj.y - g_blockSize)
	g_thePlayer = character("player")
	g_thePlayer:setTexture(	"resting",
				love.graphics.newImage(TEXTURES_DIR .. "playerrest.png"),
				false)
	g_thePlayer:setTexture(	"moving_vertical",
				love.graphics.newImage(TEXTURES_DIR .. "playermoveup.png"),
				false)
	g_thePlayer:setTexture(	"moving_horizontal",
				love.graphics.newImage(TEXTURES_DIR .. "playermove.png"),
				false)	
	g_thePlayer:setTexture(	"dead", 
				love.graphics.newImage(TEXTURES_DIR .. "playerdeath.png"),
				false)
	g_thePlayer:setSize(pSize)
	g_thePlayer:setShapeOffsets(2, 2)
	g_thePlayer:setCollisionRectangle()	
	g_thePlayer:setID("player")
	g_thePlayer:setCategory("player")
	g_thePlayer:setState("resting")
	g_thePlayer:setPathBox()
	g_thePlayer:setSpeed(g_currentLevel.levelAttribs.playerSpeed)	
	g_thePlayer:setPos(pPos)


	local anim = newAnimation(g_thePlayer:getTexture("dead"), 14, 14, 0.08, 6)
	anim:setMode("once")
	g_thePlayer:setAnim("dead", anim)

	anim = newAnimation(g_thePlayer:getTexture("resting"), 14, 14, 0.15,4)
	g_thePlayer:setAnim("resting", anim)

	anim = newAnimation(g_thePlayer:getTexture("moving_horizontal"), 14, 14, 0.05, 12)
	g_thePlayer:setAnim("moving_horizontal", anim)

	anim = newAnimation(g_thePlayer:getTexture("moving_vertical"), 14, 14, 0.05, 12)
	g_thePlayer:setAnim("moving_vertical", anim)


	local sound = g_currentLevel.levelAttribs.playerSounds["dead"]
	g_thePlayer:setSound(	"dead", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)

	sound = g_currentLevel.levelAttribs.playerSounds["moving_horizontal"]
	g_thePlayer:setSound(	"moving_horizontal", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)

	sound = g_currentLevel.levelAttribs.playerSounds["moving_vertical"]
	g_thePlayer:setSound(	"moving_vertical", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)


  -- Initialise walls
	for y, tile in ipairs(tiledMap.layers.statics.data) do
		for x, data in pairs(tile) do
			addEntityWall(data, x, y)	
		end
	end

	-- Initialise triggers
	for y, trig in ipairs(tiledMap.layers.triggers.objects) do
    addEntityTrigger(trig)	
	end

	-- Initialise cameras
	for y, cam in ipairs(tiledMap.layers.cameras.objects) do
    addCamera(cam)	
	end

	-- Initialise block-based objects
	for i, data in ipairs(tiledMap.layers.objects.objects) do
    --Skip if the entity is "special" (e.g. the player)
    if "special" ~= data.type then
      addEntityBlock(data)
    end
	end

	else	
	-- Initialise camera positions
	g_gm:setCurrX(g_currentLevel.levelAttribs.initialCamera.x * g_currentLevel.levelAttribs.blockSize)
  	g_gm:setCurrY(g_currentLevel.levelAttribs.initialCamera.y * g_currentLevel.levelAttribs.blockSize)
  	g_gm:setToX(g_gm:getCurrX())
  	g_gm:setToY(g_gm:getCurrY())
	
	local levelWidth, levelHeight = g_currentLevel.levelAttribs.width, g_currentLevel.levelAttribs.height

	local blockSize = g_currentLevel.levelAttribs.blockSize
	pathMap = buildMap(levelWidth, levelHeight)	

	local pSize = vector(10, 10)
	
	-- Create player and initialise resources
	g_thePlayer = character("player")
	g_thePlayer:setTexture(	"resting",
				love.graphics.newImage(TEXTURES_DIR .. "playerrest.png"),
				false)
	g_thePlayer:setTexture(	"moving_vertical",
				love.graphics.newImage(TEXTURES_DIR .. "playermoveup.png"),
				false)
	g_thePlayer:setTexture(	"moving_horizontal",
				love.graphics.newImage(TEXTURES_DIR .. "playermove.png"),
				false)	
	g_thePlayer:setTexture(	"dead", 
				love.graphics.newImage(TEXTURES_DIR .. "playerdeath.png"),
				false)
	g_thePlayer:setSize(pSize)
	g_thePlayer:setShapeOffsets(2, 2)
	g_thePlayer:setCollisionRectangle()	
	g_thePlayer:setID("player")
	g_thePlayer:setCategory("player")
	g_thePlayer:setState("resting")
	g_thePlayer:setPathBox()
	g_thePlayer:setSpeed(g_currentLevel.levelAttribs.playerSpeed)	
	
	local anim = newAnimation(g_thePlayer:getTexture("dead"), 14, 14, 0.08, 6)
	anim:setMode("once")
	g_thePlayer:setAnim("dead", anim)

	anim = newAnimation(g_thePlayer:getTexture("resting"), 14, 14, 0.15,4)
	g_thePlayer:setAnim("resting", anim)

	anim = newAnimation(g_thePlayer:getTexture("moving_horizontal"), 14, 14, 0.05, 12)
	g_thePlayer:setAnim("moving_horizontal", anim)

	anim = newAnimation(g_thePlayer:getTexture("moving_vertical"), 14, 14, 0.05, 12)
	g_thePlayer:setAnim("moving_vertical", anim)


	local sound = g_currentLevel.levelAttribs.playerSounds["dead"]
	g_thePlayer:setSound(	"dead", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)

	sound = g_currentLevel.levelAttribs.playerSounds["moving_horizontal"]
	g_thePlayer:setSound(	"moving_horizontal", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)

	sound = g_currentLevel.levelAttribs.playerSounds["moving_vertical"]
	g_thePlayer:setSound(	"moving_vertical", 
				lSounds[getSoundByID(sound.id)].soundData,
				sound.repeating, 
				sound.time)

	local pPos = vector(g_currentLevel.levelAttribs.playerStart.x*blockSize, g_currentLevel.levelAttribs.playerStart.y*blockSize)
	g_thePlayer:move(pPos)

	-- Initialise guns
	local g = 1
	for n, v in ipairs(g_currentLevel.guns) do
		g_entityGuns[g] = gun()
	
		g_entityGuns[g]:setInvisible(v.invisible)
	

		if not v.invisible then
		
			local size = vector(v.size.x*blockSize, v.size.y*blockSize)
			g_entityGuns[g]:setSize(size)
			g_entityGuns[g]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
			if nil == v.shape or "quad" == v.shape then
				g_entityGuns[g]:setCollisionRectangle()
			else
				g_entityGuns[g]:setCollisionCircle()
			end
			g_entityGuns[g]:addToCollisionGroup("world")

			for s, t in pairs(v.texture) do
				g_entityGuns[g]:setTexture(s, rTextures[getTextureByID(t)].data, true)
			end

			local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
	
			g_entityGuns[g]:move(pos)


			g_entityGuns[g]:setInvisible(false)
			youShallNotPass(pathMap, g_entityGuns[g]:getPos(), g_entityGuns[g]:getSize())
		else
			local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)

			g_entityGuns[g]:move(pos)
		end
		if nil ~= v.state then g_entityGuns[g]:setState(v.state) else g_entityGuns[g]:setState("dormant") end
	
			
		g_entityGuns[g]:setFiringBehaviour(v.shootingBehaviour)
		
		if v.id then 
			g_entityGuns[g]:setID(v.id)
		else
			g_entityGuns[g]:setID("gun")
		end
		g_entityGuns[g]:setBulletOffset(v.bulletOffset * blockSize)
		g_entityGuns[g]:setCategory("gun")

		for s, t in pairs(v.bulletTexture) do
			g_entityGuns[g]:setBulletTexture(s, rTextures[getTextureByID(t)].data, false)
		end

		if v.sound then
			for i, t in pairs(v.sound) do
				g_entityGuns[g]:setSound(i, 
				lSounds[getSoundByID(t.id)].soundData, 
				t.repeating, t.time)
			end
		end
	
		if v.ignoresBullets then g_entityGuns[g]:setIgnoresBullets(true) end

		g_entityGuns[g]:setBulletVel(v.bulletVel)
		g_entityGuns[g]:setBulletLife(v.bulletLife)
		g_entityGuns[g]:setBulletTime(v.bulletTime)
		g = g + 1
	end	

	-- Initialise walls
	local k = 1
	for n, v in ipairs(g_currentLevel.walls) do
		g_entityBlocks[k] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		g_entityBlocks[k]:setSize(size)
		if v.state ~= nil then g_entityBlocks[k]:setState(v.state) else g_entityBlocks[k]:setState("dormant") end
		g_entityBlocks[k]:setCollisionBehaviour(v.behaviour)
		local qX, qY = 16, 16
		if v.imageSizeX and v.imageSizeY then qX = v.imageSizeX; qY = v.imageSizeY end
		g_entityBlocks[k]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, qX, qY))
		if nil == v.shape or "quad" == v.shape then
			g_entityBlocks[k]:setCollisionRectangle()
		else
			g_entityBlocks[k]:setCollisionCircle()
		end
		
		if v.id then 
			g_entityBlocks[k]:setID(v.id)
		else
			g_entityBlocks[k]:setID("wall")
		end
		g_entityBlocks[k]:setCategory("wall")
		g_entityBlocks[k]:addToCollisionGroup("world")
		g_entityBlocks[k]:move(pos)
		for s, t in pairs(v.texture) do
			g_entityBlocks[k]:setTexture(s, rTextures[getTextureByID(t)].data, true)
		end


		if v.sound then
			for i, t in pairs(v.sound) do
				g_entityBlocks[k]:setSound(i, 
				lSounds[getSoundByID(t.id)].soundData, 
				t.repeating, t.time)
			end
		end

		if v.ignoresBullets then g_entityBlocks[k]:setIgnoresBullets(true) end
		youShallNotPass(pathMap, g_entityBlocks[k]:getPos(), g_entityBlocks[k]:getSize())
		k = k + 1
	end

	-- Initialise triggers
	k = 1
	for n, v in ipairs(g_currentLevel.triggers) do
		g_entityTriggers[k] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
		g_entityTriggers[k]:setSize(size)
		if v.state ~= nil then g_entityTriggers[k]:setState(v.state) else g_entityTriggers[k]:setState("dormant") end
		g_entityTriggers[k]:setCollisionBehaviour(v.behaviour)
		g_entityTriggers[k]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		g_entityTriggers[k]:setCollisionRectangle()
		
		if v.id then 
			g_entityTriggers[k]:setID(v.id)
		else
			g_entityTriggers[k]:setID("trigger")
		end
		g_entityTriggers[k]:setCategory("trigger")
		g_entityTriggers[k]:addToCollisionGroup("world")
		g_entityTriggers[k]:move(pos)


		if v.ignoresBullets then g_entityTriggers[k]:setIgnoresBullets(true) end

		k = k + 1
	end

	
	jumperGrid = Grid(pathMap)
	jumperFinder = PathFinder(jumperGrid, 'ASTAR', 0)
	jumperFinder:setMode("ORTHOGONAL")


	-- Initialise floors
	local i = 1
	for n, v in ipairs(g_currentLevel.floors) do
		g_entityScenery[i] = gameObject()
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		g_entityScenery[i]:setSize(size)
		g_entityScenery[i]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		g_entityScenery[i]:setCollisionRectangle()
		g_entityScenery[i]:addToCollisionGroup("world")
		theCollider:setGhost(g_entityScenery[i]:getCollisionShape())

		g_entityScenery[i]:move(pos)
		g_entityScenery[i]:setTexture("dormant", rTextures[getTextureByID(v.texture)].data, true)
		i = i + 1
	end
	
	-- Initialise enemies
	local j = 1
	for n, v in ipairs(g_currentLevel.enemies) do
		g_entityEnemies[j] = character("enemy")
		local pos = vector(v.pos.x*blockSize, v.pos.y*blockSize)
		g_entityEnemies[j]:setSize(vector(g_currentLevel.levelAttribs.enemySize, g_currentLevel.levelAttribs.enemySize))
		g_entityEnemies[j]:setCollisionRectangle(14, 14)
		g_entityEnemies[j]:setPathBox()

		if v.ignoresBullets then g_entityEnemies[j]:setIgnoresBullets(true) end

		if v.behaviour then g_entityEnemies[j]:setBehaviour(v.behaviour); g_entityEnemies[j]:setBehaviourData(v.bData); g_entityEnemies[j]:setResetBehaviour(v.resetBehaviour) end

		if v.id then 
			g_entityEnemies[j]:setID(v.id)
		else
			g_entityEnemies[j]:setID("character")
		end
		if v.category then
			g_entityEnemies[j]:setCategory(v.category)
		end
		g_entityEnemies[j]:move(pos)
		g_entityEnemies[j]:setSpeed(v.speed)
		for s, t in pairs(v.texture) do
			g_entityEnemies[j]:setTexture(s, rTextures[getTextureByID(t)].data, false)

		end
		for s, t in pairs(g_currentLevel.anims[v.category]) do
			local anim = newAnimation(g_entityEnemies[j]:getTexture(s), t[1], t[2], t[3], t[4])
			g_entityEnemies[j]:setAnim(s, anim)
			g_entityEnemies[j]:setAnimMode(s, t[5])
		end
		g_entityEnemies[j]:setState(v.state)
		g_entityEnemies[j]:setPathTimer(1.1)
		g_entityEnemies[j]:setDeathBehaviour(v.deathBehaviour)
		
		if v.sound then
			for k, t in pairs(v.sound) do
				g_entityEnemies[j]:setSound(k, lSounds[getSoundByID(t.id)].soundData, t.repeating, t.time)
			end
		end

		g_entityEnemies[j]:setState(v.state)

		j = j + 1
	end

	-- Initialise movers
	local m = 1
	for n, v in ipairs(g_currentLevel.movers) do
		g_entityMovers[m] = mover()
		g_entityMovers[m]:setState(v.status)
		local size = vector(v.size.x*blockSize, v.size.y*blockSize)
		local pos = vector(v.start.x*blockSize, v.start.y*blockSize)
		g_entityMovers[m]:setSize(size)
		g_entityMovers[m]:setCollisionBehaviour(v.behaviour)
		g_entityMovers[m]:setQuad(love.graphics.newQuad(0, 0, v.size.x*blockSize, v.size.y*blockSize, 16, 16))
		if nil == v.shape or "quad" == v.shape then
			g_entityMovers[m]:setCollisionRectangle()
		else
			g_entityMovers[m]:setCollisionCircle()
		end

		if v.id then 
			g_entityMovers[m]:setID(v.id)
		else
			g_entityMovers[m]:setID("wall")
		end
		local dir = vector(0,0)

		g_entityMovers[m]:setCategory(v.category)
		dir.x, dir.y = v.dir.x, v.dir.y
		g_entityMovers[m]:setDir(dir)
		g_entityMovers[m]:setSpeed(v.speed)
		local x1, x2 = vector(0, 0), vector(0, 0)
		x1.x, x1.y = v.moveExtents[1].x, v.moveExtents[1].y
		x2.x, x2.y = v.moveExtents[2].x, v.moveExtents[2].y

		g_entityMovers[m]:setFirstExtent(x1)
		g_entityMovers[m]:setSecondExtent(x2)	

		g_entityMovers[m]:move(pos)
		g_entityMovers[m]:calcExtent(blockSize)
		g_entityMovers[m]:addToCollisionGroup("world")
		for s, t in pairs(v.texture) do
			g_entityMovers[m]:setTexture(s, rTextures[getTextureByID(t)].data, true)
		end

		if v.sound then
			for k, t in pairs(v.sound) do
				g_entityMovers[m]:setSound(k, lSounds[getSoundByID(t.id)].soundData, t.repeating, t.time)
			end
		end

		if v.ignoresBullets then g_entityMovers[m]:setIgnoresBullets(true) end

		m = m + 1
	end
	end
end

-------------------------------------------------------------------------------
-- gameLoad
--
--  
-------------------------------------------------------------------------------
function gameLoad(levelFileName, config)
  g_currentLevel = require("src/" .. levelFileName)
  g_config = config
	love.window.setMode(g_config.widthInBlocks * g_currentLevel.levelAttribs.blockSize, g_config.heightInBlocks * g_currentLevel.levelAttribs.blockSize)
	windowWidth = love.window.getWidth()
	windowHeight = love.window.getHeight()
	gameLogo = love.graphics.newImage(rTextures[getTextureByID("gamelogo")].fname)
	love.window.setIcon(love.image.newImageData(TEXTURES_DIR .. "meleejailer_red.png"))
	g_gm:setState("splash")
 	fadeShader = love.graphics.newShader(fadeShaderSource)
 	invisShader = love.graphics.newShader(invisShaderSource)
	love.graphics.setShader(fadeShader)
	setupUI()
	loadResources()
	loadLevel()
	g_gm:saveState()
end



-------------------------------------------------------------------------------
-- gameDraw
--
--  
-------------------------------------------------------------------------------
function gameDraw()
  
  love.graphics.scale(g_config.scale, g_config.scale)
  
  -- Round the new position so it aligns with a pixel. I'm not convinced about
  -- this. I don't think it looks smooth.
  love.graphics.translate(jRound(-g_gm:getCurrX()), jRound(-g_gm:getCurrY()))
	if not g_showBoxes then
		tiledMap:draw()
	else
		for i, v in ipairs(g_entityWalls) do
			g_entityWalls[i]:drawQuad(g_showBoxes, g_pixelLocked)
		end
	end	

	g_thePlayer:draw(g_showBoxes, g_pixelLocked)

  local theState
	for i, v in ipairs(g_entityBlocks) do
    theState = g_entityBlocks[i]:getState()
		if theState ~= "dead" and not g_entityBlocks[i]:getInvisible() then
			g_entityBlocks[i]:drawQuad(g_showBoxes, g_pixelLocked)
		end
	end

if g_usingTiled then
  
else
	if g_gm:getState() == "loading" or g_gm:getState() == "splash" or g_gm:getState() == "endsplash" then 
		love.graphics.setShader()
		if g_gm:getState() == "splash" then
			love.graphics.draw(gameLogo, love.graphics.getWidth()/2-(gameLogo:getWidth() * scale/2), love.graphics.getHeight()/4 - (gameLogo:getHeight()*scale/2), 0, scale, scale, 0, 0)
		end
		g_gui.core.draw()	
		return
	end
	love.graphics.setShader(fadeShader)
	fadeShader:send("fadeFactor", 1-(g_gm:getFadeInTimer()/g_gm:getFadeInMax()))
	love.graphics.translate(g_gm:getCurrX() * scale, g_gm:getCurrY() * scale)
	if g_gm:getState() == "dead" then
	   fadeShader:send("fadeTo", {0.0, 0.0, 0.0})
	   fadeShader:send("fadeFactor", 1-g_gm:getDeathTimer())
	elseif g_gm:getState() == "finishinglevel" or g_gm:getState() == "finishinggame" then
		g_gui.core.draw()	
	   fadeShader:send("fadeTo", {0.0, 0.0, 0.0})
	   fadeShader:send("fadeFactor", 1-g_gm:getFadeTimer())
	end
	--local alpha = 0 + ((g_gm:getDeathTimer()/1) * 255)
	--love.graphics.setDefaultFilter("nearest", "nearest")
	--love.graphics.setColor(255, 255, 255, alpha)
	for i, v in ipairs(g_entityScenery) do
		if(not g_showBoxes) then g_entityScenery[i]:drawQuad(g_showBoxes) end
	end
	for i, v in ipairs(g_entityBlocks) do
		if g_entityBlocks[i]:getState() ~= "dead" then
			g_entityBlocks[i]:drawQuad(g_showBoxes)
		end
	end
	
	g_thePlayer:draw(g_showBoxes)
	
	for i, v in ipairs(g_entityTriggers) do
		if v:getState() ~= "dead" and g_showBoxes then
			v:getCollisionShape():draw("line")
		end
	end

	for i, v in ipairs(g_entityMovers) do
		if v:getState() ~= "dead" then
			v:drawQuad(g_showBoxes)
		end
	end
	
	for i, v in ipairs(g_entityGuns) do
		v:draw(g_showBoxes)
	end
	
	for i, v in ipairs(g_entityEnemies) do
		g_entityEnemies[i]:draw(g_showBoxes)
	end

	for i, v in ipairs(g_entityGuns) do
		v:draw(g_showBoxes)
	end
	--
	love.graphics.setShader()
	if(g_showGrid) then
		love.graphics.setColor(128, 128, 128)
		love.graphics.setFont(g_fonts[3])
		local xPos, yPos
		for i = 0, 60 do
			xPos = i * g_currentLevel.levelAttribs.blockSize * scale
			love.graphics.print(i, xPos, 0)
			love.graphics.line(xPos, 0, xPos, 1000)
		end
		for i = 0, 60 do
			yPos = i * g_currentLevel.levelAttribs.blockSize * scale
			love.graphics.print(i, 0, yPos)
			love.graphics.line(0, yPos, 1000, yPos)
		end
	end
	
	if "paused" == g_gm:getState()  then
 		love.graphics.translate(-g_gm:getCurrX() * scale, -g_gm:getCurrY() * scale)
 		love.graphics.translate(0, 0)
		love.graphics.draw(g_menuBGtex, love.graphics.getWidth()/2-(g_menuBGtex:getWidth() * scale/2), love.graphics.getHeight()/2 - (g_menuBGtex:getHeight()*scale/2), 0, scale, scale, 0, 0)

		if not g_menuRefreshed then love.graphics.setShader(invisShader); g_menuRefreshed = true end
		g_gui.core.draw()		
	end

	--If we're in debug mode, draw the current path
	if currentPath and g_showBoxes then
		bullet = love.graphics.newImage(TEXTURES_DIR .. "bullet_alt.png")
		for a, b in pairs(currentPath) do
			love.graphics.draw(bullet,
			b.col * g_currentLevel.levelAttribs.blockSize,
			b.row * g_currentLevel.levelAttribs.blockSize,
			0, 2, 2, 0, 0, 0, 0)
		end
	end
	love.graphics.setShader(fadeShader)
end
end


local playerInc = vector(0, 0)
local pIncX = vector(0, 0)
local pIncY = vector(0, 0)
local pPos = vector(0,0)

function getBlockByID(id)
	for i, v in ipairs(g_entityBlocks) do
		if id == v:getID() then return i end
	end
	return 0
end

function processEvent(e)
  -- An event's ID and description are basically the same thing, but somehow
  -- different. It's an oddity which I haven't yet had the courage to
  -- investigate/fix.
  eDesc = e:getDesc();
  eID = e:getID();
	if "removeblock" == eDesc then
		local i = getBlockByID(e:getSender())
		if i ~= 0 then
			youCanPass(pathMap, g_entityBlocks[i]:getPos(), g_entityBlocks[i]:getSize())
		end
	elseif "addblock" == eDesc then
		local i = getBlockByID(e:getSender())
		if i ~= 0 then
			youShallNotPass(pathMap, g_entityBlocks[i]:getPos(), g_entityBlocks[i]:getSize())
		end
	elseif "movecamera" == eID then
    local cameraName = e:getData()[1]
    local cameraTimer = e:getData()[2]
    local theCamera = g_cameras[cameraName]
    -- Calculate the new position to move the camera to.
      
    -- Since camera logic is difficult to separate from graphics logic, we
    -- have to apply the scale here (only for now, hopefully)
    local newPosX = theCamera:getPos().x -
                    ((g_config.widthInBlocks/(2 * g_config.scale)) * g_blockSize)
    local newPosY = theCamera:getPos().y -
                    ((g_config.heightInBlocks/(2 * g_config.scale)) * g_blockSize)
    g_gm:moveCamera(
      cameraName,
      newPosX,
      newPosY,
      cameraTimer)
    
	elseif "endlevel" == eID then
		g_nextLevel = e:getDesc();
    	g_gm:setState("finishinglevel");
	elseif "endgame" == eID then
    	g_gm:setState("finishinggame");
	end
	if "save" == eID then
		g_gm:saveState();
	end
end



-------------------------------------------------------------------------------
-- gameUpdate
--
--  
-------------------------------------------------------------------------------
function gameUpdate(dt)
	if (not love.window.hasFocus())and g_gm:getState() ~= "paused" and g_gm:getState() ~= "splash" and g_gm:getState() ~= "endsplash" then return end
  -- Cap the delta time at 0.07. This should prevent players from accidentally
  -- or deliberately running through walls if the game is running extremely
  -- slowly.
	dt = math.min(dt, 0.07)
	-- Get the moodified delta time (the same as regular DT if action
	-- isn't slowed down
	local modifiedDT = g_gm:getModifiedDT(dt)
	if g_usingTiled then
		tiledMap:update(modifiedDT)
	end
	-- Update the game manager, which, among other thigs, will calculate
	-- a new slowdown factor if it needs
	g_gm:update(dt)
  if "finishinglevel" == g_gm:getState() then return end
  if "finishinggame" == g_gm:getState() then return end
  if "loading" == g_gm:getState()  then 
		love.graphics.setFont(g_fonts[1])
			g_gui.group.push{grow = "down", pos = {love.graphics.getWidth()/2 - uiData.btnMenuWidth/2, love.graphics.getHeight()/2 - uiData.btnMenuHeight*0.75}}
			g_gui.Label{size = {"tight", "tight"}, text = "Loading..."}
      unloadLevel()
      g_currentLevel = nil
      g_gm:unload()
      g_currentLevel = require("src/" .. g_nextLevel)
      loadLevel()
      g_gm:saveState()
      g_gm:setState("running")
		return
	end

	if g_gm:getState() == "splash" then
		love.graphics.setFont(g_fonts[1])
		--g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - uiData.btnMenuWidth), (love.graphics.getHeight()/2 - uiData.btnMenuHeight*0.5)}, spacing = scale/2}
		if g_gui.Button{size = {"tight", "tight"}, id = "btn_start", text = "Press space or push any button to begin"} then g_gm:setState("running") end		
		
		love.graphics.setFont(g_fonts[3])
    		g_gui.Label{size = {"tight", "tight"}, pos= {1, 200}, text="Copyright (C) Brad Ellis"}

		return
	elseif g_gm:getState() == "endsplash" then
		love.graphics.setFont(g_fonts[1])
		--g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/3 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/3 - (scale * 0.5 * uiData.btnMenuHeight)*3)},}
		g_gui.Label{size = {"tight", "tight"}, text="THE END"}
		love.graphics.setFont(g_fonts[3])
		g_gui.Label{size = {"tight", "tight"}, text="You've escaped!\n\n" ..
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
	elseif g_gm:getState() == "paused" then 
		--g_fonts[3] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 10 * scale)
		--g_fonts[1] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 17.5 * scale)
		--g_fonts[4] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 4 * scale)
		--g_fonts[2] = love.graphics.newFont(FONT_PROCIONO_REGULAR, 25 * scale)
		g_gui.group.default.spacing = scale	
		love.graphics.setFont(g_fonts[1])
		if uiData.menuState == "paused" then
--			g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_resume", text = "Back to Game (P)"} then uiData.menuState = "resume" end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_settings", text = "Settings (S)"} then uiData.menuState = "settings" end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_levels", text = "Level Select (L)"} then uiData.menuState = "levels" end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_about", text = "About Jailers (J)"} then uiData.menuState = "about" end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_quit", text = "Quit (Q)"} then uiData.menuState = "exit" end
		elseif uiData.menuState == "settings" then
			g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			g_gui.Label{size = {"tight", "tight"}, text="Set Graphical Scale"}
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_1", text = "1 (key 1)"} then scale = 1; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_1p5", text = "1.5 (key 2)"} then scale = 1.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_2", text = "2 (key 3) - default"} then scale = 2; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale)  end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_2p5", text = "2.5 (key 4)"} then scale = 2.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
		elseif uiData.menuState == "exit" then
			g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			g_gui.Label{size = {"tight", "tight"}, text="Are you sure?"}
			g_gui.group.push{grow = "right", pos = {0, (scale * 0.5 * uiData.btnMenuHeight/2)}}
			if g_gui.Button{size = {"tight", "tight"}, text = "", size = {[1] = 1, [2] = 1}} then end	
			if g_gui.Button{size = {"tight", "tight"}, text = "Yes (Y)", size = {[1] = scale * 0.5 * uiData.btnMenuWidth/2, [2] = scale * 0.5 * uiData.btnMenuHeight}} then love.event.push("quit") end	
			if g_gui.Button{size = {"tight", "tight"}, text = "No (N)",  size = {[1] = scale * 0.5 * uiData.btnMenuWidth/2, [2] = scale * 0.5 * uiData.btnMenuHeight}} then uiData.menuState="paused" end	
		elseif uiData.menuState == "levels" then
			g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/4)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2.5)},}
			g_gui.Label{size = {"tight", "tight"}, text="Choose a level"}
			if g_gui.Button{size = {"tight", "tight"}, text = "", size = {[1] = 1, [2] = 1}} then end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_settings", text = "Library I (1)"} then g_nextLevel = "level1"; g_gm:setState("finishinglevel") end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_levels", text = "Library II (2)"} then  g_nextLevel = "level2"; g_gm:setState("finishinglevel") end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_about", text = "Depths I (3)"} then g_nextLevel = "level3"; g_gm:setState("finishinglevel") end	
			if g_gui.Button{size = {"tight", "tight"}, id = "btn_quit", text = "Depths II (4)"} then  g_nextLevel = "level4"; g_gm:setState("finishinglevel") end
		elseif uiData.menuState == "about" then
			love.graphics.setFont(fonts[3])
			g_gui.group.push{grow = "down", pos = {(love.graphics.getWidth()/2 - ((scale * uiData.btnMenuWidth)/3)), (love.graphics.getHeight()/2 - (scale * 0.5 * uiData.btnMenuHeight)*2)},}

			g_gui.Label{size = {"tight", "tight"}, text="Oh dear! You've only gone and trapped yourself\n" .. "in your own interdimensional prison.\n"
							.. "Avoid your traps and your jailers. After all,\n" .. "you're just another prisoner to them. \n\n"
							.. "Jailers was made by Brad Ellis.\n".. "It uses Lua and the awesome LÖVE engine.\n"
							.. "For acknoledgements and more, see the readme.\n" }
		elseif uiData.menuState == "resume" then g_gm:pause() end

	return end

	for i, e in g_gm:targets("player") do
		g_thePlayer:processEvent(e)
		g_gm:removeEvent("player", i)
	end


	for i, e in g_gm:targets("main") do
		processEvent(e)
		g_gm:removeEvent("main", i)
	end

	for _, v in ipairs(g_entityTriggers) do
		for i, e in g_gm:targets(v:getID()) do
      result = v:processEvent(e)
      g_gm:removeEvent(v:getID(), i)
		end
	end
	
	for _, v in ipairs(g_entityBlocks) do
		for i, e in g_gm:targets(v:getID()) do
      result = v:processEvent(e)
      g_gm:removeEvent(v:getID(), i)
		end
	end

	for i, e in g_gm:targets("mainwait") do
		processEvent(e)
		g_gm:removeEvent("mainwait", i)
	end
	--Prepare to move player

	downStages = {0, -0.3, -0.6, -0.9}
	upStages = {0, 0.3, 0.6, 0.9}
	local stickX, stickY = g_gm:getBandedAxes(upStages, downStages)
	playerInc.x, playerInc.y = 0, 0
	if  "dead" ~= g_thePlayer:getState() then
		
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

	if "dead" ~= g_thePlayer:getState() and "stopped" ~= g_thePlayer:getState() then
		if 0 == playerInc.x and 0 == playerInc.y then g_thePlayer:setState("resting")
			elseif math.abs(playerInc.x) > math.abs(playerInc.y) then
				g_thePlayer:setState("moving_horizontal")
			else
				g_thePlayer:setState("moving_vertical")
			end
	end
--		playerInc = playerInc:normalized()
		playerInc = playerInc * modifiedDT * g_thePlayer:getSpeed()
		pIncX.x = playerInc.x
		pIncY.y = playerInc.y

    g_thePlayer:setDir(vector(pIncX.x, pIncY.y))
	--Prepare to move enemy
	--for i,v in ipairs(g_entityEnemies) do
--		if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
	--		local moveVec = v:getMoveVec()
	--		local enemyPos = v:getPos()
	--		v:testPathCollision(g_currentLevel.levelAttribs.blockSize)
	--		local target = v:getTarget()
	--		local size = v:getSize()
	---		moveVec.x = target.x - (enemyPos.x + (size.x/2))
	--		moveVec.y = target.y - (enemyPos.y + (size.y/2))
		
	--		moveVec = moveVec:normalized()
	--		moveVec = modifiedDT * v:getSpeed() * moveVec
			
	--		v:setMoveVec(moveVec)	
	--	end
	--end		

	g_thePlayer:updateAnim(modifiedDT)

	g_thePlayer:updateSound(modifiedDT)

	--for i,v in ipairs(g_entityEnemies) do
	--	v:update(modifiedDT)
	--	v:updateAnim(modifiedDT)
	--	v:updateSound(modifiedDT)
	--end

	for i, v in ipairs(g_entityBlocks) do
		v:updateSound(modifiedDT)
	end

	--for i,v in ipairs(g_entityMovers) do
	--	v:updateSound(modifiedDT)
	--end

	--for i,v in ipairs(g_entityGuns) do
	--	v:updateSound(modifiedDT)
	--end

	--Move player and enemy on X

	g_thePlayer:move(pIncX)
	
	--for i,v in ipairs(g_entityEnemies) do
	--	if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
	--		local moveVec = v:getMoveVec()
	--		local moveVecX = vector(moveVec.x, 0)
	--		v:move(moveVecX)
	--	end
	--end
	
  local thePlayerShape = g_thePlayer:getCollisionShape()
  for a, b in pairs(theCollider:collisions(thePlayerShape)) do
    onCollide(dt, thePlayerShape, a)
  end
	
	--Move player and enemy on Y

	g_thePlayer:move(pIncY)
	
	--for i,v in ipairs(g_entityEnemies) do
	--	if v:getState() == "attacking_direct" or v:getState() == "attacking_path" then
	--		local moveVec = v:getMoveVec()
	--		local moveVecY = vector(0, moveVec.y)
	--		v:move(moveVecY)
	--	end
	--end
  
  for a, b in pairs(theCollider:collisions(thePlayerShape)) do
    onCollide(dt, thePlayerShape, a)
  end


--	for i,v in ipairs(g_entityGuns) do
	--	v:update(modifiedDT)
    
	--end
	for i,v in ipairs(g_entityBlocks) do
		if v:getState() ~= "dead" then v:update(modifiedDT) end
	end


	--PATHFINDING: prepare view rays

	g_thePlayer:getCentre(pPos)
	
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

	g_thePlayer:getTopLeft(rayStarts[1])
	g_thePlayer:getTopRight(rayStarts[2])
	g_thePlayer:getBottomLeft(rayStarts[3])
	g_thePlayer:getBottomRight(rayStarts[4])

	--for i,v in ipairs(g_entityEnemies) do
	--	if v:getState() ~= "dead" and v:getState() ~= "dormant" then 
	--		v:getTopLeft(rayStarts[5])
	--		v:getTopRight(rayStarts[6])
	--		v:getBottomLeft(rayStarts[7])
	--		v:getBottomRight(rayStarts[8])
	--		for k, r in ipairs(rayDirs) do
	--			if k < 5 then
	--				r.x = rayStarts[k+4].x - rayStarts[k].x
	--				r.y = rayStarts[k+4].y - rayStarts[k].y
	--			else
	--				r.x = -rayDirs[k-4].x
	--				r.y = -rayDirs[k-4].y
	--			end
	--		end

			--Is there a direct line of sight to the player? If so forget the path and go straight there
	--		local readyToPath = false
	--		local directRoute = true
	--		for j,o in ipairs(g_entityBlocks) do
	--			if o:getState() ~= "dead" then
	--				
	--				if o:collidesRays(rayStarts, rayDirs) then
	--						if v:getState() == "attacking_direct" then readyToPath = true end
	--						directRoute = false
	--						v:setState("attacking_path")
	--				end
	--			end
	---		end
	--		if directRoute then
	--			v:setState("attacking_direct")
	--			v:setTarget(pPos)
	--		end	
	--		v:incPathTimer(modifiedDT)
			
			--Enemy generates a new path if player goes or out of line of sight,
			--or if enemy is at end of current path or has been following it for more than 1 second
	--		if not readyToPath then readyToPath = v:testPathTimer(1) or v:isAtEndOfPath()  end	
	--		if readyToPath and v:getState() == "attacking_path" then
	--			local startX, startY = v:findNearest(g_currentLevel.levelAttribs.blockSize)
	--			local endX, endY = g_thePlayer:findNearest(g_currentLevel.levelAttribs.blockSize)
	--			local startPos = {r = startY, c = startX}
	--			local endPos = {r = endY, c = endX}

	--			local path = jumperFinder:getPath(startX, startY, endX, endY)

	--			v:copyPath(path);	
	--			
	--			currentPath = v:getPath()
	--			
	--			v:startPath(g_currentLevel.levelAttribs.blockSize)
	--		end
	--	end
	--end

	TEsound.cleanup()
end

function gameKeyPressed(key)
	if g_gm:getState() == "splash" then
	
		if key == " " then g_gm:setState("running") end
		if key == "return" then g_gm:setState("running") end
		if key == "q" then love.event.push("quit") end
		if key == "escape" then love.event.push("quit") end
		return
	end
	if g_gm:getState() == "paused" then
		if uiData.menuState == "paused" then
			if key == "q" then love.event.push("quit") end--uiData.menuState = "exit" end
			if key == "l" then uiData.menuState = "levels" end
			if key == "s" then uiData.menuState = "settings" end
			if key == "j" then uiData.menuState = "about" end
	    if key == "escape" or key == "p" then g_gm:pause(); uiData.menuState = "paused" end
		elseif uiData.menuState == "exit" then
			if key == "y" then love.event.push("quit")--[[exit]] else uiData.menuState = "paused" end
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "levels" then
			if key == "1" then g_nextLevel = "level1" g_gm:setState("finishinglevel") end
			if key == "2" then g_nextLevel = "level2" g_gm:setState("finishinglevel") end
			if key == "3" then g_nextLevel = "level3" g_gm:setState("finishinglevel") end
			if key == "4" then g_nextLevel = "level4" g_gm:setState("finishinglevel") end
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "about" then
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		elseif uiData.menuState == "settings" then
			if key == "1" then scale = 1; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
			if key == "2" then scale = 1.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
			if key == "3" then scale = 2; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
			if key == "4" then scale = 2.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end	
			if key == "p" or key == "escape" then uiData.menuState = "paused" end
		end
	elseif g_gm:getState() == "running" then
		  if key == "escape" or key == "p" then g_gm:pause(); uiData.menuState = "paused" end
	end
	if DEBUG_ENABLED then
		if key == "`" then g_showBoxes = not g_showBoxes end
		if key == "m" then g_showGrid = not g_showGrid end
		if key == "f5" then g_gm:saveState() end
		if key == "f9" then g_gm:loadState() end
		if key == "t" then g_gm:startSlowing(0.1, 5, 0.5) end
		if key == "f1" then
			if g_gm:getState() == "loading" then
				g_currentLevel = require "level1"
				loadLevel()
				g_gm:setState("running")
			else
			 	g_gm:setState("loading")
			end--unloadLevel() end
		end
	end

end

function gameJoystickPressed(joystick, button)
	if g_gm:getState() == "paused" then
    if uiData.menuState == "paused" then
      g_gm:pause(); uiData.menuState = "paused"
    elseif uiData.menuState == "exit" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "levels" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "about" then
      uiData.menuState = "paused"
    elseif uiData.menuState == "settings" then
      uiData.menuState = "paused"
    end
  elseif g_gm:getState() == "running" then
        g_gm:pause(); uiData.menuState = "paused"
  elseif g_gm:getState() == "splash" then
        g_gm:setState("running")
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
