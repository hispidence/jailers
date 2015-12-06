local blockSize = 16

function love.conf(t)
	t.title = "Jailers"
	
	t.window.width = (blockSize * 40)
	t.window.height = (blockSize * 30)
end
