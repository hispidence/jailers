return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.18.1",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 50,
  height = 50,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 17,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      image = "../textures/tileset.png",
      imagewidth = 128,
      imageheight = 128,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {
        {
          name = "barrel",
          tile = 0,
          properties = {}
        },
        {
          name = "door",
          tile = 17,
          properties = {}
        }
      },
      tilecount = 64,
      tiles = {
        {
          id = 0,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 17,
          terrain = { 1, 1, 1, 1 }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "floor",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = "false"
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJzt1UEOgjAQBdDZiLvqQjdq1J1bj8BROApH4SgchaM4BCaZVEoLSmn0v2QiBojzM20l8jv0lRHdDVHZFl+XAa9GtXHU0Xpuxzm46i1RzlmauF36heZ4EhVcDc8i56r1Pf5OpvusFm/Y4UzDOcSjrz33KNdam4FndOeqs5Xn5JpJCO694AyFWXEWNlceqRt185MSpjsDqqjNjvDlsPeMSCGHr/eQHEN7P6b2f0HvA71+rvS+pnxC99S3SQ697rVLf/+knrfNORuWIOtlqMfQ91PJ8cnvp5BB/EOOKefZ2qb0mlLftrnzSM2v5BiDHAAAAAAAAAAAAAAAAPG9APr4E7M="
    },
    {
      type = "tilelayer",
      name = "statics",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {
        ["collidable"] = "true"
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJztl0uOgzAMhj3TCmZDyrJLdq3US3AUjsJROApHyVHGxlhjhcekEgQq+ZMsWiDo/+VHIAMAtxAZQAcfAuptvvA4FzlA+ymetA+AiQ+P13sK9NGHa/FchdEmE7sC6mhQb63P6Xws5SHj6xV69HtrjEH0hOfnaksHrck5Tz6d2mUoH1I7YV5CRl90b01BHjJ+RptC6xpU4wXqwJjNiyD5oToq8XjHeGDguqY4QU7cinZB9z75IP1PYB839HE7kY+c66qRuaX/q14Z+oH0/wD7cDwnOsd91B5VY+LDca3XQe3X4kU8jLO2eygfAH9ej6oxlY9O+kT2vZKP2hfNKLo++Ch5f2mO0B2i+0NmUc61Muwd2Aceb/B31kw+yE8f5kM4qlekdui39HCYA6l9ykW4n+gZJ3MguYkRXVuiWWv/xriouM48Q8+zNKqnxMzeJfS+KDncTtl76NmrNTlVcytrfQKJUejZK/2r+rj6Z63fWV402fR9iWZuG+vjlURlPPLuSzMJ5+cwQ1P4eI2xFeG7b7jHU6C3uti4r7f2oSFPc9+Ae3C2ujQMwzAMwzAMwzAMwzAMwzCMd/kFCalaBg=="
    },
    {
      type = "objectgroup",
      name = "objects",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {
        ["collidable"] = "false"
      },
      objects = {
        {
          id = 1,
          name = "door_startroom",
          type = "door",
          shape = "rectangle",
          x = 48,
          y = 128,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 10,
          visible = true,
          properties = {
            ["category"] = "door",
            ["textureset"] = "door_standard"
          }
        },
        {
          id = 2,
          name = "door_hall",
          type = "door",
          shape = "rectangle",
          x = 128,
          y = 240,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 10,
          visible = true,
          properties = {
            ["category"] = "door",
            ["state"] = "",
            ["textureset"] = "door_standard"
          }
        },
        {
          id = 3,
          name = "switch_startroom",
          type = "switch",
          shape = "rectangle",
          x = 80,
          y = 144,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 11,
          visible = true,
          properties = {
            ["behaviour_open_door"] = "target=door_startroom  type=doorswitch_open timer=0",
            ["behaviour_start_mover"] = "target=mover_test type=activate_something timer=0",
            ["category"] = "switch",
            ["collision_behaviours"] = "behaviour_open_door behaviour_start_mover",
            ["textureset"] = "switch_standard"
          }
        },
        {
          id = 4,
          name = "mover_test",
          type = "mover",
          shape = "rectangle",
          x = 32,
          y = 64,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 22,
          visible = true,
          properties = {
            ["extents"] = "x=2 y=0",
            ["initialdirection"] = "x=1 y=0",
            ["speed"] = "2",
            ["textureset"] = "mover_standard"
          }
        },
        {
          id = 5,
          name = "the_jailer",
          type = "enemy",
          shape = "rectangle",
          x = 240,
          y = 224,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 23,
          visible = true,
          properties = {
            ["textureset"] = "switch_standard"
          }
        },
        {
          id = 6,
          name = "door_final_room",
          type = "door",
          shape = "rectangle",
          x = 256,
          y = 224,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 10,
          visible = true,
          properties = {
            ["textureset"] = "door_standard"
          }
        },
        {
          id = 7,
          name = "danger_switch",
          type = "switch",
          shape = "rectangle",
          x = 240,
          y = 304,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 11,
          visible = true,
          properties = {
            ["behaviours"] = "collisionbehaviour0, collisionbehaviour1, collisionbehaviour2",
            ["collisionbehaviour0"] = "danger_switch, danger_jailer, jailerswitch, 0",
            ["collisionbehaviour1"] = "danger_switch, danger_mover, moverswitch_on, 0",
            ["collisionbehaviour2"] = "danger_switch, danger_door, doorswitch_close, 0",
            ["textureset"] = "switch_standard"
          }
        },
        {
          id = 8,
          name = "player",
          type = "special",
          shape = "rectangle",
          x = 70,
          y = 98,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 9,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "switch_hall",
          type = "switch",
          shape = "rectangle",
          x = 32,
          y = 272,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 11,
          visible = true,
          properties = {
            ["behaviour_open_door"] = "type=doorswitch_open target=door_hall  timer=0",
            ["category"] = "switch",
            ["collision_behaviours"] = "behaviour_open_door",
            ["textureset"] = "switch_standard"
          }
        },
        {
          id = 10,
          name = "gun_start",
          type = "gun",
          shape = "rectangle",
          x = 144,
          y = 112,
          width = 16,
          height = 16,
          rotation = 0,
          gid = 21,
          visible = true,
          properties = {
            ["direction"] = "x=-1 y=0",
            ["textureset"] = "gun_standard",
            ["textureset_bullet"] = "bullet_standard"
          }
        }
      }
    },
    {
      type = "objectgroup",
      name = "cameras",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 11,
          name = "camera_hall",
          type = "camera",
          shape = "rectangle",
          x = 32,
          y = 176,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "camera_start",
          type = "camera",
          shape = "rectangle",
          x = 96,
          y = 96,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 15,
          name = "camera_hall2",
          type = "camera",
          shape = "rectangle",
          x = 184.333,
          y = 259.333,
          width = 16,
          height = 16,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      name = "triggers",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 13,
          name = "cameraTrigger_hall",
          type = "trigger",
          shape = "rectangle",
          x = 20,
          y = 160,
          width = 8,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {
            ["behaviour_move_camera"] = "timer=3 type=move_camera target=camera_hall",
            ["collision_behaviours"] = "behaviour_move_camera"
          }
        },
        {
          id = 14,
          name = "cameraTrigger_start",
          type = "trigger",
          shape = "rectangle",
          x = 20,
          y = 128,
          width = 8,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {
            ["behaviour_move_camera"] = "type=move_camera target=camera_start timer=3",
            ["collision_behaviours"] = "behaviour_move_camera"
          }
        },
        {
          id = 16,
          name = "cameraTrigger_hall2",
          type = "trigger",
          shape = "rectangle",
          x = 67.6667,
          y = 228,
          width = 8,
          height = 8,
          rotation = 0,
          visible = true,
          properties = {
            ["behaviour_move_camera"] = "timer=3 type=move_camera target=camera_hall2",
            ["collision_behaviours"] = "behaviour_move_camera"
          }
        }
      }
    }
  }
}
