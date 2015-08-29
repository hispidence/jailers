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
-- args[2] contains the name of the level to be loaded; eg, to load level0 you
-- would launch the game with love . level0
	gameLoad(arg[2] or "level1")
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

