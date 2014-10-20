vector = require("hump.vector")
gm = require("gameManager")

local level = {}

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
	vel_bullet_standard = 45,
	life_bullet_standard = 10,
	offset = 16/2,
	moverSpeed_fast = 80,
	blockSize = 16,
	width = 40,
	height = 30,
	initialCamera = vector(0, 0),
	blockSize = 16,
	enemySize = 14,
	scaledEnemySize = 14,-- * scale,
	scaledBlockSize = 16,-- * scale,
	playerSpeed = 150,
	playerStart = vector(4, 4),
	playerSounds = { ["dead"] = {id = "player_death", repeating = "false", time = 1}, ["moving_vertical"] = {id = "player_move", repeating = true, time = 0.3}, ["moving_horizontal"] = {id = "player_move", repeating = true, time = 0.3},}
}

local anims = {
	["jailer_melee"] = {["attacking_path"] = {14, 14, 0.5, 2, "loop"}, ["dead"] = {14, 14, 0.03, 12, "once"}}
}

local lTriggers = {
	{id = "trigger1",
	pos = vector(11, 16.5),
	size = vector(2, 1),
	behaviour = {collisionBehaviour("trigger1", "main",	"endlevel", 0, "level2")},
	state = "active"},
}

local lGuns = {
	{id = "gun1",
	pos = vector(2, 12),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_standard, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = 4,
	bulletTime = 0.7,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},
	
	{id = "gun2",
	pos = vector(2, 14),
	size = vector(1, 1),
	bulletVel = vector(levelAttribs.vel_bullet_standard, 0),
	bulletOffset = vector(1.0, 0.3),
	bulletLife = 4,
	bulletTime = 2.1,
	texture= {["dormant"] = "gun_right_dormant", ["active"] = "gun_right_active"},
	sound = {["active"] = {id = "gun_fire", repeating = "true", time = 0.7}, },
	bulletTexture= {["dormant"] = "bullet", ["active"] = "bullet"},
	state = "dormant"},
}

local lEnemies = {
		{id = "jailer1",
		pos = vector(22.5,  14.5),
		category = "jailer_melee",
		speed = levelAttribs.vel_jailer * (2/3),
		sound = {["attacking_path"] = {id = "jailer_pathingbeep", repeating = "true", time = 1}, ["attacking_direct"] = {id = "jailer_pathingbeep", repeating = "true", time = 0.5},
			["dead"] = {id = "jailer_death", repeating = "false", time = 0.1}},
		texture = {["dormant"] = "meleejailer", ["attacking_path"] = "meleejailer_flash", ["attacking_direct"] = "meleejailer_red", ["dead"] = "meleejailer_death" },
		deathBehaviour = {deathBehaviour("jailer1", "door1", "doorswitch_open", 0)},
		state = "dormant"
		},
	}

local lMovers = { {start = vector(17, 4),
			size = vector(2, 2),
			texture = {["dormant"] = "spikeblock", ["active"] = "spikeblockred"},
			sound = {["stomp"] = {id = "mover_stomp", repeating = "true", time = 0.5}},
			category = "mover",
			id = "mover1",
			status = "dormant",
			speed = 30,
			dir = vector(-1, 0),
			moveExtents = {vector(17, 4), vector(2, 4)}},
		}

local walls = {
		{start = vector(5, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"}},

		{start = vector(6, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_middle"}},

		{start = vector(7, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"}},


		{start = vector(2, 1),
		size = vector(15, 1),
		texture = {["dormant"] = "northwall"}},

		{start = vector( 1,  2),
		size = vector(1,  6),
		texture = {["dormant"] = "westwall"}},

		{start = vector(1, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestwall"}},

		{start = vector(2, 8),
		size = vector(15, 1),
		texture = {["dormant"] = "southwall"}},

		{start = vector(1, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestwall"}},

		{start = vector(17, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "eastwall"}},

    {start = vector(17, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastinnerwall"}},

		{start = vector(17, 7),
		size = vector(1, 1),
		texture = {["dormant"] = "eastwall"}},
  
  	{start = vector(17, 6),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
	
		{start = vector(17, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastwall"}},

		{start = vector(17, 8),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastwall"}},

		{start = vector(3, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "circle"},

		{start = vector(11, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch1", "mover1", "moverswitch_on", 0)},
		id = "switch1"},
		
		{start = vector(17, 10),
		size = vector(2, 1),
		texture = {["dormant"] = "door"},
		id = "door2"},
		
   		{start = vector(19, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "checkpointdormant", ["active"] = "checkpointactive"},
		sound = {["active"] = {id = "checkpoint_activate", repeating = "once", time = 1}},
	    behaviour = {collisionBehaviour("checkpoint1", "mainwait", "checkpoint", 0),
    		collisionBehaviour("checkpoint1", "door1", "doorswitch_open", 0),
     	 	collisionBehaviour("checkpoint1", "door2", "doorswitch_open", 0),
			collisionBehaviour("checkpoint1", "gun1", "gunswitch_on", 0), 
			collisionBehaviour("checkpoint1", "gun2", "gunswitch_on", 0),
			collisionBehaviour("checkpoint1", "mover2", "moverswitch_off", 0),},
		id="checkpoint1"},
		
    {start = vector(19, 13),
		size = vector(2, 1),
		texture = {["dormant"] = "door"},
		id = "door1"},

    {start = vector(21, 14),
		size = vector(1, 2),
		texture = {["dormant"] = "barrel"}},
		
		{start = vector(18, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "westwall"}},
		
    {start = vector(18, 3),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestinnerwall"}},
		
		{start = vector(18,  7),
		size = vector(1,  2),
		texture = {["dormant"] = "westwall"}},
		
    {start = vector(18,  6),
		size = vector(1,  1),
		texture = {["dormant"] = "southwestinnerwall"}},
		
		{start = vector(18,  9),
		size = vector(1,  1),
		texture = {["dormant"] = "northwestinnerwall"}},

		{start = vector(18, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestwall"}},

		{start = vector(18, 12),
		size = vector(1, 5),
		texture = {["dormant"] = "westwall"}},
	 
	  {start = vector(18, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestinnerwall"}},

		{start = vector(18, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestwall"}},

		{start = vector(19, 1),
		size = vector(11, 1),
		texture = {["dormant"] = "northwall"}},

    {start = vector(29,2),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch2", "jailer1", "jailerswitch", 0)},
		id = "switch2"},
		
		{start = vector(19, 16),
		size = vector(11, 1),
		texture = {["dormant"] = "southwall"}},

		{start = vector(30, 1),
		size = vector(1, 1),
		texture = {["dormant"] = "northeastwall"}},

		{start = vector(30, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastwall"}},

		{start = vector(30, 2),
		size = vector(1, 14),
		texture = {["dormant"] = "eastwall"}},

		{start = vector(19, 5),
		size = vector(2, 2),
		texture = {["dormant"] = "barrel"}},

		{start = vector(19, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(20, 9),
		size = vector(8, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(28, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},

		{start = vector(20, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(21, 11),
		size = vector(8, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(29, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},
			
		{start = vector(21, 13),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(22, 13),
		size = vector(6, 1),

		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(28, 13),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},

		{start = vector(19, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(20, 2),
		size = vector(8, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},

		{start = vector(28, 2),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},

    {start = vector(1, 9),
		size = vector(1, 1),
		texture = {["dormant"] = "northwestwall"},
		shape = "quad"},
	 
    {start = vector(2, 9),
		size = vector(16, 1),
		texture = {["dormant"] = "northwall"},
		shape = "quad"},
		
    {start = vector(1, 10),
		size = vector(1, 6),
		texture = {["dormant"] = "westwall"},
		shape = "quad"},
		
    {start = vector(1, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southwestwall"},
		shape = "quad"},
		
		{start = vector(2, 16),
		size = vector(8, 1),
		texture = {["dormant"] = "southwall"},
		shape = "quad"},
		
		{start = vector(10, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southwallendingright"},
		shape = "quad"},
		
		{start = vector(13, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southwallendingleft"},
		shape = "quad"},
   	
   	{start = vector(14, 16),
		size = vector(3, 1),
		texture = {["dormant"] = "southwall"},
		shape = "quad"}, 
    
    {start = vector(17, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastinnerwall"}},
		
    {start = vector(17, 16),
		size = vector(1, 1),
		texture = {["dormant"] = "southeastwall"}},

    {start = vector(17, 12),
		size = vector(1, 4),
		texture = {["dormant"] = "eastwall"},
		shape = "quad"},

		{start = vector(2, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},
		
		{start = vector(3, 11),
		size = vector(6, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},
	
		{start = vector(9, 11),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},
		
		{start = vector(2, 13),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},
		
	  {start = vector(3, 13),
		size = vector(6, 1),
		texture = {["dormant"] = "bookshelf_middle"},
		shape = "quad"},
		
	  {start = vector(9, 13),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},
		
		{start = vector(6, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_left"},
		shape = "quad"},

		{start = vector(7, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "bookshelf_right"},
		shape = "quad"},
		
		{start = vector(15, 10),
		size = vector(1, 1),
		texture = {["dormant"] = "barrel"},
		shape = "quad"},
		
		{start = vector(2, 10),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch3", "door3", "doorswitch_open", 0)},
		id = "switch3"},
		
		{start = vector(5, 15),
		size = vector(1, 1),
		texture = {["dormant"] = "switchoff", ["off"] = "switchon"},
		sound = {["off"] = {id = "switch_activate", repeating = "false", time = 1}},
		behaviour = {collisionBehaviour("switch4", "door4", "doorswitch_open", 0)},
		id = "switch4"},
		
    {start = vector(7, 14),
		size = vector(1, 1),
		texture = {["dormant"] = "door"},
		id = "door3"},
    
    {start = vector(11, 16),
		size = vector(2, 1),
		texture = {["dormant"] = "door"},
		id = "door4"},

	}
	
local floors = {	{start = vector(2, 2),
		size = vector(28, 14),
		texture = "floor"},
		{start = vector(11, 16),
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
