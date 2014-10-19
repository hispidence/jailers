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
	local timeLastBullet = self.data["timeLastBullet"]
	local timeBetweenBullets = self.data["timeBetweenBullets"]
	
	if timeLastBullet > timeBetweenBullets then
		local pos = theGun:getPos():clone()
		local vel = (thePlayer:getPos() - pos)
		vel = vel:normalized()

		pos = pos + vector(0.5, 6.5)

		vel = vel * self.data["bulletSpeed"]


		theGun:addBullet(pos, vel)
		self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
	end
	self.data["timeLastBullet"] = self.data["timeLastBullet"] + dt
end

local function fire_multidirectional(self, dt, theGun)
	timeLastBullet = self.data["timeLastBullet"]
	timeBetweenBullets = self.data["timeBetweenBullets"]
	
	for i, v in ipairs(self.data["bulletDirections"]) do
		local pos
		local vel
		pos = self.data["bulletOffset"]:clone() + theGun:getPos()
		vel = self.data["vel"] * v
		if timeLastBullet >= timeBetweenBullets then
			theGun:addBullet(pos, vel)
			self.data["timeLastBullet"] = timeLastBullet - timeBetweenBullets
		end
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
	vel_jailer = 5, 
	vel_bullet_standard = 60,
	offset = 16/2,
	moverSpeed = 3,
	blockSize = 16,
	width = 40,
	height = 40,
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

local anims = {
	["jailer_melee"] = {["attacking_path"] = {14, 14, 0.5, 2, "loop"}, ["dead"] = {14, 14, 0.03, 12, "once"}}
}

local anims = {
	["jailer_ranged"] = {["attacking_path"] = {16, 16, 0.5, 2, "loop"}, ["dead"] = {16, 16, 0.045, 8, "once"}}
}

local lTriggers = {
	{id = "trigger1",
	pos = vector(10, 10),
	size = vector(1, 2),
	behaviour = {collisionBehaviour("trigger1",	"main",	"movecamera", 0, {vector(0, 0), 2}), collisionBehaviour("trigger1",  "trigger2",	"triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger2",
	pos = vector(7, 10),
	size = vector(1, 2),
	behaviour = {collisionBehaviour("trigger2",	"main",	"movecamera", 0, {vector(12, -9), 2}), collisionBehaviour("trigger2",  "trigger1",	"triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger3",
	pos = vector(5, 14),
	size = vector(2, 1),
	ignoresBullets = true,
	behaviour = {collisionBehaviour("trigger3",	"main",	"movecamera", 0, {vector(12, -9), 2}), collisionBehaviour("trigger3",  "trigger4",	"triggerswitch_on", 0),},
	state = "active"},

	{id = "trigger4",
	pos = vector(5, 17),
	size = vector(2, 1),
	ignoresBullets = true,
	behaviour = {collisionBehaviour("trigger4",	"main",	"movecamera", 0, {vector(12, -15), 2}), collisionBehaviour("trigger4",  "trigger3",	"triggerswitch_on", 0),},
	state = "active"},


	{id = "trigger5",
	pos = vector(4, 33.5),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger7",	"main",	"endlevel", 0, "level4"),},
	state = "active"},
	--	{id = "trigger2",
	--	pos = vector(7, 10),
	--	size = vector(2, 1),
	--	behaviour = {collisionBehaviour("trigger2",	"main",	"movecamera", 0, {vector(-0, -5), 2}), collisionBehaviour("trigger2",	"trigger1",	"triggerswitch_on", 0, {vector(-0, -5), 2}),},
	--	state = "active"},
}

local lGuns = {
	{id = "gun1",
	pos = vector(16, 8),
	size = vector(1, 1),
	--bulletVel = vector(1.5, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = 4,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_8directions_dormant", ["active"] = "gun_8directions_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	ignoresBullets = true,
	invisible = false,	
	shootingBehaviour = firingBehaviour(
	 			{nBarrels = 7,
				vel = levelAttribs.vel_bullet_standard,
--				bulletPositions = {							
--					levelAttribs.blockSize * vector(1, 0.3),
--					levelAttribs.blockSize * vector(0.3, 1),
--					levelAttribs.blockSize * vector(0.3, -0.35),
--					levelAttribs.blockSize * vector(1, 1),
--					levelAttribs.blockSize * vector(1, -0.35),
--					levelAttribs.blockSize * vector(-0.35, 1),
--					levelAttribs.blockSize * vector(-0.35, -0.355),
--				},

				bulletOffset = vector(levelAttribs.blockSize * 0.3, levelAttribs.blockSize * 0.3),

				bulletDirections = {
					vector(1, 0),
					vector(0, 1),
					vector(0, -1),
					vector(0.70711, 0.70711),
					vector(0.70711, -0.70711),
					vector(-0.70711, 0.70711),
					vector(-0.70711, -0.70711),
				},
				timeLastBullet = 1,
				timeBetweenBullets = 0.5,
		},
		fire_multidirectional,
		reset_standard,
		soundReady_standard
	),

	state = "dormant"},

	{id = "gun2",
	pos = vector(2, 14),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_standard, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = 3,
	bulletTime = 2.1,
	invisible = true,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	shootingBehaviour = firingBehaviour({jailerSize = 1 * levelAttribs.blockSize, timeLastBullet = 0.25, timeBetweenBullets = 0.25, bulletSpeed = 2},
	fire_targeted, reset_standard, soundReady_standard),
	state = "dormant"},

}

local lEnemies = {
		{id = "jailer1",
		pos = vector(5.5, 29),
		category = "jailer_ranged",
		speed = levelAttribs.vel_jailer * (2/3),
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		texture = {["dormant"] = "rangedjailer", ["attacking_path"] = "rangedjailer_flash", ["attacking_direct"] = "rangedjailer_red", ["dead"] = "rangedjailer_death" },
		deathBehaviour = {deathBehaviour("jailer1", "door4", "doorswitch_open", 0), deathBehaviour("jailer1", "gun2", "gunswitch_off", 0)},
		behaviour = behaviour_moveAttachment,
		resetBehaviour = behaviour_moveAttachment_reset,
		bData = {timeSinceLast = .25, timeBetween = .25, otherID = "gun2"},
		ignoresBullets = true,
		state = "dormant",
		},
	}

local lMovers = { 
			{
			start = vector(2, 23),
			size = vector(1, 8),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover1",
			status = "dormant",
			speed = levelAttribs.moverSpeed,
			ignoresBullets = true,
			dir = vector(1, 0),
			moveExtents = {vector(2, 23), vector(5, 23)},},


			{start = vector(9, 23),
			size = vector(1, 8),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover2",
			status = "dormant",
			speed = levelAttribs.moverSpeed,
			ignoresBullets = true,
			dir = vector(-1, 0),
			moveExtents = {vector(9, 23), vector(6, 23)},},
		
			--{
	--		start = vector(2.5, 23),
	--		size = vector(1, 4),
	--		texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
	--		sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
	--		category = "mover",
	--		id = "mover3",
	--		status = "dormant",
	--		speed = 30,
	--		dir = vector(1, 0),
	--		moveExtents = {vector(2, 23), vector(5, 23)},},


	--		{start = vector(8.5, 23),
	--		size = vector(1, 4),
	--		texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
	--		sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
	--		category = "mover",
	--		id = "mover4",
	--		status = "dormant",
	--		speed = 30,
	--		dir = vector(-1, 0),
	--		moveExtents = {vector(9, 23), vector(6, 23)},},
		

		}

local walls = {
		{start = vector(5, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(6, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed2"}},

		{start = vector(7, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},

		{start = vector(2, 1),
		size = vector(6, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector( 1,  2),
		size = vector(1,  3),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(1, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(2, 5),
		size = vector(6, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(1, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

    	{start = vector(8, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

  		{start = vector(8, 4),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},
	
		{start = vector(8, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(8, 5),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(3, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "circle"},

		{start = vector(7, 4),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {--collisionBehaviour("switch1", "gun1", "gunswitch_on", 0),
					collisionBehaviour("switch1", "door1", "doorswitch_open", 0),
					collisionBehaviour("switch1", "door2", "doorswitch_open", 0),
					collisionBehaviour("switch1", "gun1", "gunswitch_on", 0),
					},
		id = "switch1"},
		
   		{start = vector(4, 10),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
	    behaviour = {collisionBehaviour("checkpoint1", "mainwait", "checkpoint", 0),
    		collisionBehaviour("checkpoint1", "door2", "doorswitch_close", 0),
			collisionBehaviour("switch1", "door3", "doorswitch_open", 0),
			collisionBehaviour("checkpoint1", "gun1", "gunswitch_off", 0),},
		id="checkpoint1"},
		
		{start = vector(9, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},

		{start = vector(9, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(10, 1),
		size = vector(13, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(23, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(23, 2),
		size = vector(1, 13),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(23, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(10, 15),
		size = vector(13, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(9, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(9, 12),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(9, 5),
		size = vector(1, 4),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(9, 13),
		size = vector(1, 2),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(9, 4),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},

		{start = vector(9, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},
	
		{start = vector(10, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed1"}},
		
		{start = vector(11, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed2"}},

		{start = vector(12, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "shelf_decayed3"}},

		{start = vector(13, 8),
		size = vector(3, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrel"}},

		{start = vector(8, 10),
		size = vector(2, 2),
		texture = {["dormant"] = "deepdoor"},
		id = "door2"},
	
    {start = vector(8, 3),
		size = vector(2, 1),
		texture = {["dormant"] = "deepdoor"},
		id = "door1"},

		{start = vector(3, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(4, 9),
		size = vector(5, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(8, 12),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},

		{start = vector(8, 13),
		size = vector(1, 2),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(8, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(3, 10),
		size = vector(1, 5),
		texture = {["dormant"] = "westdeepwall"}},
	
		{start = vector(3, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},
	
		{start = vector(4, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerdeepwall"}},
			
		{start = vector(7, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerdeepwall"}},
	
		{start = vector(4, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerdeepwall"}},
	
		{start = vector(2, 16),
		size = vector(2, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(1, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestdeepwall"}},

		{start = vector(1, 17),
		size = vector(1, 16),
		texture = {["dormant"] = "westdeepwall"}},

		{start = vector(1, 33),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestdeepwall"}},

		{start = vector(7, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerdeepwall"}},

		{start = vector(8, 16),
		size = vector(2, 1),
		texture = {["dormant"] = "northdeepwall"}},

		{start = vector(10, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastdeepwall"}},

		{start = vector(10, 17),
		size = vector(1, 16),
		texture = {["dormant"] = "eastdeepwall"}},

		{start = vector(10, 33),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastdeepwall"}},

		{start = vector(2, 33),
		size = vector(2, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(4, 33),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwallendingright"}},

		{start = vector(7, 33),
		size = vector(1, 1),
		texture = {["dormant"] = "southdeepwallendingleft"}},

		{start = vector(8, 33),
		size = vector(2, 1),
		texture = {["dormant"] = "southdeepwall"}},

		{start = vector(2, 22),
		size = vector(3, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(7, 22),
		size = vector(3, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "barrier"}},

		{start = vector(2, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed2"}},

		{start = vector(3, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed3"}},

		{start = vector(4, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed2"}},

		{start = vector(7, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(8, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed1"}},

		{start = vector(9, 31),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "shelf_decayed3"}},

    	{start = vector(5, 15),
		size = vector(2, 2),
		texture = {["dormant"] = "deepdoor"},
		id = "door3"},


    	{start = vector(5, 33),
		size = vector(2, 1),
		texture = {["dormant"] = "deepdoor"},
		id = "door4"},

		--{start = vector(5, 15),
		--size = vector(2,1),
		--texture = {["dormant"] = "door"},
		--id = "door3"},

		{start = vector(2, 17),
		size = vector(1, 1),
		ignoresBullets = true,
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {--collisionBehaviour("switch1", "gun1", "gunswitch_on", 0),
					collisionBehaviour("switch2", "jailer1", "jailerswitch", 0),
					collisionBehaviour("switch2", "gun2", "gunswitch_on", 0),
					collisionBehaviour("switch2", "door3", "doorswitch_close", 0),
					collisionBehaviour("switch2", "mover1", "moverswitch_on", 0),
					collisionBehaviour("switch2", "mover2", "moverswitch_on", 0),
					collisionBehaviour("switch2", "mover3", "moverswitch_on", 0),
					collisionBehaviour("switch2", "mover4", "moverswitch_on", 0),
					},
		id = "switch2"},
	}

	
local floors = {

		{start = vector(2, 2),
		size = vector(8, 3),
		texture = "floorboards"},
		{start = vector(10, 2),
		size = vector(13, 13),
		texture = "floorboards"},

		{start = vector(4, 10),
		size = vector(6, 7),
		texture = "floorboards"},

		{start = vector(2, 17),
		size = vector(8, 16),
		texture = "floorboards"},

		{start = vector(5, 33),
		size = vector(2, 1),
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
