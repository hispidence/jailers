-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- main.lua
--
-- Entry point for LÖVE
-------------------------------------------------------------------------------

g_blockSize     = 16
g_halfBlockSize = 8

function love.conf(t)
	t.title = "Jailers"
  t.console = true
	
	t.window.width = (g_blockSize * 40)
	t.window.height = (g_blockSize * 30)
end
