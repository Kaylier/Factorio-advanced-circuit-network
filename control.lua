local updater = require("scripts.updater")
local gui_builder = require("scripts.gui-controller-combinator")


script.on_init(function()
  global.controllers = {}
end)


local function reset_target_entity(entity)
  ---
  -- Reset an entity to its default state, as if it was never connected
  ---
  if not entity or not entity.valid then
    return
  end
  if entity.name == "nuclear-reactor" then
    print("Reset nuclear reactor")
    entity.active = true
  end
  if entity.name == "rocket-silo" then
    print("Reset rocket silo")
    entity.active = true
  end
end


local function init_controller(entity)
  ---
  -- Initialize and return a controller
  -- A controller is identified by unit_number, borrowed from the underlying
  -- controller combinator entity.
  ---
  assert(entity and entity.valid)
  assert(entity.name == "controller-combinator")

  local id = entity.unit_number
  if global.controllers[id] ~= nil then
    -- Already exists
    return id
  end

  global.controllers[id] = {
    controller = entity,
    type = "none",
    target = nil,
  }
  return id
end


local function assign_controller(id, target_entity)
  ---
  -- Assign a controller to a target entity
  -- If it was previously assigned, clean up beforehand
  -- If target_entity is nil, unassign the controller
  ---
  assert(global.controllers[id])

  if global.controllers[id].target then
    local old_target = global.controllers[id].target
    global.controllers[id].target = nil
    global.controllers[id].type = "none"
    reset_target_entity(old_target)
    -- Currently, we keep all affected attributes.
    -- See if it's better to remove them
  end

  if target_entity and target_entity.valid then
    local controller = global.controllers[id]
    controller.target = target_entity
    controller.type = target_entity.name
  end
end


local function destroy_controller(id)
  ---
  -- Destroy a controller, every initialized controller must either
  -- be destroyed or live forever.
  -- Once destroyed, the controller combinator entity cannot be attached again.
  ---
  if global.controllers[id] then
    assign_controller(id, nil)
    global.controllers[id] = nil
  end
end


script.on_event({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_player_rotated_entity
},
function(event)
  local entity = event.created_entity or event.entity
  if entity and entity.name == "controller-combinator" then
    -- Force the output of the constant combinator (should be useless, but we never know...)
    entity.get_control_behavior().enabled = true
    script.register_on_entity_destroyed(entity)
    local controller_id = init_controller(entity)

    -- Detect the entity facing the controller combinator
    local d = {
      [defines.direction.north]     = { 0, -1},
      [defines.direction.northeast] = { 1, -1},
      [defines.direction.east]      = { 1,  0},
      [defines.direction.southeast] = { 1,  1},
      [defines.direction.south]     = { 0,  1},
      [defines.direction.southwest] = {-1,  1},
      [defines.direction.west]      = {-1,  0},
      [defines.direction.northwest] = {-1, -1}
    }
    local x = entity.position.x + d[entity.direction][1]
    local y = entity.position.y + d[entity.direction][2]

    local target = entity.surface.find_entities_filtered{position={x,y}, name={"nuclear-reactor", "rocket-silo"}}
    assign_controller(controller_id, target[1])
  end

  --TODO: if entity and potential target, assign it to the controller

end)


script.on_event({
  defines.events.on_entity_destroyed,
  defines.events.script_raised_destroy
},
function(event)
  local id = event.unit_number
  destroy_controller(id)
end)


script.on_nth_tick(1, function()
  for id, data in pairs(global.controllers) do
    local controller = data.controller
    if controller.valid then
      if data.target and data.target.valid then
        updater[data.type](data)
      else
        assign_controller(id, nil)
      end
    else
      log("Controller combinator destroyed without raising event.")
      destroy_controller(id)
    end
  end
end)


script.on_event(defines.events.on_pre_entity_settings_pasted,
function(event)
  if event.source.name == "controller-combinator" and event.destination.name == "controller-combinator" then
    local id_source = event.source.unit_number
    local id_dest = event.destination.unit_number

    assert(global.controllers[id_source])
    assert(global.controllers[id_dest])

    for k,v in pairs(global.controllers[id_source]) do
      if k ~= "controller" and k ~= "type" and k ~= "target" then
        global.controllers[id_dest][k] = v
      end
    end

  end
end)

script.on_event(defines.events.on_entity_cloned,
function(event)
  game.print("entity cloned")
end)

script.on_event(defines.events.on_player_setup_blueprint,
function(event)
  game.print("blueprint setup")
end)

script.on_event(defines.events.on_area_cloned,
function(event)
  game.print("area cloned")
end)


local opened_controller_id = nil


script.on_event(defines.events.on_gui_opened,
function(event)
  ---
  -- Replaces constant-combinator native gui by the custom one and set the opened controller id
  ---
  if event.gui_type == defines.gui_type.entity and event.entity.name == "controller-combinator" then
    opened_controller_id = event.entity.unit_number
    local controller = global.controllers[opened_controller_id]
    local player = game.get_player(event.player_index)
    player.opened = gui_builder[controller.type](player.gui.screen, controller)
  end
end)


script.on_event(defines.events.on_gui_closed,
function(event)
  if event.element and event.element.name == "gui-controller-combinator" then
    event.element.destroy()
    opened_controller_id = nil
  end
end)


script.on_event(defines.events.on_gui_checked_state_changed,
function(event)
  ---
  -- checkbox and radiobutton
  ---
  if event.element.name == "gui-controller-combinator-enable" then
    global.controllers[opened_controller_id].control_enabled = event.element.state
    event.element.parent["gui-controller-combinator-enable-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-enable-endline"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-inventory" then
    global.controllers[opened_controller_id].read_inventory = event.element.state
  elseif event.element.name == "gui-controller-combinator-temperature" then
    global.controllers[opened_controller_id].read_temperature = event.element.state
    event.element.parent["gui-controller-combinator-temperature-frame"].visible = event.element.state
  end
end)

script.on_event(defines.events.on_gui_click,
function(event)
  ---
  -- button and sprite-button
  ---
end)

script.on_event(defines.events.on_gui_confirmed,
function(event)
  ---
  -- textfield
  ---
  if event.element.name == "gui-controller-combinator-enable-cond3" then
    global.controllers[opened_controller_id].control_enabled_cond3 = event.element.text
  end
end)

script.on_event(defines.events.on_gui_elem_changed,
function(event)
  ---
  -- choose-elem-button
  ---
  if event.element.name == "gui-controller-combinator-enable-cond1" then
    global.controllers[opened_controller_id].control_enabled_cond1 = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-temperature-signal" then
    global.controllers[opened_controller_id].read_temperature_signal = event.element.elem_value
  end
  --[[
  if event.element.name == "gui-controller-combinator-enable-cond3" then
    global.controllers[opened_controller_id].control_enabled_cond3 = event.element.signal
  end
  ]]
end)

script.on_event(defines.events.on_gui_selection_state_changed,
function(event)
  ---
  -- tabbed-pane
  ---
end)

script.on_event(defines.events.on_gui_selection_state_changed,
function(event)
  ---
  -- drop-down and list-box
  ---
  if event.element.name == "gui-controller-combinator-enable-cond2" then
    global.controllers[opened_controller_id].control_enabled_cond2 = event.element.selected_index
  end
end)

script.on_event(defines.events.on_gui_switch_state_changed,
function(event)
  ---
  -- switch
  ---
end)

script.on_event(defines.events.on_gui_text_changed,
function(event)
  ---
  -- textfield and text-box
  ---
end)

script.on_event(defines.events.on_gui_value_changed,
function(event)
  ---
  -- slider
  ---
end)


