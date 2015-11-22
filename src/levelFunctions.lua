-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2015
--
--
-- levelFunctions.lua
--
-- Common functions for objects; i.e. what do do when they collide with
-- the player.
-------------------------------------------------------------------------------



gm = require("src/gameManager")

g_collisionBehaviours = {
	endLevel =
	function(args)
    return function()
      e1 = jlEvent(args.sender, args.target, args.data, "endlevel")
      gm:sendEvent(e1)	
    end
	end,

	checkpoint =
	function(args)
    return function()
      e1 = jlEvent(args.sender, args.sender, "active", "endlevel")
      e2 = jlEvent(args.sender, args.target, "none", "save")
      gm:sendEvent(e1)
      gm:sendEvent(e2)
    end
	end,

	doorswitch_open = 
	function(args)
    return function()
			e1 = jlEvent(args.sender, args.target, "none", "removeblock", args.data)
			e2 = jlEvent(args.sender, args.sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
    end
	end,
  
  doorswitch_close = 
  function(args)
    return function()
			e1 = jlEvent(args.sender, args.target, "none", "addblock", args.data)
			e2 = jlEvent(args.sender, args.sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
    end
  end
}



--[[
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
]]--

