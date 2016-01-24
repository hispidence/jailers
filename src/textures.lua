-------------------------------------------------------------------------------
-- Copyright (C) Brad Ellis 2013-2016
--
--
-- textures.lua
--
-- Textures and sets thereof.
-------------------------------------------------------------------------------

TEXTURES_DIR = "textures/"

function getTextureByID(id)
	for i, v in ipairs(rTextures) do
		if v.id == id then return i end
	end
	return 0
end

-- Each key corresponds to an object state, and each value corresponds
-- to a texture ID from rTextures.
g_textureSets = {
  
  door_standard = {
    dormant = "door",
  },
  
  switch_standard = {
    dormant = "switchoff",
    used = "switchon"
  },
  
  mover_standard = {
    dormant = "spikeblock",
    active  = "spikeblockred"
  },  
  
  gun_standard = {
    dormant = "gun_down_dormant",
    active = "gun_down_active"
  },
  
  bullet_standard = {
    active = "bullet"
  }
  
}

rTextures = {
	{id = "shelf_decayed1",
	fname = TEXTURES_DIR .. "shelf_decayed1.png",
	data = nil},

	{id = "shelf_decayed2",
	fname = TEXTURES_DIR .. "shelf_decayed2.png",
	data = nil},

	{id = "shelf_decayed3",
	fname = TEXTURES_DIR .. "shelf_decayed3.png",
	data = nil},

	{id = "bookshelf_left",
	fname = TEXTURES_DIR .. "bookshelf_left.png",
	data = nil},

	{id = "bookshelf_middle",
	fname = TEXTURES_DIR .. "bookshelf_middle.png",
	data = nil},

	{id = "bookshelf_right",
	fname = TEXTURES_DIR .. "bookshelf_right.png",
	data = nil},

	{id = "gun_down_dormant",
	fname = TEXTURES_DIR .. "gun_down_dormant.png",
	data = nil},

	{id = "gun_up_dormant",
	fname = TEXTURES_DIR .. "gun_up_dormant.png",
	data = nil},

	{id = "gun_right_dormant",
	fname = TEXTURES_DIR .. "gun_right_dormant.png",
	data = nil},

	{id = "gun_left_dormant",
	fname = TEXTURES_DIR .. "gun_left_dormant.png",
	data = nil},

	{id = "gun_8directions_dormant",
	fname = TEXTURES_DIR .. "gun_8directions_dormant.png",
	data = nil},

	{id = "gun_down_active",
	fname = TEXTURES_DIR .. "gun_down_active.png",
	data = nil},

	{id = "gun_up_active",
	fname = TEXTURES_DIR .. "gun_up_active.png",
	data = nil},

	{id = "gun_right_active",
	fname = TEXTURES_DIR .. "gun_right_active.png",
	data = nil},
	
	{id = "gun_left_active",
	fname = TEXTURES_DIR .. "gun_left_active.png",
	data = nil},

	{id = "gun_8directions_active",
	fname = TEXTURES_DIR .. "gun_8directions_active.png",
	data = nil},

	{id = "eyegun_dormant",
	fname = TEXTURES_DIR .. "eyegun_dormant.png",
	data = nil},

	{id = "eyegun_active",
	fname = TEXTURES_DIR .. "eyegun_active.png",
	data = nil},

	{id = "biggun_dormant",
	fname = TEXTURES_DIR .. "biggun_dormant.png",
	data = nil},

	{id = "biggun_active",
	fname = TEXTURES_DIR .. "biggun_active.png",
	data = nil},

	{id = "bullet",
	fname = TEXTURES_DIR .. "bullet_alt.png",
	data = nil},

	{id = "whitebullet",
	fname = TEXTURES_DIR .. "whitebullet.png",
	data = nil},

	{id = "barrel",
	fname = TEXTURES_DIR .. "barrel.png",
	data = nil},

	{id = "northwall",
	fname = TEXTURES_DIR .. "northwall.png",
	data = nil},

	{id = "westwall",
	fname = TEXTURES_DIR .. "westwall.png",
	data = nil},

	{id = "southwall",
	fname = TEXTURES_DIR .. "southwall.png",
	data = nil},

  {id = "southwallendingleft",
	fname = TEXTURES_DIR .. "southwallendingleft.png",
	data = nil},

  {id = "southwallendingright",
	fname = TEXTURES_DIR .. "southwallendingright.png",
	data = nil},
  
  {id = "eastwallendingup",
	fname = TEXTURES_DIR .. "eastwallendingup.png",
	data = nil},
	
  {id = "eastwallendingdown",
	fname = TEXTURES_DIR .. "eastwallendingdown.png",
	data = nil},

  {id = "westwallendingup",
	fname = TEXTURES_DIR .. "westwallendingup.png",
	data = nil},
	
  {id = "westwallendingdown",
	fname = TEXTURES_DIR .. "westwallendingdown.png",
	data = nil},

	{id = "eastwall",
	fname = TEXTURES_DIR .. "eastwall.png",
	data = nil},

	{id = "southwestwall",
	fname = TEXTURES_DIR .. "southwestwall.png",
	data = nil},

	{id = "southwestinnerwall",
	fname = TEXTURES_DIR .. "southwestinnerwall.png",
	data = nil},

	{id = "northwestinnerwall",
	fname = TEXTURES_DIR .. "northwestinnerwall.png",
	data = nil},

	{id = "southeastwall",
	fname = TEXTURES_DIR .. "southeastwall.png",
	data = nil},

	{id = "northeastwall",
	fname = TEXTURES_DIR .. "northeastwall.png",
	data = nil},

	{id = "northwestwall",
	fname = TEXTURES_DIR .. "northwestwall.png",
	data = nil},

	{id = "southeastinnerwall",
	fname = TEXTURES_DIR .. "southeastinnerwall.png",
	data = nil},

	{id = "northeastinnerwall",
	fname = TEXTURES_DIR .. "northeastinnerwall.png",
	data = nil},

	{id = "northdeepwall",
	fname = TEXTURES_DIR .. "northdeepwall.png",
	data = nil},

	{id = "southdeepwall",
	fname = TEXTURES_DIR .. "southdeepwall.png",
	data = nil},
	
	{id = "westdeepwall",
	fname = TEXTURES_DIR .. "westdeepwall.png",
	data = nil},

	{id = "eastdeepwall",
	fname = TEXTURES_DIR .. "eastdeepwall.png",
	data = nil},
	
	{id = "northwestdeepwall",
	fname = TEXTURES_DIR .. "northwestdeepwall.png",
	data = nil},

	{id = "northeastdeepwall",
	fname = TEXTURES_DIR .. "northeastdeepwall.png",
	data = nil},

	{id = "southwestdeepwall",
	fname = TEXTURES_DIR .. "southwestdeepwall.png",
	data = nil},

	{id = "southeastdeepwall",
	fname = TEXTURES_DIR .. "southeastdeepwall.png",
	data = nil},

	{id = "southeastinnerdeepwall",
	fname = TEXTURES_DIR .. "southeastinnerdeepwall.png",
	data = nil},

	{id = "southwestinnerdeepwall",
	fname = TEXTURES_DIR .. "southwestinnerdeepwall.png",
	data = nil},

	{id = "northwestinnerdeepwall",
	fname = TEXTURES_DIR .. "northwestinnerdeepwall.png",
	data = nil},

	{id = "northeastinnerdeepwall",
	fname = TEXTURES_DIR .. "northeastinnerdeepwall.png",
	data = nil},

  	{id = "southdeepwallendingleft",
	fname = TEXTURES_DIR .. "southdeepwallendingleft.png",
	data = nil},

  	{id = "southdeepwallendingright",
	fname = TEXTURES_DIR .. "southdeepwallendingright.png",
	data = nil},

	{id = "eastdeepwallendingdown",
	fname = TEXTURES_DIR .. "eastdeepwallendingdown.png",
	data = nil},

  	{id = "eastdeepwallendingup",
	fname = TEXTURES_DIR .. "eastdeepwallendingup.png",
	data = nil},

	{id = "switchoff",
	fname = TEXTURES_DIR .. "switchoff.png",
	data = nil},

	{id = "switchon",
	fname = TEXTURES_DIR .. "switchon.png",
	data = nil},

	{id = "gamelogo",
	fname = TEXTURES_DIR .. "gamelogo.png",
	data = nil},

	{id = "door",
	fname = TEXTURES_DIR .. "door.png",
	data = nil},

	{id = "deepdoor",
	fname = TEXTURES_DIR .. "deepdoor.png",
	data = nil},

	{id = "checkpointdormant",
	fname = TEXTURES_DIR .. "checkpointdormant.png",
	data = nil},

	{id = "checkpointactive",
	fname = TEXTURES_DIR .. "checkpointactive.png",
	data = nil},

	{id = "floor",
	fname = TEXTURES_DIR .. "floor.png",
	data = nil},

	{id = "floorboards",
	fname = TEXTURES_DIR .. "floorboards.png",
	data = nil},

	{id = "barrier",
	fname = TEXTURES_DIR .. "barrier.png",
	data = nil},

	{id = "end",
	fname = TEXTURES_DIR .. "end.png",
	data = nil},

	{id = "meleejailer",
	fname = TEXTURES_DIR .. "meleejailer.png",
	data = nil},

	{id = "meleejailer_flash",
	fname = TEXTURES_DIR .. "meleejailer_flash.png",
	data = nil},

	{id = "meleejailer_red",
	fname = TEXTURES_DIR .. "meleejailer_red.png",
	data = nil},

	{id = "meleejailer_death",
	fname = TEXTURES_DIR .. "meleejailer_death.png",
	data = nil},

	{id = "superjailer_flash",
	fname = TEXTURES_DIR .. "superjailer_flash.png",
	data = nil},

	{id = "superjailer_white",
	fname = TEXTURES_DIR .. "superjailer_white.png",
	data = nil},

	{id = "rangedjailer_flash",
	fname = TEXTURES_DIR .. "rangedjailer_flash.png",
	data = nil},

	{id = "rangedjailer_red",
	fname = TEXTURES_DIR .. "rangedjailer_red.png",
	data = nil},

	{id = "rangedjailer",
	fname = TEXTURES_DIR .. "rangedjailer.png",
	data = nil},

	{id = "rangedjailer_death",
	fname = TEXTURES_DIR .. "rangedjailer_death.png",
	data = nil},

	{id = "spikeblock",
	fname = TEXTURES_DIR .. "spikeblock.png",
	data = nil},

	{id = "spikeblockred",
	fname = TEXTURES_DIR .. "spikeblockred.png",
	data = nil},
}

--Dirty and oh so temporary
-- TODO: fix it
rTextures.mt = {
  __index = function(table, key)
    return rawget(table, getTextureByID(key))
  end
}

setmetatable(rTextures, rTextures.mt)
