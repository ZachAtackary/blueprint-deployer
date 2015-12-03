data:extend(
{
	----------------------------------------------------------------------------------------------------
	--                               Blueprint Deployer Entities                                      --
	----------------------------------------------------------------------------------------------------
	{
    type = "constant-combinator",
    name = "blueprint-deployer-data-object",
    icon = "__base__/graphics/icons/constant-combinator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "blueprint-deployer-activator"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		collision_mask = {},
    --selection_box = {{-2.5, -2.5}, {-1.5, -1.5}},

    item_slot_count = 15,

    sprite =
    {
			filename = "__blueprintDeployer__/graphics/blueprint-deployer.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {10000, 10000},
        green = {10000, 10000},
      },
      wire =
      {
        red = {10000, 10000},
        green = {10000, 10000},
      }
    },
    circuit_wire_max_distance = 7.5
  },
	 {
    type = "lamp",
    name = "blueprint-deployer-activator",
    icon = "__base__/graphics/icons/small-lamp.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "blueprint-deployer-activator"},
    max_health = 55,
    corpse = "small-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "5KW",
    light = {intensity = 0.9, size = 40},
    picture_off =
    {
			filename = "__blueprintDeployer__/graphics/blueprint-deployer.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },
    picture_on =
    {
			filename = "__blueprintDeployer__/graphics/blueprint-deployer.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {-0.5, 0},
        green = {0.5, 0},
      },
      wire =
      {
        red = {-0.5, 0},
        green = {0.5, 0},
      }
    },

    circuit_wire_max_distance = 7.5
  },

	----------------------------------------------------------------------------------------------------
	--                                   Deconstructor Entities                                       --
	----------------------------------------------------------------------------------------------------
	{
    type = "constant-combinator",
    name = "deconstructor-data-object",
    icon = "__base__/graphics/icons/constant-combinator.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "deconstructor-activator"},
    max_health = 50,
    corpse = "small-remnants",

    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		collision_mask = {},
    --selection_box = {{-2.5, -2.5}, {-1.5, -1.5}},

    item_slot_count = 15,

    sprite =
    {
			filename = "__blueprintDeployer__/graphics/deconstructor.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {10000, 10000},
        green = {10000, 10000},
      },
      wire =
      {
        red = {10000, 10000},
        green = {10000, 10000},
      }
    },
    circuit_wire_max_distance = 7.5
  },
	{
    type = "lamp",
    name = "deconstructor-activator",
    icon = "__base__/graphics/icons/small-lamp.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "deconstructor-activator"},
    max_health = 55,
    corpse = "small-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "5KW",
    light = {intensity = 0.9, size = 40},
    picture_off =
    {
			filename = "__blueprintDeployer__/graphics/deconstructor.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },
    picture_on =
    {
			filename = "__blueprintDeployer__/graphics/deconstructor.png",
      priority = "extra-high",
      width = 96,
      height = 96,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {0, 0}
    },

    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {-0.5, 0},
        green = {0.5, 0},
      },
      wire =
      {
        red = {-0.5, 0},
        green = {0.5, 0},
      }
    },

    circuit_wire_max_distance = 7.5
  },
	
	----------------------------------------------------------------------------------------------------
	--                                        Extra Entities                                          --
	----------------------------------------------------------------------------------------------------
	{
    type = "inserter",
    name = "cursor-finder",
    icon = "__base__/graphics/icons/basic-inserter.png",
    flags = {"placeable-player", "player-creation", "placeable-off-grid"},
    minable = {hardness = 0.2, mining_time = 0.5},
    max_health = 40,
    corpse = "small-remnants",
    collision_mask = {},
    selection_box = {{-0.4, -0.35}, {0.4, 0.45}},
    energy_per_movement = 5000,
    energy_per_rotation = 5000,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      drain = "0.4kW"
    },
    extension_speed = 0.03,
    rotation_speed = 0.014,
    fast_replaceable_group = "inserter",
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      match_progress_to_activity = true,
      sound =
      {
        {
          filename = "__base__/sound/inserter-basic-1.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-basic-2.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-basic-3.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-basic-4.ogg",
          volume = 0.75
        },
        {
          filename = "__base__/sound/inserter-basic-5.ogg",
          volume = 0.75
        }
      }
    },
    hand_base_picture =
    {
      filename = "__base__/graphics/entity/basic-inserter/basic-inserter-hand-base.png",
      priority = "extra-high",
      width = 8,
      height = 33
    },
    hand_closed_picture =
    {
      filename = "__base__/graphics/entity/basic-inserter/basic-inserter-hand-closed.png",
      priority = "extra-high",
      width = 18,
      height = 41
    },
    hand_open_picture =
    {
      filename = "__base__/graphics/entity/basic-inserter/basic-inserter-hand-open.png",
      priority = "extra-high",
      width = 18,
      height = 41
    },
    hand_base_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-base-shadow.png",
      priority = "extra-high",
      width = 8,
      height = 34
    },
    hand_closed_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-closed-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41
    },
    hand_open_shadow =
    {
      filename = "__base__/graphics/entity/burner-inserter/burner-inserter-hand-open-shadow.png",
      priority = "extra-high",
      width = 18,
      height = 41
    },
    pickup_position = {0, -1},
    insert_position = {0, 1.2},
    platform_picture =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/basic-inserter/basic-inserter-platform.png",
        priority = "extra-high",
        width = 46,
        height = 46,
      }
    }
  },
	{
    type = "lamp",
    name = "bounds-marker",
    icon = "__base__/graphics/icons/small-lamp.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5},
    max_health = 55,
    corpse = "small-remnants",
    collision_mask = {},
		collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "5KW",
    light = {intensity = 0.9, size = 40},
    picture_off =
    {
      filename = "__base__/graphics/entity/small-lamp/light-off.png",
      priority = "high",
      width = 67,
      height = 58,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.021875, 0.16875},
    },
    picture_on =
    {
      filename = "__base__/graphics/entity/small-lamp/light-on-patch.png",
      priority = "high",
      width = 62,
      height = 62,
      frame_count = 1,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.0375, -0.01875},
    },

    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.759375, -0.096875},
        green = {0.759375, -0.096875},
      },
      wire =
      {
        red = {0.30625, -0.39375},
        green = {0.30625, -0.39375},
      }
    },

    circuit_wire_max_distance = 7.5
  },
})