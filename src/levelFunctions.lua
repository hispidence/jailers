-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- levelFunctions.lua
--
-- Common functions for objects; i.e. what do do when they collide with
-- the player.
-------------------------------------------------------------------------------



local gm = require("src/gameManager")

g_collisionBehaviours = {
	endLevel =
	function(args)
    return function()
      local e1 = jlEvent(args.sender, args.target, args.data, "endlevel")
      gm:sendEvent(e1)	
    end
	end,

	checkpoint =
	function(args)
    return function()
      local e1 = jlEvent(args.sender, args.sender, "active", "endlevel")
      local e2 = jlEvent(args.sender, args.target, "none", "save")
      gm:sendEvent(e1)
      gm:sendEvent(e2)
    end
	end,

  activate_something =
  function(args)
    return function()
      local e1 = jlEvent(args.sender, args.target, "active",  "changestate")
      gm:sendEvent(e1)
    end
	end,
  
	doorswitch_open = 
	function(args)
    return function()
			local e1 = jlEvent(args.sender, args.target, "none", "removeblock")
			local e2 = jlEvent(args.sender, args.sender, "switchOn", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
    end
	end,
  
  doorswitch_close = 
  function(args)
    return function()
			local e1 = jlEvent(args.sender, args.target, "none", "addblock")
			local e2 = jlEvent(args.sender, args.sender, "switchOff", "none")
			gm:sendEvent(e1)
			gm:sendEvent(e2)
    end
  end,


  move_camera =
	function(args)
    return function()
      -- In order to work with the mess that's the current event system, we
      -- have to mangle and pack the arguments in a different way to the other
      -- events.
      local data = {args.target, args.timer}
      local e1 = jlEvent(args.sender, "main",       "none",     "movecamera", data, 0)
      local e2 = jlEvent(args.sender, args.target,  "dormant",  "changestate", nil, 0)
      gm:sendEvent(e1)
      gm:sendEvent(e2)
      
    end
	end
}
