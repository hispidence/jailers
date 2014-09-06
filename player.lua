require("gameObject")

player = {}
for k,v in pairs(gameObject) do
	player[k]=v
end
player.__index = player

setmetatable(player,
	{__index = gameObject,
	__call = function(cls, ...)
		local self = setmetatable({}, cls)
		self:init()		
		return self
	end
	})

function player:tex_iter()
	local t = self.textures
	local i = nil
	local fn = nil
	local tex = nil
	return function()
		i = next(t, i)
		if i~= nil then
			fn = t[i].fileName
			tex = t[i].texture
			return i, fn, tex
		end
		return nil
	end
end

function player:init()
	gameObject:init()
	gameObject:setClass("player")
end
