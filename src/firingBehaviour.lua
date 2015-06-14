firingBehaviour = {}

firingBehaviour.__index = firingBehaviour

	setmetatable(firingBehaviour,
			{__call = function(cls, ...)
				return cls.new(...)
			end})

	function firingBehaviour.new(...)
		local self = setmetatable({}, firingBehaviour)
		self:init(...)
		return self
	end

	function firingBehaviour:init()
		self.data = {}
	end

	function firingBehaviour:init(data, fireFunc, resetFunc, soundFunc)
		self.data = data
		self.fire = fireFunc
		self.reset = resetFunc
		self.isSoundReady = soundFunc
	end

	function firingBehaviour:fire(dt, gun)
		print("No fire behaviour set")
	end

	function firingBehaviour:reset()
		print("No reset behaviour set")
	end

	function firingBehaviour:setFireFunc(fireFunc)
		self.fire = fireFunc
	end

	function firingBehaviour:setResetFunc(resetFunc)
		self.reset = resetFunc
	end
