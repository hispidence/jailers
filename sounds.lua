function getSoundByID(id)
	for i, v in ipairs(lSounds) do
		if v.id == id then return i end
	end
	return 0
end

lSounds = {
 {id = "player_move",
	fname = "/sounds/player_move.wav",
	soundData = nil},
 {id = "jailer_pathingbeep",
	fname = "/sounds/jailer_pathingbeep.wav",
	soundData = nil},

 {id = "superjailer_breath",
	fname = "/sounds/superjailer_breath.wav",
	soundData = nil},
 
 {id = "checkpoint_activate",
	fname = "/sounds/checkpoint_activate.wav",
	soundData = nil},
 {id = "switch_activate",
	fname = "/sounds/switch_activate.wav",
	soundData = nil},
 {id = "player_death",
	fname = "/sounds/player_death.wav",
	soundData = nil},
 {id = "jailer_death",
	fname = "/sounds/jailer_death.wav",
	soundData = nil},
 {id = "gun_fire",
	fname = "/sounds/gun_fire.wav",
	soundData = nil},
 {id = "mover_stomp",
	fname = "/sounds/mover_stomp.wav",
	soundData = nil},

}
