-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2015
--
--
-- main.lua
--
-- Entry point for LÖVE
-------------------------------------------------------------------------------

require("gameMain")

function love.load()
	gameLoad()
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

