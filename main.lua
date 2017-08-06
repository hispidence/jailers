-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- main.lua
--
-- Entry point for LÖVE
-------------------------------------------------------------------------------

require("src/gameMain")

function love.load(args)
  
  -- Enable ZeroBrane Studio debugging
  local isDebugging = false
  if "-debug" == args[#args] then
    isDebugging = true
    require("mobdebug").start()
  end
  
  -- Level scale
  local config = {
    widthInBlocks = 40,
    heightInBlocks = 30,
    scale = 2,
  }
  
  -- Launch level based on commandline args; eg, to load level0
  -- you would launch the game with love . level0
  local levelName
  if (#args > 2 and isDebugging) or (#args == 2 and not isDebugging) then
    levelName = args[2]
  else
    levelName = "guntest"
  end
  
	local loaded, errStr = gameLoad(levelName, config)
  
  if not loaded then
    love.errhand(errStr)
    love.event.quit()
  end
  
end

function love.draw()
	gameDraw()
end

function love.update(dt)
	gameUpdate(dt)
end

function love.keypressed(key)
	gameKeyPressed(key)
end

function love.joystickpressed(joystick, button)	
	gameJoystickPressed(joystick, button)
end

