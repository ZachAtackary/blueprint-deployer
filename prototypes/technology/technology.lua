data:extend(
{
	------------------------------------------------------------------------------
	--                                 Technology                               --
	------------------------------------------------------------------------------	
	{
    type = "technology",
    name = "automated-construction-2",
    icon = "__base__/graphics/icons/blueprint.png",
    effects = {
			{
        type = "unlock-recipe",
        recipe = "blueprint-deployer-activator"
      },
			{
        type = "unlock-recipe",
        recipe = "deconstructor-activator"
      },
    },
    prerequisites = {"automated-construction"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
      },
      time = 30
    },
    order = "c-k-b",
  },
})