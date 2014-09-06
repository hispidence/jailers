function getTextureByID(id)
	for i, v in ipairs(rTextures) do
		if v.id == id then return i end
	end
	return 0
end

rTextures = {
	{id = "shelf_decayed1",
	fname = "/textures/shelf_decayed1.png",
	data = nil},

	{id = "shelf_decayed2",
	fname = "/textures/shelf_decayed2.png",
	data = nil},

	{id = "shelf_decayed3",
	fname = "/textures/shelf_decayed3.png",
	data = nil},

	{id = "bookshelf_left",
	fname = "/textures/bookshelf_left.png",
	data = nil},

	{id = "bookshelf_middle",
	fname = "/textures/bookshelf_middle.png",
	data = nil},

	{id = "bookshelf_right",
	fname = "/textures/bookshelf_right.png",
	data = nil},

	{id = "gun_down_dormant",
	fname = "/textures/gun_down_dormant.png",
	data = nil},

	{id = "gun_up_dormant",
	fname = "/textures/gun_up_dormant.png",
	data = nil},

	{id = "gun_right_dormant",
	fname = "/textures/gun_right_dormant.png",
	data = nil},

	{id = "gun_left_dormant",
	fname = "/textures/gun_left_dormant.png",
	data = nil},

	{id = "gun_8directions_dormant",
	fname = "/textures/gun_8directions_dormant.png",
	data = nil},

	{id = "gun_down_active",
	fname = "/textures/gun_down_active.png",
	data = nil},

	{id = "gun_up_active",
	fname = "/textures/gun_up_active.png",
	data = nil},

	{id = "gun_right_active",
	fname = "/textures/gun_right_active.png",
	data = nil},
	
	{id = "gun_left_active",
	fname = "/textures/gun_left_active.png",
	data = nil},

	{id = "gun_8directions_active",
	fname = "/textures/gun_8directions_active.png",
	data = nil},

	{id = "eyegun_dormant",
	fname = "/textures/eyegun_dormant.png",
	data = nil},

	{id = "eyegun_active",
	fname = "/textures/eyegun_active.png",
	data = nil},

	{id = "biggun_dormant",
	fname = "/textures/biggun_dormant.png",
	data = nil},

	{id = "biggun_active",
	fname = "/textures/biggun_active.png",
	data = nil},

	{id = "bullet",
	fname = "/textures/bullet.png",
	data = nil},

	{id = "whitebullet",
	fname = "/textures/whitebullet.png",
	data = nil},

	{id = "barrel",
	fname = "/textures/barrel.png",
	data = nil},

	{id = "northwall",
	fname = "/textures/northwall.png",
	data = nil},

	{id = "westwall",
	fname = "/textures/westwall.png",
	data = nil},

	{id = "southwall",
	fname = "/textures/southwall.png",
	data = nil},

  {id = "southwallendingleft",
	fname = "/textures/southwallendingleft.png",
	data = nil},

  {id = "southwallendingright",
	fname = "/textures/southwallendingright.png",
	data = nil},
  
  {id = "eastwallendingup",
	fname = "/textures/eastwallendingup.png",
	data = nil},
	
  {id = "eastwallendingdown",
	fname = "/textures/eastwallendingdown.png",
	data = nil},

 
  {id = "westwallendingup",
	fname = "/textures/westwallendingup.png",
	data = nil},
	
  {id = "westwallendingdown",
	fname = "/textures/westwallendingdown.png",
	data = nil},


	{id = "eastwall",
	fname = "/textures/eastwall.png",
	data = nil},

	{id = "southwestwall",
	fname = "/textures/southwestwall.png",
	data = nil},

	{id = "southwestinnerwall",
	fname = "/textures/southwestinnerwall.png",
	data = nil},

	{id = "northwestinnerwall",
	fname = "/textures/northwestinnerwall.png",
	data = nil},

	{id = "southeastwall",
	fname = "/textures/southeastwall.png",
	data = nil},

	{id = "northeastwall",
	fname = "/textures/northeastwall.png",
	data = nil},

	{id = "northwestwall",
	fname = "/textures/northwestwall.png",
	data = nil},

	{id = "southeastinnerwall",
	fname = "/textures/southeastinnerwall.png",
	data = nil},

	{id = "northeastinnerwall",
	fname = "/textures/northeastinnerwall.png",
	data = nil},

	{id = "northdeepwall",
	fname = "/textures/northdeepwall.png",
	data = nil},

	{id = "southdeepwall",
	fname = "/textures/southdeepwall.png",
	data = nil},
	
	{id = "westdeepwall",
	fname = "/textures/westdeepwall.png",
	data = nil},

	{id = "eastdeepwall",
	fname = "/textures/eastdeepwall.png",
	data = nil},
	
	{id = "northwestdeepwall",
	fname = "/textures/northwestdeepwall.png",
	data = nil},

	{id = "northeastdeepwall",
	fname = "/textures/northeastdeepwall.png",
	data = nil},

	{id = "southwestdeepwall",
	fname = "/textures/southwestdeepwall.png",
	data = nil},

	{id = "southeastdeepwall",
	fname = "/textures/southeastdeepwall.png",
	data = nil},

	{id = "southeastinnerdeepwall",
	fname = "/textures/southeastinnerdeepwall.png",
	data = nil},

	{id = "southwestinnerdeepwall",
	fname = "/textures/southwestinnerdeepwall.png",
	data = nil},

	{id = "northwestinnerdeepwall",
	fname = "/textures/northwestinnerdeepwall.png",
	data = nil},

	{id = "northeastinnerdeepwall",
	fname = "/textures/northeastinnerdeepwall.png",
	data = nil},

  	{id = "southdeepwallendingleft",
	fname = "/textures/southdeepwallendingleft.png",
	data = nil},

  	{id = "southdeepwallendingright",
	fname = "/textures/southdeepwallendingright.png",
	data = nil},

	{id = "eastdeepwallendingdown",
	fname = "/textures/eastdeepwallendingdown.png",
	data = nil},

  	{id = "eastdeepwallendingup",
	fname = "/textures/eastdeepwallendingup.png",
	data = nil},

	{id = "switchoff",
	fname = "/textures/switchoff.png",
	data = nil},

	{id = "switchon",
	fname = "/textures/switchon.png",
	data = nil},

	{id = "gamelogo",
	fname = "/textures/gamelogo.png",
	data = nil},

	{id = "door",
	fname = "/textures/door.png",
	data = nil},

	{id = "deepdoor",
	fname = "/textures/deepdoor.png",
	data = nil},

	{id = "checkpointdormant",
	fname = "/textures/checkpointdormant.png",
	data = nil},

	{id = "checkpointactive",
	fname = "/textures/checkpointactive.png",
	data = nil},

	{id = "floor",
	fname = "/textures/floor.png",
	data = nil},

	{id = "floorboards",
	fname = "/textures/floorboards.png",
	data = nil},

	{id = "barrier",
	fname = "/textures/barrier.png",
	data = nil},

	{id = "end",
	fname = "/textures/end.png",
	data = nil},

	{id = "meleejailer",
	fname = "/textures/meleejailer.png",
	data = nil},

	{id = "meleejailer_flash",
	fname = "/textures/meleejailer_flash.png",
	data = nil},

	{id = "meleejailer_red",
	fname = "/textures/meleejailer_red.png",
	data = nil},

	{id = "meleejailer_death",
	fname = "/textures/meleejailer_death.png",
	data = nil},

	{id = "superjailer_flash",
	fname = "/textures/superjailer_flash.png",
	data = nil},

	{id = "superjailer_white",
	fname = "/textures/superjailer_white.png",
	data = nil},

	{id = "rangedjailer_flash",
	fname = "/textures/rangedjailer_flash.png",
	data = nil},

	{id = "rangedjailer_red",
	fname = "/textures/rangedjailer_red.png",
	data = nil},

	{id = "rangedjailer",
	fname = "/textures/rangedjailer.png",
	data = nil},

	{id = "rangedjailer_death",
	fname = "/textures/rangedjailer_death.png",
	data = nil},


	{id = "spikeblock",
	fname = "/textures/spikeblock.png",
	data = nil},
	{id = "spikeblockred",
	fname = "/textures/spikeblockred.png",
	data = nil},
}


