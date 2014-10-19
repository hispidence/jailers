require("firingBehaviour")
vector = require("hump.vector")
gm = require("gameManager")

local level = {}

local function delayedFire(self, dt, theGun)
	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]
	if timeLastBullet > timeBetweenBullets[self.data["currentStage"]] then
		local pos = self.data["pos"]:clone()
		local vel = self.data["vel"]
		theGun:addBullet(pos, vel)
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets[self.data["currentStage"]]
		self.data["currentStage"] = self.data["currentStage"] + 1
		if self.data["currentStage"] > #timeBetweenBullets then self.data["currentStage"] = 1 end
	end
	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function delayedReset(self, theGun)
	self.data["timeLastBullet"] = self.data["initialTimeLastBullet"]
	self.data["currentStage"] = 1
end

local function delayedSoundReady(self, dt)
	timeBetweenBullets = self.data["timeBetweenBullets"]
	if self.data["timeLastBullet"] then
		if self.data["timeLastBullet"] > timeBetweenBullets[self.data["currentStage"]] then
			return true
		else
			return false
		end
	end
end

local function newFire(self, dt, theGun)
	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]
	pos = self.data["pos"]:clone()
	vel = self.data["vel"]

	if timeLastBullet > timeBetweenBullets then
		theGun:addBullet(pos, vel)
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end	
	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function newReset(self, theGun)
	self.data["timeLastBullet"] = self.data["timeBetweenBullets"]
end


local function newSoundReady(self, dt)
	if self.data["timeLastBullet"] then
		if self.data["timeLastBullet"] > self.data["timeBetweenBullets"] then
			return true
		else
			return false
		end
	end
end


local function collisionBehaviour(sender, target, desc, timer, data)
	if desc == "endlevel" then 
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
	vel_jailer = 80, 
	vel_bullet_standard = 60,
	vel_bullet_slow = 40,
	offset = 16/2,
	moverSpeed_fast = 80,
	blockSize = 16,
	initialCamera = vector(0, 0),
	width = 40,
	height = 30,
	blockSize = 16,
	enemySize = 14,
	scaledEnemySize = 14,-- * scale,
	scaledBlockSize = 16,-- * scale,
	playerSpeed = 130,
	playerStart = vector(2, 2),	
	playerSounds = { ["dead"] = {id = "player_death", repeating = "false", time = 1}, ["moving_vertical"] = {id = "player_move", repeating = true, time = 0.3}, ["moving_horizontal"] = {id = "player_move", repeating = true, time = 0.3},}
}

local anims = {
	["jailer_melee"] = {["attacking_path"] = {14, 14, 0.5, 2, "loop"}, ["dead"] = {14, 14, 0.03, 12, "once"}}
}

local lTriggers = {
	{id = "trigger1",
	pos = vector(26, 5),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger1", "main",	"movecamera", 0, {vector(0, 0), 2}), collisionBehaviour("trigger1",	"trigger2",	"triggerswitch_on", 0, {vector(-0, -5), 2})},
	state = "active"},

	{id = "trigger2",
	pos = vector(26, 8),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger2",	"main",	"movecamera", 0, {vector(-0, -5), 2}), collisionBehaviour("trigger2",	"trigger1",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	state = "active"},

	{id = "trigger3",
	pos = vector(26, 20),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger3",	"main",	"movecamera", 0, {vector(-0, -5), 2}), collisionBehaviour("trigger3",	"trigger4",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	state = "active"},

	{id = "trigger4",
	pos = vector(26, 23),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger4",	"main",	"movecamera", 0, {vector(0, -10), 2}), collisionBehaviour("trigger4",	"trigger3",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	state = "active"},

	{id = "trigger5",
	pos = vector(2, 20),
	size = vector(1, 1),
	behaviour = {collisionBehaviour("trigger5",	"main",	"movecamera", 0, {vector(0, -10), 2}), collisionBehaviour("trigger5",	"trigger6",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	state = "active"},

	{id = "trigger6",
	pos = vector(2, 17),
	size = vector(1, 1),
	behaviour = {collisionBehaviour("trigger6",	"main",	"movecamera", 0, {vector(0, -5), 2}), collisionBehaviour("trigger6",	"trigger5",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	state = "active"},

	{id = "trigger7",
	pos = vector(30.5, 14),
	size = vector(1, 2),
	behaviour = {collisionBehaviour("trigger7",	"main",	"endlevel", 0, "level3"),},
	state = "active"},
}

local lGuns = {
	{id = "sgun1",
	pos = vector(20, 2),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 10,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_left_dormant", ["active"] = "gun_left_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	shootingBehaviour = firingBehaviour(
		{pos = vector(19.6, 2.3) * levelAttribs.blockSize,
		vel = vector(-levelAttribs.vel_bullet_slow, 0),
		timeLastBullet = 2.5,
		initialTimeLastBullet = 2.5,
		timeBetweenBullets = {2.5, 0.5},
		currentStage = 1},
		delayedFire, delayedReset, delayedSoundReady),
	state = "dormant"},
	
	{id = "sgun2",
	pos = vector(20, 3),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 10,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_left_dormant", ["active"] = "gun_left_active"},
	--sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	shootingBehaviour = firingBehaviour({pos = vector(19.6, 3.3) * levelAttribs.blockSize, vel = vector(-levelAttribs.vel_bullet_slow, 0),
		timeLastBullet = 1.5, timeBetweenBullets = 1.5}, newFire, newReset, newSoundReady),
	state = "dormant"},

	{id = "sgun3",
	pos = vector(20, 4),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 10,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_left_dormant", ["active"] = "gun_left_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	shootingBehaviour = firingBehaviour(
		{pos = vector(19.6, 4.3) * levelAttribs.blockSize,
		vel = vector(-levelAttribs.vel_bullet_slow, 0),
		timeLastBullet = 1.5,
		initialTimeLastBullet = 1.5,
		timeBetweenBullets = {2.5, 0.5},
		currentStage = 1},
		delayedFire, delayedReset, delayedSoundReady),
	state = "dormant"},

	{id = "atriumgun1",
	pos = vector(24, 8),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	shootingBehaviour = firingBehaviour({pos = vector(24.3, 9) * levelAttribs.blockSize, vel = vector(0, levelAttribs.vel_bullet_standard), timeLastBullet = 0.7, timeBetweenBullets = 0.7}, newFire, newReset, newSoundReady),
	state = "dormant"},
	
	{id = "atriumgun2",
	pos = vector(25, 8),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "atriumgun3",
	pos = vector(28, 8),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},
	
	{id = "atriumgun4",
	pos = vector(29, 8),
	size = vector(1, 1),
	bulletVel = vector(0, levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, 1),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_down_dormant", ["active"] = "gun_down_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun1",
	pos = vector(10, 18),
	size = vector(1, 1),
	bulletVel = vector(0, -levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, -0.37),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun2",
	pos = vector(14, 18),
	size = vector(1, 1),
	bulletVel = vector(0, -levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, -0.37),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun3",
	pos = vector(18, 18),
	size = vector(1, 1),
	bulletVel = vector(0, -levelAttribs.vel_bullet_standard),
	bulletOffset = vector(0.3, -0.37),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_up_dormant", ["active"] = "gun_up_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun4",
	pos = vector(6, 14),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_standard, 0),
	bulletOffset = vector(1, 0.3),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},

	{id = "gun5",
	pos = vector(5, 11),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_standard, 0),
	bulletOffset = vector(1, 0.3),
	bulletLife = 3,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"}
}

local lEnemies = {
		{id = "jailer2",
		pos = vector(28.9,  20),
		category = "jailer_melee",
		speed = levelAttribs.vel_jailer/2,
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		texture = {["dormant"] = "meleejailer", ["attacking_path"] = "meleejailer_flash", ["attacking_direct"] = "meleejailer_red", ["dead"] = "meleejailer_death" },
		deathBehaviour = {deathBehaviour("jailer2", "door3", "doorswitch_open", 0),	deathBehaviour("jailer3", "mover6", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover7", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover8", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover9", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover10", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover11", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover12", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover13", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover14", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover15", "moverswitch_on", 0),
			deathBehaviour("jailer3", "mover16", "moverswitch_on", 0),},

		state = "dormant"
		},
		{id = "jailer3",
		pos = vector(5.1,  27),
		category = "jailer_melee",
		speed = levelAttribs.vel_jailer/3,
		texture = {["dormant"] = "meleejailer", ["attacking_path"] = "meleejailer_flash", ["attacking_direct"] = "meleejailer_red", ["dead"] = "meleejailer_death" },
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		deathBehaviour = {deathBehaviour("jailer3", "door4", "doorswitch_open", 0),			},
		state = "dormant"
		},
		{id = "jailer4",
		pos = vector(21, 18),
		category = "jailer_melee",
		speed = levelAttribs.vel_jailer/2,
		texture = {["dormant"] = "meleejailer", ["attacking_path"] = "meleejailer_flash", ["attacking_direct"] = "meleejailer_red", ["dead"] = "meleejailer_death" },
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		deathBehaviour = {deathBehaviour("jailer4", "door6", "doorswitch_open", 0),
						deathBehaviour("jailer4", "door7", "doorswitch_open", 0),
						deathBehaviour("jailer4", "gun1", "gunswitch_off", 0),
						deathBehaviour("jailer4", "gun2", "gunswitch_off", 0),
						deathBehaviour("jailer4", "gun3", "gunswitch_off", 0),
						deathBehaviour("jailer4", "gun4", "gunswitch_off", 0),
						deathBehaviour("jailer4", "gun5", "gunswitch_off", 0),
						deathBehaviour("jailer4", "mover17", "moverswitch_off", 0),},
		state = "dormant"},
	}

local lMovers = { 
		--	{start = vector(11, 2),
		--	size = vector(1, 1),
		--	texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
		--	sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
		--	category = "mover",
		--	id = "mover1",
		--	status = "dormant",
		--	speed = 30,
		--	dir = vector(0, 1),
		--	moveExtents = {vector(11, 2), vector(11, 5)}},

		--	{start = vector(6, 4),
		--	size = vector(1, 1),
		--	texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
		--	sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.3}},
		--	category = "mover",
		--	id = "mover2",
		--	status = "active",
		--	speed = 30,
		--	dir = vector(0, 1),
		--	moveExtents = {vector(6, 2), vector(6, 5)}},

		--	{start = vector(7, 2),
		--	size = vector(1, 1),
		--	texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
		--	sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.3}}, 
		--	category = "mover",
		--	id = "mover3",
		--	status = "active",
		--	speed = 30,
		--	dir = vector(0, 1),
		--	moveExtents = {vector(7, 2), vector(7, 5)}},
				
			{start = vector(29, 13),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover4",
			status = "dormant",
			speed = 50,
			dir = vector(-1, 0),
			moveExtents = {vector(29, 13), vector(24, 13)}},
				
				{start = vector(24, 16),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover5",
			status = "dormant",
			speed = 50,
			dir = vector(1, 0),
			moveExtents = {vector(24, 16), vector(29, 16)}},
			
				{start = vector(11, 23),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover6",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(11, 21), vector(11, 27)}},
				{start = vector(12, 23.5),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover7",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(12, 21), vector(12, 27)}},
				{start = vector(13, 24),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover8",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(13, 21), vector(13, 27)}},
				{start = vector(14, 24.5),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover9",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(14, 21), vector(14, 27)}},
				{start = vector(15, 25),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover10",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(15, 21), vector(15, 27)}},
					{start = vector(16, 25.5),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover11",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(16, 21), vector(16, 27)}},
					{start = vector(17, 26),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover12",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(17, 21), vector(17, 27)}},
					{start = vector(18, 26.5),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover13",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, 1),
			moveExtents = {vector(18, 21), vector(18, 27)}},
					
					{start = vector(19, 27),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover14",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, -1),
			moveExtents = {vector(19, 27), vector(19, 21)}},
					{start = vector(20, 26.5),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover15",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, -1),
			moveExtents = {vector(20, 27), vector(20, 21)}},

					{start = vector(21, 26),
			size = vector(1, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover16",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast,
			dir = vector(0, -1),
			moveExtents = {vector(21, 27), vector(21, 21)}},

				{start = vector(6, 15),
			size = vector(2, 1),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover17",
			status = "dormant",
			speed = levelAttribs.moverSpeed_fast/2,
			dir = vector(0, 1),
			moveExtents = {vector(6, 15), vector(6, 18)}},

	--			{start = vector(24, 10.8),
	--		size = vector(2, 1),
	--		texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
	--		category = "mover",
	--		id = "mover17",
	--		status = "dormant",
	--		speed = levelAttribs.levelAttribs.moverSpeed_fast/2,
	--		dir = vector(0, 1),
	--		moveExtents = {vector(6, 15), vector(6, 18)}},
		}

local walls = {
		{start = vector(26, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(27, 2),
		size = vector(2, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(29, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},
			
		{start = vector(3, 4),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch0", "sgun1", "gunswitch_on", 0),
					collisionBehaviour("switch0", "sgun2", "gunswitch_on", 0),
					collisionBehaviour("switch0", "sgun3", "gunswitch_on", 0),
					collisionBehaviour("switch0", "door0", "doorswitch_open", 0)
					},
		id = "switch0"},

		{start = vector(20, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "door"},
		id = "door0"},
		{start = vector(4, 2),
		size = vector(1, 3),
		texture = {["dormant"] = "barrel"},
		shape = "quad"},
		{start = vector(6, 5),
		size = vector(13, 1),
		texture = {["dormant"] = "barrel"},
		shape = "quad"},
		{start = vector( 2, 1),
		size = vector(20, 1),
		texture = {["dormant"] = "northwall"}},
		{start = vector( 1,  2),
		size = vector(1,  4),
		texture = {["dormant"] = "westwall"}},
		{start = vector(1, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestwall"}},
		{start = vector(2, 6),
		size = vector(20, 1),
		texture = {["dormant"] = "southwall"}},
		{start = vector(1, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestwall"}},
		{start = vector(22, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},
		{start = vector(22, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
		{start = vector(22, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastwall"}},
		{start = vector(22, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastwall"}},
		{start = vector(3, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "circle"},
		{start = vector(21, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {
					collisionBehaviour("switch1", "sgun1", "gunswitch_off", 0),
					collisionBehaviour("switch1", "sgun2", "gunswitch_off", 0),
					collisionBehaviour("switch1", "sgun3", "gunswitch_off", 0),
					collisionBehaviour("switch1", "door1", "doorswitch_open", 0),},
		id = "switch1"},
			{start = vector(22, 3),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door1"},


		
			{start = vector(23, 1),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestwall"}},
			{start = vector(23, 5),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestinnerwall"}},
			{start = vector(23,  2),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestinnerwall"}},

			{start = vector(23, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestwall"}},
			{start = vector(24, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southwall"}},
	{start = vector(25, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerwall"}},
		
		{start = vector(29, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southwall"}},
	  {start = vector(28, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
		
			{start = vector(30,  2),
		size = vector(1,  4),
		texture = {["dormant"] = "eastwall"}},
			{start = vector(24,  1),
		size = vector(6,  1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(30, 1),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastwall"}},
			{start = vector(30, 6),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastwall"}},
			{start = vector(26, 6),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door2"},
			{start = vector(25, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
	
		behaviour = {collisionBehaviour("checkpoint1", "mainwait", "checkpoint", 0), collisionBehaviour("checkpoint1", "door2", "doorswitch_open", 0),
			collisionBehaviour("checkpoint1", "mover4", "moverswitch_on", 0), collisionBehaviour("checkpoint1", "mover5", "moverswitch_on", 0),
			collisionBehaviour("checkpoint1", "door1", "doorswitch_close", 0), collisionBehaviour("checkpoint1", "mover1", "moverswitch_off", 0),
			collisionBehaviour("checkpoint1", "mover2", "moverswitch_off", 0), collisionBehaviour("checkpoint1", "mover3", "moverswitch_off", 0),
			collisionBehaviour("checkpoint1", "atriumgun1", "gunswitch_on", 0), collisionBehaviour("checkpoint1", "atriumgun2", "gunswitch_on", 0),
			collisionBehaviour("checkpoint1", "atriumgun3", "gunswitch_on", 0), collisionBehaviour("checkpoint1", "atriumgun4", "gunswitch_on", 0)},
		id="checkpoint1"},
			
			{start = vector(24, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwall"}},
	  {start = vector(25, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestinnerwall"}},
    {start = vector(28, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastinnerwall"}},
	
			{start = vector(29, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(30, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastwall"}},
			{start = vector(23, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestwall"}},


			{start = vector(30, 8),
		size = vector(1,  5),
		texture = {["dormant"] = "eastwall"}},
	{start = vector(30, 13),
		size = vector(1,  1),
		texture = {["dormant"] = "eastwallendingdown"}},
			
			{start = vector(23, 8),
		size = vector(1,  5),
		texture = {["dormant"] = "westwall"}},
	    {start = vector(23, 13),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestinnerwall"}},
      {start = vector(30, 16),
		size = vector(1,  1),
		texture = {["dormant"] = "eastwallendingup"}},
			{start = vector(30, 17),
		size = vector(1,  4),
		texture = {["dormant"] = "eastwall"}},
			{start = vector(23, 17),
		size = vector(1,  4),
		texture = {["dormant"] = "westwall"}},
		{start = vector(23, 16),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestinnerwall"}},
		
			{start = vector(30, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastwall"}},
			{start = vector(23, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestwall"}},
			{start = vector(24, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southwall"}},
	    {start = vector(25, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestinnerwall"}},
		  {start = vector(29, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southwall"}}, 
			{start = vector(28, 21),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastinnerwall"}},
			{start = vector(26, 21),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door3",
		},

		{start = vector(24, 19),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "quad"},
		
			{start = vector(24, 20),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch2", "jailer2", "jailerswitch", 0), collisionBehaviour("switch2", "door2", "doorswitch_close", 0)},
		id = "switch2"},
	
		{start = vector(24, 27),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
		behaviour = {collisionBehaviour("extracheckpoint", "mainwait", "checkpoint", 0), 
			collisionBehaviour("extracheckpoint", "door3", "doorswitch_close", 0),
			collisionBehaviour("extracheckpoint", "mover4", "moverswitch_off", 0),
			collisionBehaviour("extracheckpoint", "mover5", "moverswitch_off", 0),
			collisionBehaviour("extracheckpoint", "atriumgun1", "gunswitch_off", 0),
			collisionBehaviour("extracheckpoint", "atriumgun2", "gunswitch_off", 0),
			collisionBehaviour("extracheckpoint", "atriumgun3", "gunswitch_off", 0),
			collisionBehaviour("extracheckpoint", "atriumgun4", "gunswitch_off", 0),
			},
		id="extracheckpoint"},

	{start = vector(28, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(29, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},

		{start = vector(22, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(23, 23),
		size = vector(2, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(25, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},



			{start = vector(30, 22),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastwall"}},
	{start = vector(28, 22),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},
		
			{start = vector(29, 22),
		size = vector(1, 1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(30, 23),
		size = vector(1, 5),
		texture = {["dormant"] = "eastwall"}},
			{start = vector(30, 28),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastwall"}},
			{start = vector(5, 28),
		size = vector(25, 1),
		texture = {["dormant"] = "southwall"}},
			{start = vector(23, 22),
		size = vector(2, 1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(25, 22),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerwall"}},
			{start = vector(22, 21),
		size = vector(1, 1),
		texture = {["dormant"] = "eastwall"}},

			{start = vector(22, 20),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastwall"}},
		
			{start = vector(22, 22),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},
			{start = vector(5, 20),
		size = vector(17, 1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(4, 20),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestwall"}},
			{start = vector(4, 27),
		size = vector(1, 1),
		texture = {["dormant"] = "westwall"}},
		
		{start = vector(4, 26),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerwall"}},
			
			{start = vector(4, 21),
		size = vector(1, 2),
		texture = {["dormant"] = "westwall"}},
	{start = vector(4, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerwall"}},
			
			{start = vector(4, 28),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestwall"}},
			{start = vector(3, 24),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door4",},
			{start = vector(5, 21),
		size = vector(1, 1),
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		behaviour = {collisionBehaviour("switch3", "jailer3", "jailerswitch", 0), collisionBehaviour("switch3", "door3", "doorswitch_close", 0)},
		id = "switch3"},

			{start = vector(3, 28),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastwall"}},
			{start = vector(3, 15),
		size = vector(1, 8),
		texture = {["dormant"] = "eastwall"}},
	    {start = vector(3, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
			{start = vector(3, 23),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},
			{start = vector(3, 26),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
      {start = vector(3, 27),
		size = vector(1, 1),
		texture = {["dormant"] = "eastwall"}},	
			{start = vector(1, 8),
		size = vector(1, 20),
		texture = {["dormant"] = "westwall"}},	
			{start = vector(1, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestwall"}},	
			{start = vector(3, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastwall"}},	
			{start = vector(2, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwall"}},	
			{start = vector(3, 8),
		size = vector(1, 3),
		texture = {["dormant"] = "eastwall"}},	
    	{start = vector(3, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},	
			
			{start = vector(1, 28),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestwall"}},	
			{start = vector(2, 28),
		size = vector(1,  1),
		texture = {["dormant"] = "southwall"}},	
			{start = vector(3, 12),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door5",},

			{start = vector(2, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
		behaviour = {collisionBehaviour("checkpoint2", "mainwait", "checkpoint", 0), collisionBehaviour("checkpoint2", "door5", "doorswitch_open", 0),
			collisionBehaviour("checkpoint2", "door4", "doorswitch_close", 0),
			collisionBehaviour("checkpoint2", "mover17", "moverswitch_on", 0),
			collisionBehaviour("checkpoint2", "mover4", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover5", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover6", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover7", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover8", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover9", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover10", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover11", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover12", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover13", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover14", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover15", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "mover16", "moverswitch_off", 0),
			collisionBehaviour("checkpoint2", "gun1", "gunswitch_on", 0),
			collisionBehaviour("checkpoint2", "gun2", "gunswitch_on", 0),
			collisionBehaviour("checkpoint2", "gun3", "gunswitch_on", 0),
			collisionBehaviour("checkpoint2", "gun4", "gunswitch_on", 0),
			collisionBehaviour("checkpoint2", "gun5", "gunswitch_on", 0),
			collisionBehaviour("checkpoint2", "atriumgun1", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "atriumgun2", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "atriumgun3", "gunswitch_off", 0),
			collisionBehaviour("checkpoint2", "atriumgun4", "gunswitch_off", 0),
			},	
		id="checkpoint2"},
			{start = vector(22, 19),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastwall"}},
			{start = vector(22, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastwall"}},
			{start = vector(22, 8),
		size = vector(1,  5),
		texture = {["dormant"] = "eastwall"}},
			{start = vector(22, 13),
		size = vector(1,  1),
		texture = {["dormant"] = "northeastinnerwall"}},
			
			{start = vector(22, 17),
		size = vector(1,  2),
		texture = {["dormant"] = "eastwall"}},
	    {start = vector(22, 16),
		size = vector(1,  1),
		texture = {["dormant"] = "southeastinnerwall"}},
			
			{start = vector(4, 8),
		size = vector(1,  3),
		texture = {["dormant"] = "westwall"}},
			{start = vector(4, 11),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestinnerwall"}},
		
		  {start = vector(4, 14),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestinnerwall"}},
			
				{start = vector(4, 15),
		size = vector(1,  4),
		texture = {["dormant"] = "westwall"}},
			{start = vector(5, 7),
		size = vector(17,  1),
		texture = {["dormant"] = "northwall"}},
			{start = vector(5, 19),
		size = vector(17,  1),
		texture = {["dormant"] = "southwall"}},
			{start = vector(4, 19),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestwall"}},
			{start = vector(4, 7),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestwall"}},
		
		{start = vector(5, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "quad"},
			{start = vector(22, 14),
		size = vector(2, 2),
		texture = {["dormant"] = "door"},
		id = "door6",},
			{start = vector(30, 14),
		size = vector(1, 2),
		texture = {["dormant"] = "door"},
		id = "door7",},
			{start = vector(21, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch4", "jailer4", "jailerswitch", 0),
			collisionBehaviour("switch4", "door5", "doorswitch_close", 0),},
		id = "switch4"},

	}
	
local floors = {	{start = vector(2, 2),
		size = vector(28, 26),
		texture = "floor"},
		{start = vector(30, 14),
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
