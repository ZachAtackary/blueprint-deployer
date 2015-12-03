require "config"

local mod_version="0.1.3"

local function print(...)
	for _,player in pairs(game.players) do
		player.print(...)
	end
end

local debug=function() end
if debug_mode then
  debug=print
end

function tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl or {}) do
    formatting = "." .. string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      debug(formatting)
      tprint(v, indent+1)
    else
      debug(formatting .. tostring(v))
    end
  end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function is_table_equal(t1,t2,ignore_mt)
	local ty1 = type(t1)
	local ty2 = type(t2)
	if ty1 ~= ty2 then return false end
	-- non-table types can be directly compared
	if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(t1)
	if not ignore_mt and mt and mt.__eq then return t1 == t2 end
	for k1,v1 in pairs(t1) do
	local v2 = t2[k1]
	if v2 == nil or not is_table_equal(v1,v2) then return false end
	end
	for k2,v2 in pairs(t2) do
	local v1 = t1[k2]
	if v1 == nil or not is_table_equal(v1,v2) then return false end
	end
	return true
end

local function existsIn(value, tableIn) --returns either the index of item, or #table + 1
	exists = #tableIn + 1
	for i=1, #tableIn do
		if is_table_equal(tableIn[i], value) then
			exists = i
		end
	end
	return exists
end


local function onLoad()
	if global.blueprintDeployerMod == nil then
		global.blueprintDeployerMod = {}
	end
	if global.blueprintDeployerMod.playersSettingDeconstructorBounds == nil then
		global.blueprintDeployerMod.playersSettingDeconstructorBounds = {}
	end
	if global.blueprintDeployerMod.blueprintDeploying == nil then
		global.blueprintDeployerMod.blueprintDeploying = false
	end
	if global.blueprintDeployerMod.playersSettingOffsets == nil then
		global.blueprintDeployerMod.playersSettingOffsets = {}
	end
	if global.blueprintDeployerMod.deconstructors==nil then
    global.blueprintDeployerMod.deconstructors={}
	end
  if global.blueprintDeployerMod.blueprintDeployers==nil then
    global.blueprintDeployerMod.blueprintDeployers={}
  end
	if global.blueprintDeployerMod.blueprints == nil then
		global.blueprintDeployerMod.blueprints = {}
	end
end

local function findOpenedActivator(player, list)
	local object = nil
	for i = 1, #list do
		if list[i].activator == player.opened then
			object = list[i]
		end
	end
	return object
end

local function blueprintDeployerOpened(player)
	return findOpenedActivator(player, global.blueprintDeployerMod.blueprintDeployers)
end

local function deconstructorOpened(player)
	return findOpenedActivator(player, global.blueprintDeployerMod.deconstructors)
end

local function getCursorPosition(entity)
	global.blueprintDeployerMod.cursorData.cursorPos = entity.position
	global.blueprintDeployerMod.cursorData.direction = entity.direction
	tprint(global.blueprintDeployerMod.cursorData.cursorPos)
	entity.destroy()
end

local function placeCursorFinder(player)
	global.blueprintDeployerMod.cursorData = {}
	local characterStore = player.character
	player.character = nil
	player.cursor_stack.set_stack{name = "cursor-finder", count = 1}
	player.build_from_cursor()
	player.character = characterStore
end

local function getOffset(event)
	local entity = event.created_entity
	--if you try to clear a blueprint cursorstack on the tick that the blueprint is placed, 
	--instead of getting rid of the cursor stack, it gets rid of all of the data on the blueprint, 
	--but leaves the blueprint, so I have to do an on tick test looking to see if they have just set offsets, 
	--and then remove the cursor_stack the next tick
	global.blueprintDeployerMod.playersSettingOffsets[event.player_index].toClearCursorStack = true 
	
	local blueprintDeployer = global.blueprintDeployerMod.playersSettingOffsets[event.player_index].blueprintDeployer
	if not pcall(function() if blueprintDeployer.activator.position.x == 5 then end end) then debug("Blueprint Deployer no longer exists!") entity.destroy() return end 
	--the if statement has no signifigance, just needed to do something with the entity to see if it still exists or not
	local xOffset = math.floor(entity.position.x - blueprintDeployer.activator.position.x) + 1
	local yOffset = math.floor(entity.position.y - blueprintDeployer.activator.position.y) + 1
	debug("xOffset: " .. xOffset .. " yOffset: " .. yOffset)
	if xOffset < 0 then	xOffset = xOffset + 2000 end
	if yOffset < 0 then	yOffset = yOffset + 2000 end
	
	local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
	BDData[2].signal.name = "blueprint-index"
	BDData[2].count = xOffset
	BDData[3].signal.name = "blueprint-index"
	BDData[3].count = yOffset
	blueprintDeployer.dataObject.set_circuit_condition(1, {parameters = BDData})
end

local function setBlueprintOffsets(event)
	local player = game.players[event.player_index]
	local blueprintDeployer = blueprintDeployerOpened(player)
	if blueprintDeployer == nil then return end
	
	local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
	if BDData[1].signal.name ~= "blueprint-index" then player.print("please insert a blueprint first!") return end
	local index = BDData[1].count
	
	local cursorStack = player.cursor_stack
	if cursorStack and cursorStack.valid_for_read then player.print("you can't be holding something when clicking this button!") return end
	
	local blueprintEntities = deepcopy(global.blueprintDeployerMod.blueprints[index].entities)
	--add a cursor-finder so we can find the center of the blueprint
	blueprintEntities[#blueprintEntities + 1] = {entity_number = #blueprintEntities + 1, name = "cursor-finder", position = {x = 0, y = 0}, direction = 0}
	cursorStack.set_stack{name = "blueprint", count = 1}
	cursorStack.set_blueprint_entities(blueprintEntities)
	cursorStack.set_blueprint_tiles(global.blueprintDeployerMod.blueprints[index].tiles)
	cursorStack.blueprint_icons = global.blueprintDeployerMod.blueprints[index].icons
	global.blueprintDeployerMod.playersSettingOffsets[player.index] = {}
	global.blueprintDeployerMod.playersSettingOffsets[player.index].blueprintDeployer = blueprintDeployer
end

local function getBounds(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local cursorStack = player.cursor_stack
	if global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].position1 == nil then --first of the two bounds setting
		global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].position1 = entity.position
		cursorStack.set_stack{name = "bounds-marker", count = 1}
		event.created_entity.destroy()
	else --second of the two bounds setting
		local position1 = global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].position1
		local position2 = entity.position
		local deconstructor = global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].deconstructor
		local DData = deconstructor.dataObject.get_circuit_condition(1).parameters
		position1.x = math.floor(position1.x - deconstructor.dataObject.position.x)
		position1.y = math.floor(position1.y - deconstructor.dataObject.position.y)
		position2.x = math.floor(position2.x - deconstructor.dataObject.position.x)
		position2.y = math.floor(position2.y - deconstructor.dataObject.position.y)
		tprint(position1)
		tprint(position2)
		if position1.x < 0 then	position1.x = position1.x + 2000 end
		if position1.y < 0 then	position1.y = position1.y + 2000 end
		if position2.x < 0 then	position2.x = position2.x + 2000 end
		if position2.y < 0 then	position2.y = position2.y + 2000 end
		for i = 1, 6 do
			DData[i].signal.name = "blueprint-index"
		end
		DData[1].count = 0
		DData[2].count = 0
		DData[3].count = position1.x
		DData[4].count = position1.y
		DData[5].count = position2.x
		DData[6].count = position2.y
		deconstructor.dataObject.set_circuit_condition(1, {parameters = DData})
		event.created_entity.destroy()
		deconstructor.deconstructed = false
		table.remove(global.blueprintDeployerMod.playersSettingDeconstructorBounds,event.player_index)
	end
end

local function setDeconstructorBounds(event)
	local player = game.players[event.player_index]
	local deconstructor = deconstructorOpened(player)
	if deconstructor == nil then return end
	
	local cursorStack = player.cursor_stack
	if cursorStack and cursorStack.valid_for_read then player.print("you can't be holding something when clicking this button!") return end

	cursorStack.set_stack{name = "bounds-marker", count = 1}
	global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index] = {}
	global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].isSetting = true
	global.blueprintDeployerMod.playersSettingDeconstructorBounds[player.index].deconstructor = deconstructor
end

local function saveBlueprint(event)
	local player = game.players[event.player_index]
	local blueprintDeployer = blueprintDeployerOpened(player)
	if blueprintDeployer == nil then return end
	
	if player.cursor_stack.valid_for_read and player.cursor_stack.name == "blueprint" then -- he must have a blueprint in order to copy
		local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
		local blueprint = {}
		blueprint.entities = player.cursor_stack.get_blueprint_entities()
		blueprint.tiles= player.cursor_stack.get_blueprint_tiles()
		blueprint.icons = player.cursor_stack.blueprint_icons
		
		local index = existsIn(blueprint, global.blueprintDeployerMod.blueprints)
		debug("index: " .. index)
		global.blueprintDeployerMod.blueprints[index] = deepcopy(blueprint)
		
		BDData[1].signal.name = "blueprint-index"
		BDData[1].count = index
		player.gui.top.deployerGui.blueprintButton.caption = "Blueprint Found"
		blueprintDeployer.dataObject.set_circuit_condition(1, {parameters = BDData})
	else -- no blueprint, so set the blueprint deployer's blueprint to nothing
		local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
		BDData[1].signal.name = ""
		BDData[1].count = 0
		player.gui.top.deployerGui.blueprintButton.caption = "No Blueprint Found"
		blueprintDeployer.dataObject.set_circuit_condition(1, {parameters = BDData})
	end
end

local function resetDeployment(event)
	local player = game.players[event.player_index]
	local blueprintDeployer = blueprintDeployerOpened(player)
	if blueprintDeployer ~= nil then
		blueprintDeployer.placedGhosts = false;
		event.element.caption = "Awaiting Circuit Condition"
	end
	local deconstructor = deconstructorOpened(player)
	if deconstructor ~= nil then
		deconstructor.deconstructed = false;
		event.element.caption = "Awaiting Circuit Condition"
	end
end

local function onGuiClick(event)
	if event.element.name == "setBlueprintOffsets" then
		setBlueprintOffsets(event)
	elseif event.element.name == "setDeconstructorBounds" then
		setDeconstructorBounds(event)
	elseif event.element.name == "blueprintButton" then
		saveBlueprint(event)
	elseif event.element.name == "deploymentReset" then
		resetDeployment(event)
	end
end

local function displayGui(playerIndex, entity)
	local player = game.players[playerIndex]
	local playerGui = player.gui.top
	if playerGui.deployerGui then return end
	
	local blueprintDeployer = blueprintDeployerOpened(player)
	if blueprintDeployer == nil then return end
	
	local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
	local offsetX = 0
	local offsetY = 0
	if BDData[2].signal.name == "blueprint-index" then offsetX = BDData[2].count end
	if offsetX > 1000 then offsetX = offsetX - 2000 end
	
	if BDData[3].signal.name == "blueprint-index" then offsetY = BDData[3].count end
	if offsetY > 1000 then offsetY = offsetY - 2000 end
	
	playerGui.add{type = "frame", caption = "Blueprint Deployer", name = "deployerGui", direction = "vertical"}
	playerGui.deployerGui.add{type = "button", name = "blueprintButton", state = false}
	if BDData[1].signal.name == "blueprint-index" then playerGui.deployerGui.blueprintButton.caption = "Blueprint Found"
	else playerGui.deployerGui.blueprintButton.caption = "No Blueprint Found" end
	playerGui.deployerGui.add{type = "label", caption = "place blueprint here" .. "               "}
	
	playerGui.deployerGui.add{type = "button", caption = "     Set Offsets     ", name = "setBlueprintOffsets"}
	playerGui.deployerGui.add{type = "flow", name = "offsetX", direction = "horizontal"}
	playerGui.deployerGui.offsetX.add{type="label", caption = "X Offset: " .. offsetX}
	playerGui.deployerGui.add{type = "flow", name = "offsetY", direction = "horizontal"}
	playerGui.deployerGui.offsetY.add{type="label", caption = "Y Offset: " .. offsetY}
	
	playerGui.deployerGui.add{type = "button", name = "deploymentReset", state = false}
	if blueprintDeployer.placedGhosts then playerGui.deployerGui.deploymentReset.caption = "Blueprint Placed"
	else playerGui.deployerGui.deploymentReset.caption = "Awaiting Circuit Condition" end	
	playerGui.deployerGui.add{type = "label", caption = "Reset Blueprint Deployment"}
end

local function displayGuiDeconstructor(playerIndex, entity)
	local player = game.players[playerIndex]
	local deconstructor = deconstructorOpened(player)
	if deconstructor == nil then return end
	
	local playerGui = player.gui.top
	if playerGui.deployerGui then return end

	local DData = deconstructor.dataObject.get_circuit_condition(1).parameters
	local left = 0
	local top = 0
	local right = 0
	local bottom = 0

	if DData[3].signal.name == "blueprint-index" then
		left = DData[3].count
		if left > 1000 then left = left - 2000 end
	end
	if DData[4].signal.name == "blueprint-index" then
		top = DData[4].count
		if top > 1000 then top = top - 2000 end
	end
	if DData[5].signal.name == "blueprint-index" then
		right = DData[5].count
		if right > 1000 then right = right - 2000 end
	end
	if DData[6].signal.name == "blueprint-index" then
		bottom = DData[6].count
		if bottom > 1000 then bottom = bottom - 2000 end
	end
	
	playerGui.add{type = "frame", caption = "Deconstructor", name = "deployerGui", direction = "vertical"}
	playerGui.deployerGui.add{type = "button", caption = "Set Bounds  ", name = "setDeconstructorBounds"}
	playerGui.deployerGui.add{type = "label", caption = "bounds:               "}
	playerGui.deployerGui.add{type="label", caption = "Left: "   .. left   .. "                       "}
	playerGui.deployerGui.add{type="label", caption = "Top: "    .. top    .. "                       "}
	playerGui.deployerGui.add{type="label", caption = "Right: "  .. right  .. "                       "}
	playerGui.deployerGui.add{type="label", caption = "Bottom: " .. bottom .. "                       "}
	
	playerGui.deployerGui.add{type = "button", name = "deploymentReset"}
	if deconstructor.deconstructed then playerGui.deployerGui.deploymentReset.caption = "Deconstructed"
	else playerGui.deployerGui.deploymentReset.caption = "Awaiting Circuit Condition" end	
	playerGui.deployerGui.add{type = "label", caption = "Reset Deconstruction Deployment"}
end

local function hideGui(playerIndex)
	local playerGui = game.players[playerIndex].gui.top
	if playerGui.deployerGui then playerGui.deployerGui.destroy() end
end

local function guiLoop()
	for i,player in pairs(game.players) do
		if player.character and player.opened and player.opened.name == "blueprint-deployer-activator" then
		  displayGui(i, player.opened)
		elseif player.character and player.opened and player.opened.name == "deconstructor-activator" then
		  displayGuiDeconstructor(i, player.opened)
		else
			hideGui(i)
		end
	end
end

local function placeBlueprint(blueprintDeployer)
	local BDData = blueprintDeployer.dataObject.get_circuit_condition(1).parameters
	if BDData[1].signal.name ~= "blueprint-index" then return end
	local index = BDData[1].count
	tprint(global.blueprintDeployerMod.blueprints[index].enitites)
	local player = game.players[1]
	placeCursorFinder(player) --this will place a cursor-finder at the cursor which will cause getCursorPosition to be called
	local characterStore = player.character
	player.character = nil
	
	local cursorStack = player.cursor_stack
	--player.rotate_for_build() doesn't do anything for a blueprint, so I need to give the player a dummy item, rotate it, then give them a blueprint
	cursorStack.set_stack{name = "basic-inserter", count = 1}
	local rotation = global.blueprintDeployerMod.cursorData.direction -- set from the placeCursorFinder(player)
	debug("rotation = " .. rotation)
	for i = 1, (4-(rotation/2))%4 do
		player.rotate_for_build()
	end
	
	local entities = deepcopy(global.blueprintDeployerMod.blueprints[index].entities)
	for k,entity in pairs(entities or {}) do
		if entity.name == "blueprint-deployer-data-object" then
			tprint(entity)
			local hasBlueprint = false
			local hasXOffset = false
			local hasYOffset = false
			if entity.filters then
				for i = 1, #entity.filters do
					if entity.filters[i].index == 1 then hasBlueprint = true end
					if entity.filters[i].index == 2 then hasXOffset = true end
					if entity.filters[i].index == 3 then hasYOffset = true end
				end
			else entity.filters = {} end
			if hasBlueprint == false then
				entity.filters[#entity.filters + 1] = {signal = {type = "item", name = "blueprint-index"}, count = BDData[1].count, index = 1}
			end
			if hasXOffset == false then
				entity.filters[#entity.filters + 1] = {signal = {type = "item", name = "blueprint-index"}, count = BDData[2].count, index = 2}
			end
			if hasYOffset == false then
				entity.filters[#entity.filters + 1] = {signal = {type = "item", name = "blueprint-index"}, count = BDData[3].count, index = 3}
			end
		end
	end
	
	cursorStack.set_stack{name = "blueprint", count = 1}
	cursorStack.set_blueprint_entities(entities)
	cursorStack.set_blueprint_tiles(global.blueprintDeployerMod.blueprints[index].tiles)
	cursorStack.blueprint_icons = global.blueprintDeployerMod.blueprints[index].icons
	debug("building!")
	local offsetX = BDData[2].count
	if offsetX > 1000 then offsetX = offsetX - 2000 end
	local offsetY = BDData[3].count
	if offsetY > 1000 then offsetY = offsetY - 2000 end
	
	local cursorPositionX = blueprintDeployer.activator.position.x + offsetX
	local cursorPositionY = blueprintDeployer.activator.position.y + offsetY
	local screenCursorPos = player.real2screenposition({cursorPositionX, cursorPositionY})
	
	player.cursor_position = screenCursorPos
	player.build_from_cursor()
	--player.rotate_for_build() doesn't do anything for a blueprint, so I need to give the player a dummy item to rotate it
	cursorStack.set_stack{name = "basic-inserter", count = 1}
	for i = 1, rotation/2 do
		player.rotate_for_build()
	end
	
	blueprintDeployer.placedGhosts = true
	local returnCursorPos = player.real2screenposition(global.blueprintDeployerMod.cursorData.cursorPos)
	player.cursor_position = returnCursorPos
	player.cursor_stack.clear()
	player.character = characterStore
end

local function deconstruct(deconstructor)
	deconstructor.deconstructed = true
	local data = deconstructor.dataObject.get_circuit_condition(1).parameters
	local offsetX = 0
	local offsetY = 0
	local left = 0
	local top = 0
	local right = 0
	local bottom = 0
	
	if data[1].signal.name == "blueprint-index" then 
		offsetX = data[1].count
		if offsetX > 1000 then offsetX = offsetX - 2000 end
	end
	if data[2].signal.name == "blueprint-index" then 
		offsetY = data[2].count
		if offsetY > 1000 then offsetY = offsetY - 2000 end
	end
	
	if data[3].signal.name == "blueprint-index" then 
		left = data[3].count
		if left > 1000 then left = left - 2000 end
	end
	if data[4].signal.name == "blueprint-index" then 
		top = data[4].count
		if top > 1000 then top = top - 2000 end
	end
	if data[1].signal.name == "blueprint-index" then 
		right = data[5].count
		if right > 1000 then right = right - 2000 end
	end
	if data[1].signal.name == "blueprint-index" then 
		bottom = data[6].count
		if bottom > 1000 then bottom = bottom - 2000 end
	end
	
	left = deconstructor.dataObject.position.x + offsetX + left
	top = deconstructor.dataObject.position.y + offsetY + top
	right = deconstructor.dataObject.position.x + offsetX + right
	bottom = deconstructor.dataObject.position.y + offsetY + bottom
	debug("removing at " .. left .. ", " .. top .. " to " .. right .. ", " .. bottom)
	local bounds1 = {left, top}
	local bounds2 = {right, bottom}
	local entities = game.surfaces.nauvis.find_entities{bounds1, bounds2}
	
	for i=1, #entities do
		debug("deconstructing entity " .. entities[i].name)
		if not pcall(function() entities[i].order_deconstruction(entities[i].force) end) then debug("cannot remove: " .. entities[i].name) end
	end
end

local function onTick(event)
	guiLoop()
	for i,player in pairs(game.players) do
		if global.blueprintDeployerMod.playersSettingOffsets[i] and global.blueprintDeployerMod.playersSettingOffsets[i].toClearCursorStack == true then
			debug("clearing cursor stack")
			player.cursor_stack.clear()
			table.remove(global.blueprintDeployerMod.playersSettingOffsets,event.player_index)
		end
	end
  for i=1,#global.blueprintDeployerMod.blueprintDeployers do
    local blueprintDeployer=global.blueprintDeployerMod.blueprintDeployers[i]
		if blueprintDeployer.activator and blueprintDeployer.activator.get_circuit_condition(1).fulfilled and not blueprintDeployer.placedGhosts then
			global.blueprintDeployerMod.blueprintDeploying = true
			placeBlueprint(blueprintDeployer)
			global.blueprintDeployerMod.blueprintDeploying = false
		end
	end
	for i=1,#global.blueprintDeployerMod.deconstructors do
		local deconstructor=global.blueprintDeployerMod.deconstructors[i]
		if deconstructor.activator and deconstructor.activator.get_circuit_condition(1).fulfilled and not deconstructor.deconstructed then
			deconstruct(deconstructor)
		end
	end
end

local function placeDataObject(activatorEntity, dataObjectName, list)
	debug("placed deployer")
	local coords = {activatorEntity.position.x, activatorEntity.position.y}
	local newDataObject = game.surfaces.nauvis.create_entity{name = dataObjectName, position = coords, force=game.forces.player}
	local ghosts = game.surfaces.nauvis.find_entities_filtered{area = {coords, coords}, name = "entity-ghost"}
	for _,ghost in pairs(ghosts) do
		if ghost.ghost_name == dataObjectName then
			newDataObject.set_circuit_condition(1, ghost.get_circuit_condition(1))
		end
		ghost.destroy()
	end
	list[#list+1]={dataObject = newDataObject, activator = activatorEntity}
end

local function onPlace(event)
	local entity = event.created_entity
	if 		 entity.name == "cursor-finder" 							 then getCursorPosition(entity)
	elseif entity.name == "bounds-marker"								 then getBounds(event)
	elseif entity.name == "blueprint-deployer-activator" then	placeDataObject(entity, "blueprint-deployer-data-object", global.blueprintDeployerMod.blueprintDeployers)
	elseif entity.name == "deconstructor-activator" 		 then placeDataObject(entity, "deconstructor-data-object", global.blueprintDeployerMod.deconstructors)
	elseif entity.name == "entity-ghost"                 then 
		debug("event.player_index: " .. event.player_index)
		if global.blueprintDeployerMod.playersSettingOffsets[event.player_index] then
			if global.blueprintDeployerMod.blueprintDeploying then return end
			debug("looking at ghost")
			if entity.ghost_name == "cursor-finder" then
				getOffset(event)
			end
			debug("destroying ghost " .. entity.ghost_name)
			entity.destroy()
		end
	end
end

local function onRemove(event)
  if event.entity.name == "blueprint-deployer-data-object" or event.entity.name == "blueprint-deployer-activator" then
    for i=1,#global.blueprintDeployerMod.blueprintDeployers do
			if global.blueprintDeployerMod.blueprintDeployers[i].dataObject == event.entity then
				global.blueprintDeployerMod.blueprintDeployers[i].activator.destroy()
        table.remove(global.blueprintDeployerMod.blueprintDeployers,i)
        break
			elseif global.blueprintDeployerMod.blueprintDeployers[i].activator == event.entity then
				global.blueprintDeployerMod.blueprintDeployers[i].dataObject.destroy()
        table.remove(global.blueprintDeployerMod.blueprintDeployers,i)
        break
      end
    end
  end
	if event.entity.name == "deconstructor-data-object" or event.entity.name == "deconstructor-activator" then
    for i=1,#global.blueprintDeployerMod.deconstructors do
      if global.blueprintDeployerMod.deconstructors[i].dataObject==event.entity then
				global.blueprintDeployerMod.deconstructors[i].activator.destroy()
				table.remove(global.blueprintDeployerMod.deconstructors,i)
				break
			elseif global.blueprintDeployerMod.deconstructors[i].activator == event.entity then
				global.blueprintDeployerMod.deconstructors[i].dataObject.destroy()
        table.remove(global.blueprintDeployerMod.deconstructors,i)
        break
      end
    end
  end
end



script.on_init(onLoad)
script.on_load(onLoad)

script.on_event(defines.events.on_tick,onTick)

script.on_event(defines.events.on_built_entity,onPlace)
script.on_event(defines.events.on_robot_built_entity,onPlace)

script.on_event(defines.events.on_preplayer_mined_item, onRemove)
script.on_event(defines.events.on_robot_pre_mined, onRemove)
script.on_event(defines.events.on_entity_died, onRemove)


script.on_event(defines.events.on_gui_click, onGuiClick)
