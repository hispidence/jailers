scale = 2  

local blockSize = 16

function love.conf(t)
	t.title = "Jailers"
	
	t.window.width = (blockSize * 40 * scale)
	t.window.height = (blockSize * 30 * scale)
end
