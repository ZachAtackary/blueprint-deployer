data:extend(
{
	------------------------------------------------------------------------------
	--                       Blueprint Deployer Items                           --
	------------------------------------------------------------------------------
	{
    type = "item",
    name = "blueprint-deployer-data-object",
    icon = "__blueprintDeployer__/graphics/blueprint-deployer-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-b[roboport]",
    place_result="blueprint-deployer-data-object",
    stack_size= 50,
  },
	{
    type = "item",
    name = "blueprint-deployer-activator",
    icon = "__blueprintDeployer__/graphics/blueprint-deployer-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-b[roboport]",
    place_result="blueprint-deployer-activator",
    stack_size= 50,
  },
	
	------------------------------------------------------------------------------
	--                          Deconstructor Items                             --
	------------------------------------------------------------------------------
	{
    type = "item",
    name = "deconstructor-data-object",
    icon = "__blueprintDeployer__/graphics/deconstructor-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-b[roboport]",
    place_result="deconstructor-data-object",
    stack_size= 50,
  },
	{
    type = "item",
    name = "deconstructor-activator",
    icon = "__blueprintDeployer__/graphics/deconstructor-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-b[roboport]",
    place_result="deconstructor-activator",
    stack_size= 50,
  },
	
	------------------------------------------------------------------------------
	--                                Extra Items                               --
	------------------------------------------------------------------------------
	{
    type = "item",
    name = "cursor-finder",
    icon = "__base__/graphics/icons/smart-inserter.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-c[roboport]",
    place_result="cursor-finder",
    stack_size= 50,
  },
	{
    type = "item",
    name = "bounds-marker",
    icon = "__base__/graphics/icons/small-lamp.png",
    flags = {"goes-to-quickbar"},
    subgroup = "logistic-network",
    order = "c[signal]-c[roboport]",
		place_result="bounds-marker",
    stack_size= 50,
  },
})