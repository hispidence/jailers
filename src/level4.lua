require("firingBehaviour")
vector = require("hump.vector")
gm = require("gameManager")


local level = {}


local function behaviour_moveAttachment(self, dt) 

	self.bData.timeSinceLast = self.bData.timeSinceLast + dt
	
	if self.bData.timeSinceLast >= self.bData.timeBetween then
		e1 = jlEvent(self.id, self.bData.otherID, "none", "move", self.position, 0)
		gm:sendEvent(e1)
		self.bData.timeSinceLast = self.bData.timeSinceLast - self.bData.timeBetween
	end
end

local function behaviour_moveAttachment_reset(self)
	
	self.bData.timeSinceLast = self.bData.timeBetween
end


local function fire_targeted(self, dt, theGun)
	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]
	if timeLastBullet > timeBetweenBullets then
		local pos = theGun:getPos():clone()
		local vel = (g_thePlayer:getPos() - pos)
		vel = vel:normalized()

		pos = pos + vector(0.5, 6.5)

		vel = vel * self.data["bulletSpeed"]

		theGun:addBullet(pos, vel)
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end
	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function fire_circular(self, dt, theGun)
	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]

	if timeLastBullet >= timeBetweenBullets then
		local function rotate(p, angle)
			local newPoint = p:clone()
			newPoint.x = (p.x * math.cos(angle)) - (p.y * math.sin(angle))
			newPoint.y = (p.x * math.sin(angle)) + (p.y * math.cos(angle))
			return newPoint
		end

		local pos
		local vel
		local rotatedDir

		for i = 0, self.data["nBullets"] do
			pos = self.data["bulletOffset"]:clone() + theGun:getPos()
			rotatedDir = rotate(self.data["bulletDirection"], (i / self.data["nBullets"]) * (2 * math.pi))
			vel = self.data["vel"] * rotatedDir
			theGun:addBullet(pos, vel)
		end	
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end

	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function fire_targetedTri(self, dt, theGun)
		timeLastBullet = self.data["timeLastBullet"]
		timeBetweenBullets = self.data["timeBetweenBullets"]
		
		if timeLastBullet > timeBetweenBullets then

			local pos = theGun:getPos():clone()
			local dir = (g_thePlayer:getPos() - pos)
			dir = dir:normalized()
	
			pos = pos + vector(0.5, 6.5)
	
			local vel

			local function rotate(p, angle)
				local newPoint = p:clone()
				newPoint.x = (p.x * math.cos(angle)) - (p.y * math.sin(angle))
				newPoint.y = (p.x * math.sin(angle)) + (p.y * math.cos(angle))
				return newPoint
			end
			
			local rotatedDir
			pos = self.data["bulletOffset"]:clone() + theGun:getPos()
			rotatedDir = rotate(dir, (-0.39263))
			vel = self.data["bulletSpeed"] * rotatedDir
			theGun:addBullet(pos, vel)
	
			pos = self.data["bulletOffset"]:clone() + theGun:getPos()
			vel = self.data["bulletSpeed"] * dir
			theGun:addBullet(pos, vel)
	
			pos = self.data["bulletOffset"]:clone() + theGun:getPos()
			rotatedDir = rotate(dir, (0.39263))
			vel = self.data["bulletSpeed"] * rotatedDir
			theGun:addBullet(pos, vel)
	
			self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end
	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function fire_rotating(self, dt, theGun)
	local function rotate(p, angle)
		local newPoint = p:clone()
		newPoint.x = (p.x * math.cos(angle)) - (p.y * math.sin(angle))
		newPoint.y = (p.x * math.sin(angle)) + (p.y * math.cos(angle))
		return newPoint
	end

	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]
	
	self.data["rotationAngle"] = self.data["rotationAngle"] + dt * self.data.rotDir * self.data.rotSpeed
		
	local passedExtent = false

	if self.data.rotDir > 0 then
		passedExtent = self.data["rotationAngle"] >= self.data["extents"][self.data["currentExtent"]]
	else
		passedExtent = self.data["rotationAngle"] <= self.data["extents"][self.data["currentExtent"]]
	end

	if passedExtent then	
		self.data.rotDir = -self.data.rotDir
		local amount = 2 * (self.data["rotationAngle"] - self.data["extents"][self.data["currentExtent"]])
		self.data["rotationAngle"] = self.data["rotationAngle"] - amount

		self.data["currentExtent"] = self.data["currentExtent"] + 1
		if self.data["currentExtent"] > #self.data["extents"] then self.data["currentExtent"] = 1 end
	end

	if timeLastBullet >= timeBetweenBullets then
		local rotatedDir = rotate(self.data["bulletDirection"], self.data["rotationAngle"])
		local pos
		local vel
		pos = self.data["bulletOffset"]:clone() + theGun:getPos()
		vel = self.data["vel"] * rotatedDir
		
		theGun:addBullet(pos, vel)
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end

	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function reset_standard(self, theGun)
	self.data["timeLastBullet"] = self.data["timeBetweenBullets"]
end

local function soundReady_standard(self, dt)
	if self.data["timeLastBullet"] then
		if self.data["timeLastBullet"] >= self.data["timeBetweenBullets"] then
			return true
		else
			return false
		end
	end

end


local function collisionBehaviour(sender, target, desc, timer, data)
	if desc == "endgame" then 
		return function(o1, o2)
			if fired then return end
			e1 = jlEvent(sender, target, data, "endgame")
			gm:sendEvent(e1)
		end	
	elseif desc == "endlevel" then 
		return function(o1, o2)
			if fired then return end
			e1 = jlEvent(sender, target, data, "endlevel")
			gm:sendEvent(e1)
		end	
	elseif desc == "checkpoint" then 
		return function(o1, o2)
			if fired then return end
			e1 = jlEvent(sender, sender, "active", "changestate");
			e2 = jlEvent(sender, target, "none", "save")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end	
	elseif desc == "doorswitch_open" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "none", "removeblock", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "doorswitch_close" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "none", "addblock", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "jailerswitch" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "attacking_path", "activate", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "moverswitch_on" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "active", "changestate", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "moverswitch_off" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "dormant", "changestate", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "gunswitch_on" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "active", "changestate", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "gunswitch_off" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "dormant", "changestate", timer)
			e2 = jlEvent(sender, sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	elseif desc == "triggerswitch_on" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "active", "changestate", timer)
			gm:sendEvent(e1)
		end	
	elseif desc == "movecamera" then 
		return function(o1, o2)
			e1 = jlEvent(sender, target, "none", "movecamera", data, timer)
			e2 = jlEvent(sender, sender, "dormant", "changestate", timer)
			gm:sendEvent(e1)
			gm:sendEvent(e2)
		end
	end
end

local function deathBehaviour(sender, target, desc, timer)
	if desc == "doorswitch_open" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "none", "removeblock", timer)
			gm:sendEvent(e1)
		end
	elseif desc == "moverswitch_on" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "active", "changestate", timer)
			gm:sendEvent(e1)
		end
	elseif desc == "moverswitch_off" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "dormant", "changestate", timer)
			gm:sendEvent(e1)
		end
	elseif desc == "gunswitch_on" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "active", "changestate", timer)
			gm:sendEvent(e1)
		end
	elseif desc == "gunswitch_off" then
		return function(o1, o2)
			e1 = jlEvent(sender, target, "dormant", "changestate", timer)
			gm:sendEvent(e1)
		end
	end	
end


local levelAttribs = {
	vel_jailer = 25, 
	vel_bullet_standard = 60,
	vel_bullet_slow = 40,
	vel_bullet_fast = 80,
	life_bullet_standard = 10,
	life_bullet_short = 5.75,
	offset = 16/2,
	moverSpeed = 25,
	blockSize = 16,
	width = 40,
	height = 60,
	initialCamera = vector(0, 0),
	blockSize = 16,
	enemySize = 14,
	scaledEnemySize = 14,-- * scale,
	scaledBlockSize = 16,-- * scale,
	playerSpeed = 150,
	playerStart = vector(4, 4),
	playerSounds = { 	["dead"] = {id = "player_death", repeating = "false", time = 1},
						["moving_vertical"] = {id = "player_move", repeating = true, time = 0.3},
						["moving_horizontal"] = {id = "player_move", repeating = true, time = 0.3},}
}

-- not sure why these are here and not in levelAttribs.
-- TODO: either remove these into levelAttribs or move levelAttribs stuff into here
-- OR! rename them to something more descriptive eg hallGunAttribs
local uniqueAttribs = {
	bulletVelUp = vector(0, -levelAttribs.vel_bullet_slow),
	bulletVelDown = vector(0, levelAttribs.vel_bullet_slow),
	bulletLife = levelAttribs.life_bullet_short,
	bulletOffset = vector(0.3, 0.3),
	timeBetweenBullets = 1.75,
}

local anims = {
	["jailer_ranged"] = {["attacking_path"] = {16, 16, 0.5, 2, "loop"}, ["dead"] = {16, 16, 0.045, 8, "once"}},
	["jailer_melee"] = {["attacking_path"] = {14, 14, 0.5, 2, "loop"}, ["dead"] = {14, 14, 0.03, 12, "once"}}
}

local lTriggers = {
	{id = "trigger1",
	pos = vector(22, 17),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger1",	"main",	"movecamera", 0, {vector(0, 0), 3}), collisionBehaviour("trigger1",  "trigger2", "triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger2",
	pos = vector(22, 19),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger2",	"main",	"movecamera", 0, {vector(0, -17), 3}), collisionBehaviour("trigger2",  "trigger1", "triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger3",
	pos = vector(14, 33),
	size = vector(2, 1),
	ignoresBullets = true,
	behaviour = {collisionBehaviour("trigger3",	"main",	"movecamera", 0, {vector(0, -17), 3}), collisionBehaviour("trigger3",  "trigger4", "triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger4",
	pos = vector(14, 36),
	size = vector(2, 1),
	ignoresBullets = true,
	behaviour = {collisionBehaviour("trigger4",	"main",	"movecamera", 0, {vector(0, -33), 3}), collisionBehaviour("trigger4",  "trigger3", "triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger5",
	pos = vector(27.5, 40),
	size = vector(1, 2),
	ignoresBullets = true,
	behaviour = {collisionBehaviour("trigger5",	"main",	"endgame", 0, nil)},
	state = "active"},
}

local lGuns = {
	{id = "gun1",
	pos = vector(22, 10),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_slow, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = levelAttribs.life_bullet_standard,
	bulletTime = 0.7,
	texture= {["dormant"] = "eyegun_dormant", ["active"] = "eyegun_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	ignoresBullets = true,
	invisible = false,	
	shootingBehaviour = firingBehaviour(
	 			{
				rotDir = 1,
				extents = {0.5235, -0.5235},
				currentExtent = 1,
				vel = levelAttribs.vel_bullet_standard,
				rotSpeed = 1.5,
				bulletOffset = vector(levelAttribs.blockSize * 0.3, levelAttribs.blockSize * 0.3),
				rotationAngle = 0,
				bulletDirection = vector(-1, 0),
				timeLastBullet = 0.125,
				timeBetweenBullets = 0.125,
		},
		fire_rotating,
		reset_standard,
		soundReady_standard
	),
	state = "dormant"},

	{id = "gun2",
	pos = vector(2, 14),
	size = vector(1, 1),
	bulletVel = vector(0, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = levelAttribs.life_bullet_standard,
	bulletTime = 2.1,
	invisible = true,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "whitebullet", ["active"] = "whitebullet"},
	shootingBehaviour = firingBehaviour({bulletOffset = vector(0.6, 9.0), jailerSize = 1 * levelAttribs.blockSize, timeLastBullet = 1, timeBetweenBullets = 1, bulletSpeed = levelAttribs.vel_bullet_fast},
	fire_targetedTri, reset_standard, soundReady_standard),
	state = "dormant"},

	{id = "gun3",
	pos = vector(11, 19),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelDown, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = uniqueAttribs.timeBetweenBullets}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun4",
	pos = vector(13, 19),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelDown, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},


	{id = "gun5",
	pos = vector(15, 19),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelDown, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},



	{id = "gun6",
	pos = vector(17, 19),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelDown, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,

	ignoresBullets = true,

	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},


	{id = "gun7",
	pos = vector(19, 19),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelDown, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun8",
	pos = vector(10, 32),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelUp, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},


	{id = "gun9",
	pos = vector(12, 32),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelUp, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},


	{id = "gun10",
	pos = vector(14, 32),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelUp, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun11",
	pos = vector(16, 32),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelUp, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun12",
	pos = vector(18, 32),
	size = vector(1, 1),
	bulletVel = uniqueAttribs.bulletVelUp, 
	bulletOffset = uniqueAttribs.bulletOffset, 
	bulletLife = uniqueAttribs.bulletLife,
	bulletTime = uniqueAttribs.timeBetweenBullets,
	ignoresBullets = true,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "biggun",
	pos = vector(13.8, 47.8),
	size = vector(1, 1),
	bulletVel = vector(vel_bullet_standard, 0),
	bulletOffset = vector(0, 0),
	bulletLife = levelAttribs.life_bullet_standard,
	bulletTime = 0.7,
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	ignoresBullets = true,
	invisible = true,	
	shootingBehaviour = firingBehaviour(
	 			{
				nBullets = 10,
				vel = levelAttribs.vel_bullet_slow,
				bulletOffset = vector(0, 0),
				bulletDirection = vector(-1, 0),
				timeLastBullet = 1,
				timeBetweenBullets = 1,
		},
		fire_circular,
		reset_standard,
		soundReady_standard
	),

	state = "dormant"},


}

local lEnemies = {
		{id = "jailer1",
		pos = vector(7.5, 11.5),
		category = "jailer_melee",
		speed = levelAttribs.vel_jailer,
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		texture = {["dormant"] = "meleejailer", ["attacking_path"] = "meleejailer_flash", ["attacking_direct"] = "meleejailer_red", ["dead"] = "meleejailer_death" },
		deathBehaviour = {deathBehaviour("jailer1", "door2", "doorswitch_open", 0), deathBehaviour("jailer1", "gun2", "gunswitch_off", 0)},
		state = "dormant",
		},

		{id = "jailer2",
		pos = vector(10.5, 48),
		category = "jailer_ranged",
		speed = levelAttribs.vel_jailer * (2/3),
		sound = {["attacking_path"] = {id = "superjailer_breath", repeating = "true", time = 1}, ["attacking_direct"] = {id = "superjailer_breath", repeating = "true", time = 1},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		texture = {["dormant"] = "rangedjailer", ["attacking_path"] = "superjailer_flash", ["attacking_direct"] = "superjailer_white", ["dead"] = "rangedjailer_death" },
		deathBehaviour = {deathBehaviour("jailer1", "door4", "doorswitch_open", 0), deathBehaviour("jailer1", "gun2", "gunswitch_off", 0)},
		behaviour = behaviour_moveAttachment,
		resetBehaviour = behaviour_moveAttachment_reset,
		bData = {timeSinceLast = 1, timeBetween = 1, otherID = "gun2"},
		ignoresBullets = true,
		state = "dormant",
		},
	}

local lMovers = { 
			{
			start = vector(24, 7),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover1",
			status = "dormant",
			speed = levelAttribs.moverSpeed,
			ignoresBullets = true,
			dir = vector(0, 1),
			moveExtents = {vector(24, 7), vector(24, 9)},},

			{start = vector(24, 13),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			category = "mover",
			id = "mover2",
			status = "dormant",
			speed = levelAttribs.moverSpeed,
			ignoresBullets = true,
			dir = vector(0, -1),
			moveExtents = {vector(24, 13), vector(24, 11)},},
		}

local walls = {
		{start = vector(5, 2),
		size = vector(2, 2),
		texture = {["dormant"] = "barrel"}},

		{start = vector(4, 5),
		size = vector(2, 1),
		id = "door1",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(7, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(2, 1),
		size = vector(5, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector( 1,  2),
		size = vector(1,  3),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(1, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(2, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(6, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(1, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

  		{start = vector(7, 2),
		size = vector(1, 3),
		texture = {["dormant"] = "eastdeepwall"}},
	
		{start = vector(7, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(7, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(3, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(5, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(3, 6),
		size = vector(1, 8),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(3, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(5, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(6, 6),
		size = vector(20, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(4, 14),
		size = vector(17, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(21, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(26, 7),
		size = vector(1, 7),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(26, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(25, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(24, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(3, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "circle"},

		{start = vector(5, 7),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed1"}},
		{start = vector(5, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed2"}},
		{start = vector(5, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},
		{start = vector(5, 10),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed2"}},
		{start = vector(5, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},
		{start = vector(5, 12),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},

		{start = vector(22, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},
		{start = vector(22, 9),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed2"}},
		{start = vector(22, 11),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed3"}},
		{start = vector(22, 12),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed1"}},
		{start = vector(23, 10),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed1"}},
		{start = vector(24, 10),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(6, 4),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch1", "door1", "doorswitch_open", 0),
					collisionBehaviour("switch1", "mover1", "moverswitch_on", 0),
					collisionBehaviour("switch1", "mover2", "moverswitch_on", 0),
					collisionBehaviour("switch1", "gun1", "gunswitch_on", 0),
					},
		id = "switch1"},		

		{start = vector(26, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},	

		{start = vector(6, 7),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch2", "jailer1", "jailerswitch", 0),
					},
		id = "switch2"},

		{start = vector(22, 14),
		size = vector(2, 1),
		id = "door2",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(21, 15),
		size = vector(1, 16),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(24, 15),
		size = vector(1, 19),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(24, 34),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(21, 31),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(10, 34),
		size = vector(3, 1),
		texture = {["dormant"] = "southdeepwall"}},
		
		{start = vector(17, 34),
		size = vector(7, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(9, 34),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(20, 17),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},
		
		{start = vector(20, 18),
		size = vector(1, 13),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(20, 31),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(8, 17),
		size = vector(1, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(7, 17),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(7, 18),
		size = vector(1, 3),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(7, 21),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(8, 21),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(9, 17),
		size = vector(11, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(9, 22),
		size = vector(1, 12),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(9, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(10, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(12, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(14, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(16, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(18, 19),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(11, 32),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(13, 32),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(15, 32),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(17, 32),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},


		{start = vector(23, 30),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
	    behaviour = {collisionBehaviour("checkpoint1", "mainwait", "checkpoint", 0),
    		collisionBehaviour("checkpoint1", "door2", "doorswitch_close", 0),
			collisionBehaviour("checkpoint1", "door2point5", "doorswitch_open", 0),
			collisionBehaviour("checkpoint1", "mover1", "moverswitch_off", 0),
			collisionBehaviour("checkpoint1", "mover2", "moverswitch_off", 0),
			collisionBehaviour("checkpoint1", "gun1", "gunswitch_off", 0),},
		id="checkpoint1"},

		{start = vector(10, 33),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch3", "gun3", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun4", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun5", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun6", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun7", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun8", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun9", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun10", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun11", "gunswitch_on", 0),
					collisionBehaviour("switch3", "gun12", "gunswitch_on", 0),
					collisionBehaviour("switch3", "door2point5", "doorswitch_close", 0),
					--collisionBehaviour("switch3", "biggun", "gunswitch_on", 0),
					collisionBehaviour("switch3", "door3", "doorswitch_open", 0),
					},
		id = "switch3"},		

		{start = vector(19, 18),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch4", "door4", "doorswitch_open", 0),
					},
		id = "switch4"},		

		{start = vector(20, 32),
		size = vector(2, 2),
		id = "door2point5",
		texture = {["dormant"] = "deepdoor"}},


		{start = vector(9, 20),
		size = vector(1, 1),
		id = "door3",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(14, 34),
		size = vector(2, 2),
		id = "door4",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(9, 21),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(13, 34),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(16, 34),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},
		
		{start = vector(16, 35),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(13, 35),
		size = vector(1, 1),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(13, 36),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(11, 36),
		size = vector(2, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(10, 36),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(10, 37),
		size = vector(1, 1),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(10, 38),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(11, 38),
		size = vector(2, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(13, 38),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(16, 35),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(16, 36),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(17, 36),
		size = vector(2, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(19, 36),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(19, 37),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(19, 38),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(17, 38),
		size = vector(2, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(16, 37),
		size = vector(3, 1),
		texture = {["dormant"] = "barrel"}},

	{start = vector(11, 37),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
	    behaviour = {collisionBehaviour("checkpoint2", "mainwait", "checkpoint", 0),
    		collisionBehaviour("checkpoint2", "door4", "doorswitch_close", 0),
			collisionBehaviour("checkpoint2", "door6", "doorswitch_open", 0),
			collisionBehaviour("checkpoint2", "door7", "doorswitch_open", 0),
			collisionBehaviour("checkpoint2", "gun3", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun4", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun5", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun6", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun7", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun8", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun9", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun10", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun11", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun12", "gunswitch_off", 0),},
		id="checkpoint2"},

		{start = vector(16, 39),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(14, 39),
		size = vector(2, 2),
		id = "door7",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(16, 38),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(13, 39),
		size = vector(1, 1),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(13, 40),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(16, 40),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(17, 40),
		size = vector(4, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(5, 40),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(6, 40),
		size = vector(7, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(5, 41),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(4, 41),
		size = vector(1, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(4, 43),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(3, 41),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(3, 42),
		size = vector(1, 1),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(3, 43),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(5, 43),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(21, 40),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(21, 41),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(22, 41),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(22, 38),
		size = vector(1, 3),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(22, 37),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(23, 37),
		size = vector(4, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(27, 37),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(27, 38),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(27, 39),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwallendingdown"}},

		{start = vector(27, 42),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwallendingup"}},

		{start = vector(23, 38),
		size = vector(4, 2),
		texture = {["dormant"] = "barrel"}},

		{start = vector(25, 42),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(26, 42),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed2"}},

		{start = vector(23, 53),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch5", "gun2", "gunswitch_on", 0),
					collisionBehaviour("switch5", "jailer2", "jailerswitch", 0),
					collisionBehaviour("switch5", "door7", "doorswitch_close", 0),
					collisionBehaviour("switch5", "door8", "doorswitch_open", 0),
					collisionBehaviour("switch5", "biggun", "gunswitch_on", 0),
					collisionBehaviour("switch5", "biggun_graphic", "gunswitch_on", 0),
					},
		id = "switch5"},

		{start = vector(5, 42),
		size = vector(1, 1),
		id = "door8",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(22, 42),
		size = vector(1, 1),
		id = "door9",
		texture = {["dormant"] = "deepdoor"}},

		{start = vector(4, 42),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch6", "door9", "doorswitch_open", 0),
					},
		id = "switch6"},

		{start = vector(27, 43),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(23, 43),
		size = vector(4, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(22, 43),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(22, 44),
		size = vector(1, 8),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(22, 52),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(23, 52),
		size = vector(1, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(24, 52),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(24, 53),
		size = vector(1, 1),
		texture = {["dormant"] = "eastdeepwall"}},
	
		{start = vector(24, 54),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},
			
		{start = vector(23, 54),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(23, 54),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(22, 54),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(22, 55),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(5, 44),
		size = vector(1, 11),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(6, 55),
		size = vector(16, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(5, 55),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(13, 47),
		size = vector(2, 2),
		imageSizeX = 32,
		imageSizeY = 32,
		ignoresBullets = true,
		texture = {["dormant"] = "biggun_dormant", active = "biggun_active"},
		id = "biggun_graphic",},
}


local floors = {

		{start = vector(2, 2),
		size = vector(5, 4),
		texture = "floorboards"},

		{start = vector(4, 6),
		size = vector(22, 8),
		texture = "floorboards"},

		{start = vector(22, 14),
		size = vector(2, 20),
		texture = "floorboards"},

		{start = vector(8, 18),
		size = vector(2, 3),
		texture = "floorboards"},

		{start = vector(10, 18),
		size = vector(12, 16),
		texture = "floorboards"},

		{start = vector(14, 34),
		size = vector(2, 7),
		texture = "floorboards"},

		{start = vector(10, 37),
		size = vector(3, 1),
		texture = "floorboards"},

		{start = vector(12, 37),
		size = vector(3, 1),
		texture = "floorboards"},

		{start = vector(5, 41),
		size = vector(18, 14),
		texture = "floorboards"},

		{start = vector(22, 41),
		size = vector(1, 1),
		texture = "floorboards"},

		{start = vector(22, 38),
		size = vector(5, 5),
		texture = "floorboards"},


		{start = vector(27, 40),
		size = vector(1, 2),
		texture = "end"},

	}

return {
	walls = walls,
	guns = lGuns,
	enemies = lEnemies,
	triggers = lTriggers,
	movers = lMovers,
	anims = anims,
	floors = floors,
	levelAttribs = levelAttribs,
}
