-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2017
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
local g_debugDraw = false



-------------------------------------------------------------------------------
-- Set game manager, GUI, and gamestate variables
-------------------------------------------------------------------------------
local g_gui = require("src/external/Quickie")
local g_gm = require("src/gameManager")
local g_nextLevel = "level2"
local g_menuRefreshed = false
local g_blockSize = 16
local g_config = nil
local g_pixelLocked = false
local FONT_PROCIONO_REGULAR = "resources/Prociono-Regular.ttf"



-------------------------------------------------------------------------------
-- Make variables to hold GUI resources
-------------------------------------------------------------------------------
local g_menuBGtex = nil
local g_fonts = {}



-------------------------------------------------------------------------------
-- createDebugTablePrint
--
-- Creates a function which prints out a table of strings over the game's
-- actual graphics.
-------------------------------------------------------------------------------
function createDebugTablePrint(colour, startX, startY, wrap, alignment)

  function debugTablePrint(textTable)
    for i, v in ipairs(textTable) do
      local text = v
      local yOffset = ((i - 1) * 20);
      love.graphics.printf({{0, 0, 0, 255}, text}, startX, startY + yOffset, wrap, alignment)
      love.graphics.printf({colour, text}, startX + 1.2, startY + yOffset + 1.2, wrap, alignment)
    end
  end

  return debugTablePrint
end

local sTablePrint = createDebugTablePrint({0, 85, 0, 255}, 0, 0, 1000, "left")



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

  theBlock:setCanCollide(true)
  theBlock:setCollisionRectangle()

  theBlock:setID("wall"..x..y)

  theBlock:setCategory("wall")

  local pos = vector(x * g_blockSize, y * g_blockSize)
  pos.x = pos.x - size.x
  pos.y = pos.y - size.y
  theBlock:move(pos)

  g_entityWalls[blockID] = theBlock

  -- if v.ignoresBullets then g_entityWalls[blockID]:setIgnoresBullets(true) end
  -- youShallNotPass(pathMap, g_entityWalls[blockID]:getPos(), g_entityWalls[blockID]:getSize())
end



-------------------------------------------------------------------------------
-- addEntityBlock
--
-- Add block-based objects (e.g. switches, doors) to the g_entityBlocks table.
-------------------------------------------------------------------------------
function addEntityBlock(block)
  local blockID = #g_entityBlocks + 1

  if not block.name or "" == block.name then
    print("Warning! A block has no name.")
    block.name = "nameless_block_FIX_THIS_NOW_" .. blockID
  end

  if not block.type or "" == block.type then
    print("Warning! Block \"" .. block.name .. "\" has no type.")
    block.type = "typeless"
  end

  local prop = block.properties

  if not prop then
    print("Warning! Block \"" .. block.name .. "\" has no properties.")
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

  theBlock:setCanCollide(true)
  theBlock:setCollisionRectangle()

  if prop then
    -- Does the entity specify a textureset?
    theBlock:assignTextureSet(prop.textureset)

    registerBehaviours(theBlock, prop)

    if prop.state and prop.state ~= "" then
      theBlock:setState(prop.state)
    else
      theBlock:setState("dormant");
    end
    -- property assignment should not depend on anything other than the entity
    -- existing, but movers need to know their position beforehand for now
    theBlock:assignFromProperties(prop)
  end

  local pos = vector(block.x, block.y)

  pos.y = pos.y - size.y;
  theBlock:move(pos)

  g_entityBlocks[blockID] = theBlock

  local subObjects = theBlock:createSubObjects()

  if subObjects then
    for i, o in ipairs(subObjects) do
      g_entityBlocks[blockID + i] = o;
    end
  end

end



-------------------------------------------------------------------------------
-- hasDuplicates
--
--
-------------------------------------------------------------------------------
function hasDuplicates(t)
  local hash = {}
  local foundDuplicate = false
  local id
  local duplicates = {}
  for _, v in ipairs(t) do
    id = v:getID()
    if hash[id] then
      duplicates[#duplicates + 1] = id
      foundDuplicate = true
    else
      hash[id] = true
    end
  end
  return foundDuplicate, duplicates
end



-------------------------------------------------------------------------------
-- loadLevel
--
--
-------------------------------------------------------------------------------
function loadLevel(levelFileName)

  tiledMap = sti("src/levels/" .. levelFileName .. ".lua")

  world = love.physics.newWorld(0, 0)

  -- No entities from the "objects" layer get drawn through the STI Tiled
  -- library. Instead, we create entities based on them, and where draw
  -- those instead (where applicable).
  --
  -- Entities from the objects layer are put into one of the global tables
  -- defined above
  if tiledMap.layers["objects"] then
    tiledMap.layers["objects"].visible = false
  end

  if tiledMap.layers["cameras"] then
    tiledMap.layers["cameras"].visible = false
  end

  if tiledMap.layers["triggers"] then
    tiledMap.layers["triggers"].visible = false
  end

  local sLayer = tiledMap.layers["statics"]
  pathMap = buildMap(sLayer.width, sLayer.height)

  local pSize = vector(10, 10)
  local playerObj = tiledMap:getObject("objects", "player")
  local pPos = vector(playerObj.x, playerObj.y - g_blockSize)
  g_thePlayer = character("player")
  g_thePlayer:setTexture("resting",
        love.graphics.newImage(TEXTURES_DIR .. "playerrest.png"),
        false)
  g_thePlayer:setTexture("moving_vertical",
        love.graphics.newImage(TEXTURES_DIR .. "playermoveup.png"),
        false)
  g_thePlayer:setTexture("moving_horizontal",
        love.graphics.newImage(TEXTURES_DIR .. "playermove.png"),
        false)
  g_thePlayer:setTexture("dead",
        love.graphics.newImage(TEXTURES_DIR .. "playerdeath.png"),
        false)
  g_thePlayer:setSize(pSize)
  g_thePlayer:setShapeOffsets(2, 2)
  g_thePlayer:setCollisionRectangle()
  g_thePlayer:setID("player")
  g_thePlayer:setCategory("player")
  g_thePlayer:setState("resting")
  g_thePlayer:setPathBox()
  g_thePlayer:setSpeed(150)
  g_thePlayer:setPos(pPos)
  g_thePlayer:setCanCollide(true)


  local anim = newAnimation(g_thePlayer:getTexture("dead"), 14, 14, 0.08, 6)
  anim:setMode("once")
  g_thePlayer:setAnim("dead", anim)

  anim = newAnimation(g_thePlayer:getTexture("resting"), 14, 14, 0.15,4)
  g_thePlayer:setAnim("resting", anim)

  anim = newAnimation(g_thePlayer:getTexture("moving_horizontal"), 14, 14, 0.05, 12)
  g_thePlayer:setAnim("moving_horizontal", anim)

  anim = newAnimation(g_thePlayer:getTexture("moving_vertical"), 14, 14, 0.05, 12)
  g_thePlayer:setAnim("moving_vertical", anim)


  -- Initialise walls
  for y, tile in ipairs(tiledMap.layers.statics.data) do
    for x, data in pairs(tile) do
      addEntityWall(data, x, y)
    end
  end

  -- Initialise triggers
  if tiledMap.layers["triggers"] then
    for y, trig in ipairs(tiledMap.layers.triggers.objects) do
      addEntityTrigger(trig)
    end
  end

  local duplicates
  local dupsPresent = false
  local dupErrStr = "Level " .. levelFileName .. " has duplicates: "
  dupsPresent, duplicates = hasDuplicates(g_entityTriggers)

  if dupsPresent then
    return false, dupErrStr .. table.concat(duplicates, ", ")
  end

  -- Initialise cameras
  if tiledMap.layers["cameras"] then
    for y, cam in ipairs(tiledMap.layers.cameras.objects) do
      addCamera(cam)
    end
  end
  dupsPresent, duplicates = hasDuplicates(g_cameras)

  if dupsPresent then
    return false, dupErrStr .. table.concat(duplicates, ", ")
  end

  -- Initialise block-based objects
  if tiledMap.layers["objects"] then
    for i, data in ipairs(tiledMap.layers.objects.objects) do
      --Skip if the entity is "special" (e.g. the player)
      if "special" ~= data.type then
        addEntityBlock(data)
      end
    end
  end
  dupsPresent, duplicates = hasDuplicates(g_entityBlocks)

  if dupsPresent then
    return false, dupErrStr .. table.concat(duplicates, ", ")
  end

  return true
end

-------------------------------------------------------------------------------
-- gameLoad
--
--
-------------------------------------------------------------------------------
function gameLoad(levelFileName, config)
  g_config = config
  love.window.setMode(g_config.widthInBlocks * 16, g_config.heightInBlocks * 16)
  windowWidth, windowHeight, _ = love.window.getMode()
  gameLogo = love.graphics.newImage(rTextures[getTextureByID("gamelogo")].fname)
  love.window.setIcon(love.image.newImageData(TEXTURES_DIR .. "meleejailer_red.png"))
  fadeShader = love.graphics.newShader(fadeShaderSource)
  invisShader = love.graphics.newShader(invisShaderSource)
  debugWorldShader = love.graphics.newShader(debugShaderWorldSource)
  debugDebugShader = love.graphics.newShader(debugShaderDebugSource)
  setupUI()
  loadResources()
  local loaded, errStr = loadLevel(levelFileName)
  if not loaded then return false, errStr end
    g_gm:saveState()
  return true
end



-------------------------------------------------------------------------------
-- gameDraw
--
--
-------------------------------------------------------------------------------
function gameDraw()

  love.graphics.setShader(fadeShader)
  love.graphics.scale(g_config.scale, g_config.scale)

  -- Round the new position so it aligns with a pixel. I'm not convinced about
  -- this. I don't think it looks smooth.
  local tX = jRound(-g_gm:getCurrX());
  local tY = jRound(-g_gm:getCurrY());
  love.graphics.translate(tX, tY)

  if(g_debugDraw) then
    love.graphics.setShader(debugWorldShader)
  end
  tiledMap:draw()
  g_thePlayer:draw(g_pixelLocked)

  local theState
  for i, v in ipairs(g_entityBlocks) do
    theState = g_entityBlocks[i]:getState()
    if theState ~= "dead" and not g_entityBlocks[i]:getInvisible() then
      g_entityBlocks[i]:draw(g_pixelLocked)
    end
  end

  if(g_debugDraw) then
    love.graphics.setShader(debugDebugShader)
  end

  if g_debugDraw then
    for i, v in ipairs(g_entityWalls) do
      g_entityWalls[i]:drawDebug()
    end
    g_thePlayer:drawDebug()
    for i, v in ipairs(g_entityBlocks) do
      g_entityBlocks[i]:drawDebug()
    end
  end

  -- If we're in debug mode, print statistics
  if DEBUG_ENABLED then
    love.graphics.setShader()
    love.graphics.translate(-tX, -tY)
    love.graphics.scale(0.75, 0.75)
    love.graphics.setFont(g_fonts[3])
    local debugStrings = {}
    table.insert(debugStrings, "FPS: " .. love.timer.getFPS())
    table.insert(debugStrings, "Slowdown factor: " .. string.format("%.2f", g_gm:getSlowFactor()))
    table.insert(debugStrings, "Player location: " .. string.format("%.2f, %.2f", g_thePlayer:getPos().x, g_thePlayer:getPos().y) )
    table.insert(debugStrings, "Image scale: " ..  g_config.scale)
    sTablePrint(debugStrings)
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
  if (not love.window.hasFocus()) or g_gm:getState() == "paused" then return end
  -- Cap the delta time at 0.07. This should prevent players from accidentally
  -- or deliberately running through walls if the game is running extremely
  -- slowly.

  dt = math.min(dt, 0.07)
  -- Get the moodified delta time (the same as regular DT if action
  -- isn't slowed down

  local modifiedDT = g_gm:getModifiedDT(dt)
  tiledMap:update(modifiedDT)

  -- Update the game manager, which, among other thigs, will calculate
  -- a new slowdown factor if it needs
  g_gm:update(dt)

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
--    playerInc = playerInc:normalized()
  playerInc = playerInc * modifiedDT * g_thePlayer:getSpeed()
  pIncX.x = playerInc.x
  pIncY.y = playerInc.y

  g_thePlayer:setDir(vector(pIncX.x, pIncY.y))


  g_thePlayer:updateAnim(modifiedDT)

  g_thePlayer:updateSound(modifiedDT)

  for i, v in ipairs(g_entityBlocks) do
    v:updateSound(modifiedDT)
  end

  g_thePlayer:move(pIncX)

  local thePlayerShape = g_thePlayer:getCollisionShape()
  for a, b in pairs(theCollider:collisions(thePlayerShape)) do
    onCollide(dt, thePlayerShape, a)
  end

  g_thePlayer:move(pIncY)


  for a, b in pairs(theCollider:collisions(thePlayerShape)) do
    onCollide(dt, thePlayerShape, a)
  end

  for i,v in ipairs(g_entityBlocks) do
    if v:getState() ~= "dead" then v:update(modifiedDT) end
  end

  for _, v in ipairs(g_entityBlocks) do
    local theShape = v:getCollisionShape()
      if v:getCanCollide() then
      for a, b in pairs(theCollider:collisions(theShape)) do
        onCollide(dt, theShape, a)
      end
    end
  end

  --PATHFINDING: prepare view rays

  g_thePlayer:getCentre(pPos)

  local rayStarts = {vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0)}
  local rayDirs = {vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0),
            vector(0,0)}

  g_thePlayer:getTopLeft(rayStarts[1])
  g_thePlayer:getTopRight(rayStarts[2])
  g_thePlayer:getBottomLeft(rayStarts[3])
  g_thePlayer:getBottomRight(rayStarts[4])


  TEsound.cleanup()

end

function gameKeyPressed(key)
  if g_gm:getState() == "paused" then
      if key == "q" then love.event.push("quit") end
      if key == "escape" or key == "p" then g_gm:pause() end
      if key == "1" then scale = 1; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end
      if key == "2" then scale = 1.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end
      if key == "3" then scale = 2; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end
      if key == "4" then scale = 2.5; love.window.setMode(40 * g_currentLevel.levelAttribs.blockSize * scale, 30 * g_currentLevel.levelAttribs.blockSize * scale) end
  elseif g_gm:getState() == "running" then
      if key == "escape" or key == "p" then g_gm:pause() end
  end
  if DEBUG_ENABLED then
    if key == "`" then g_debugDraw = not g_debugDraw end
    if key == "m" then g_showGrid = not g_showGrid end
    if key == "f5" then g_gm:saveState() end
    if key == "f9" then g_gm:loadState() end
    if key == "t" then g_gm:startSlowing(0.1, 5, 0.5) end
    if key == "f1" then
      if g_gm:getState() == "loading" then
        --g_currentLevel = require "level1"
        --loadLevel()
        g_gm:setState("running")
      else
        g_gm:setState("loading")
      end
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
