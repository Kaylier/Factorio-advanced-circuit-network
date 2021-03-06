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
  if entity.type == "assembling-machine" then
    entity.active = true
  end
  if entity.type == "beacon" then
    entity.active = true
  end
  if entity.type == "furnace" then
    entity.active = true
  end
  if entity.type == "lab" then
    entity.active = true
  end
  if entity.type == "reactor" then
    entity.active = true
  end
  if entity.type == "rocket-silo" then
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
    control_enabled = false,
    control_enabled_cond1 = nil,
    control_enabled_cond2 = 2,
    control_enabled_cond3 = "0",
    control_launch = false,
    control_launch_cond1 = {type = "item", name = "satellite"},
    control_launch_cond2 = 1,
    control_launch_cond3 = "0",
    read_inventory = false,
    read_temperature = false,
    read_temperature_signal = {type = "virtual", name = "signal-T"},
    read_ingredients = false,
    read_result = false,
    read_result_multiplier = 1,
    read_tech = false,
    read_tech_time_signal = {type = "virtual", name = "signal-T"},
    read_tech_progress = false,
    read_tech_progress_signal = {type = "virtual", name = "signal-P"},
    read_tech_completed = false,
    read_tech_completed_state = false,
    read_tech_completed_signal = {type = "virtual", name = "signal-C"},
    read_rocket_progress = false,
    read_rocket_progress_signal = {type = "item", name = "rocket-part"},
    read_rocket_launch = false,
    read_rocket_launch_signal = {type = "virtual", name = "signal-L"},
    read_rocket_launch_mode = true, -- true for unique, false for hold
    read_rocket_launch_state = false, -- set by launch events
    read_rocket_launch_output_mode = true, -- true for 1, false for launch count
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

  -- Reset circuit output
  local controller_comb = global.controllers[id].controller
  if controller_comb.valid then
    local circuit_buffer = controller_comb.get_control_behavior()
    for idx = 1,circuit_buffer.signals_count do
      circuit_buffer.set_signal(idx, nil)
    end
    controller_comb.get_control_behavior().enabled = false
  end

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
    if controller_comb.valid then
      controller_comb.get_control_behavior().enabled = true
    end
    controller.target = target_entity
    controller.type = target_entity.type
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
    -- Set the constant combinator to disabled (see right info panel)
    entity.get_control_behavior().enabled = false
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

    global.controllers[controller_id].target_position = {x=x,y=y}
    local target = entity.surface.find_entities_filtered{position={x=x,y=y}, type={"assembling-machine", "beacon", "furnace", "lab", "reactor", "rocket-silo"}}
    assign_controller(controller_id, target[1])
  end

  local lookup = {
    ["assembling-machine"] = true,
    ["beacon"] = true,
    ["furnace"] = true,
    ["lab"] = true,
    ["reactor"] = true,
    ["rocket-silo"] = true,
  }
  if entity and lookup[entity.type] then
    local box = entity.bounding_box
    for id, data in pairs(global.controllers) do
      if data.target == nil then
        local x, y = data.target_position.x, data.target_position.y
        if box.left_top.x < x and x < box.right_bottom.x and
           box.left_top.y < y and y < box.right_bottom.y then
           assign_controller(id, entity)
        end
      end
    end
  end

end)


script.on_event({
  defines.events.on_entity_destroyed,
  defines.events.script_raised_destroy
},
function(event)
  local id = event.unit_number
  destroy_controller(id)
end)


local function on_nth_tick()
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
end
script.on_nth_tick(settings.global["advanced-circuit-network-update-interval"].value, on_nth_tick)
script.on_event(defines.events.on_runtime_mod_setting_changed,
function()
  script.on_nth_tick(nil)
  script.on_nth_tick(settings.global["advanced-circuit-network-update-interval"].value, on_nth_tick)
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
  --game.print("entity cloned")
end)

script.on_event(defines.events.on_player_setup_blueprint,
function(event)
  --game.print("blueprint setup")
end)

script.on_event(defines.events.on_area_cloned,
function(event)
  --game.print("area cloned")
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
  elseif event.element.name == "gui-controller-combinator-ingredients" then
    global.controllers[opened_controller_id].read_ingredients = event.element.state
  elseif event.element.name == "gui-controller-combinator-result" then
    global.controllers[opened_controller_id].read_result = event.element.state
    event.element.parent["gui-controller-combinator-result-frame"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-temperature" then
    global.controllers[opened_controller_id].read_temperature = event.element.state
    event.element.parent["gui-controller-combinator-temperature-frame"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-progress" then
    global.controllers[opened_controller_id].read_rocket_progress = event.element.state
    event.element.parent["gui-controller-combinator-rocket-progress-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-rocket-progress-endline"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-launch" then
    global.controllers[opened_controller_id].control_launch = event.element.state
    event.element.parent["gui-controller-combinator-launch-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-launch-endline"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-launch" then
    global.controllers[opened_controller_id].read_rocket_launch = event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-frame2"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-launch-unique" then
    global.controllers[opened_controller_id].read_rocket_launch_mode = event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-hold"].state = not event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-launch-hold" then
    global.controllers[opened_controller_id].read_rocket_launch_mode = not event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-unique"].state = not event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-launch-one" then
    global.controllers[opened_controller_id].read_rocket_launch_output_mode = event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-count"].state = not event.element.state
  elseif event.element.name == "gui-controller-combinator-rocket-launch-count" then
    global.controllers[opened_controller_id].read_rocket_launch_output_mode = not event.element.state
    event.element.parent["gui-controller-combinator-rocket-launch-one"].state = not event.element.state
  elseif event.element.name == "gui-controller-combinator-tech" then
    global.controllers[opened_controller_id].read_tech = event.element.state
    event.element.parent["gui-controller-combinator-tech-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-tech-endline"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-tech-progress" then
    global.controllers[opened_controller_id].read_tech_progress = event.element.state
    event.element.parent["gui-controller-combinator-tech-progress-frame"].visible = event.element.state
    event.element.parent["gui-controller-combinator-tech-progress-endline"].visible = event.element.state
  elseif event.element.name == "gui-controller-combinator-tech-completed" then
    global.controllers[opened_controller_id].read_tech_completed = event.element.state
    event.element.parent["gui-controller-combinator-tech-completed-frame"].visible = event.element.state
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
end)

script.on_event(defines.events.on_gui_elem_changed,
function(event)
  ---
  -- choose-elem-button
  ---

  if event.element.elem_value.name == "signal-everything" then
    event.element.elem_value = nil
  elseif event.element.elem_value.name == "signal-anything" then
    event.element.elem_value = nil
  elseif event.element.elem_value.name == "signal-each" then
    event.element.elem_value = nil
  elseif event.element.elem_value.name == nil then
    event.element.elem_value = nil
  end

  if event.element.name == "gui-controller-combinator-enable-cond1" then
    global.controllers[opened_controller_id].control_enabled_cond1 = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-temperature-signal" then
    global.controllers[opened_controller_id].read_temperature_signal = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-rocket-progress-signal" then
    global.controllers[opened_controller_id].read_rocket_progress_signal = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-launch-cond1" then
    global.controllers[opened_controller_id].control_launch_cond1 = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-rocket-launch-signal" then
    global.controllers[opened_controller_id].read_rocket_launch_signal = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-tech-time-signal" then
    global.controllers[opened_controller_id].read_tech_time_signal = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-tech-progress-signal" then
    global.controllers[opened_controller_id].read_tech_progress_signal = event.element.elem_value
  elseif event.element.name == "gui-controller-combinator-tech-completed-signal" then
    global.controllers[opened_controller_id].read_tech_completed_signal = event.element.elem_value
  end
  --[[
  elseif event.element.name == "gui-controller-combinator-enable-cond3" then
    global.controllers[opened_controller_id].control_enabled_cond3 = event.element.signal
  elseif event.element.name == "gui-controller-combinator-launch-cond3" then
    global.controllers[opened_controller_id].control_launch_cond3 = event.element.signal
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
  elseif event.element.name == "gui-controller-combinator-launch-cond2" then
    global.controllers[opened_controller_id].control_launch_cond2 = event.element.selected_index
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
  if event.element.name == "gui-controller-combinator-enable-cond3" then
    global.controllers[opened_controller_id].control_enabled_cond3 = event.element.text
  elseif event.element.name == "gui-controller-combinator-launch-cond3" then
    global.controllers[opened_controller_id].control_launch_cond3 = event.element.text
  end
end)

script.on_event(defines.events.on_gui_value_changed,
function(event)
  ---
  -- slider
  ---
  if event.element.name == "gui-controller-combinator-result-multiplier" then
    local realval = event.element.slider_value
    if realval >= 0 then
      realval = math.pow(10, realval)
    end
    global.controllers[opened_controller_id].read_result_multiplier = realval
    event.element.parent["gui-controller-combinator-result-multiplier-label"].caption = realval
  end
end)


script.on_event(defines.events.on_rocket_launch_ordered,
function(event)
  for id, data in pairs(global.controllers) do
    if data.target == event.rocket_silo then
      data.read_rocket_launch_state = true
    end
  end
end)

script.on_event(defines.events.on_rocket_launched,
function(event)
  for id, data in pairs(global.controllers) do
    if data.target and data.target.unit_number == event.rocket_silo.unit_number then
      data.read_rocket_launch_state = false
    end
  end
end)

script.on_event(defines.events.on_research_finished,
function(event)
  for id, data in pairs(global.controllers) do
    if data.type == "lab" then
      data.read_tech_completed_state = true
    end
  end
end)


