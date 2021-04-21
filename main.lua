-------------------------------------------------------------------------------
-- Copyright (C) Hispidence 2013-2021
--
--
-- main.lua
--
-- Entry point for LÖVE
-------------------------------------------------------------------------------

require("src.gameMain")

function love.load(args)
  -- Launch level based on commandline args; eg, to load level0
  -- you would launch the game with love . level0
  local levelName = "guntest"

  if args[1] then
    levelName = args[1]
  end

  local loaded, errStr = gameLoad(levelName)

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

