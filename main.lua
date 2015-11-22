-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2015
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
  if args[#args] == "-debug" then
    isDebugging = true
    require("mobdebug").start()
  end
  
  -- Launch level based on commandline args; eg, to load level0
  -- you would launch the game with love . level0
  local levelName = "level1"
  if (#args > 2 and isDebugging) or (#args == 2 and not isDebugging) then
    levelName = args[2]
  else
    levelName = "level1"
  end
  
	gameLoad(levelName)
  
end

function love.draw()
	love.graphics.scale(2, 2)
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

