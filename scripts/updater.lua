

local function init_circuit_buffer(data)
  local circuit_buffer = data.controller.get_control_behavior()

  circuit_buffer.parameters = nil
  circuit_buffer.enabled = true

  return circuit_buffer
end


local function eval_signal_comp_txt(data, sig, cmp, txt)
  local v1 = 0
  if sig then
    v1 = data.controller.get_merged_signal(sig)
  end
  local v2 = tonumber(txt) or 0

  if cmp == 1 then
    return v1 > v2
  elseif cmp == 2 then
    return v1 < v2
  elseif cmp == 3 then
    return v1 == v2
  elseif cmp == 4 then
    return v1 >= v2
  elseif cmp == 5 then
    return v1 <= v2
  elseif cmp == 6 then
    return v1 ~= v2
  end
end


local function read_inventories(data, circuit_buffer, inventories)
  if not data.read_inventory then
    return 1
  end
  local idx = 1
  for i, inventory_name in pairs(inventories) do
    local inventory = data.target.get_inventory(inventory_name)
    if inventory then
      local content = inventory.get_contents()
      for k,v in pairs(content) do
        circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
        idx = idx + 1
      end
    end
  end
  return idx
end


local function update_none(data)
  return
end


local assembling_machine_inventories = {
  defines.inventory.assembling_machine_input,
  defines.inventory.assembling_machine_output,
  defines.inventory.assembling_machine_modules
}
local function update_assembling_machine(data)
  assert(data.type == "assembling-machine")
  assert(data.target.type == "assembling-machine")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_ingredients ~= nil)
  assert(data.read_result ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, assembling_machine_inventories)
  
  local recipe = data.target.get_recipe()
  if data.read_ingredients and recipe then
    local ingredients = recipe.ingredients
    for i,ing in pairs(ingredients) do
      circuit_buffer.set_signal(circuit_idx, {signal = {type = ing.type, name = ing.name}, count = ing.amount})
      circuit_idx = circuit_idx + 1
    end
  end

  if data.read_result and recipe then
    local results = recipe.products
    for i, p in pairs(results) do
      local prob = p.probability or 1
      local amount = p.amount
      if amount == nil then
        amount = ((p.amount_min or 0) + (p.amount_max or 1))/2
      end
      amount = amount * prob * data.read_result_multiplier

      circuit_buffer.set_signal(circuit_idx, {signal = {type = p.type, name = p.name}, count = amount})
      circuit_idx = circuit_idx + 1
    end

  end

  data.target.active = (not data.control_enabled) or eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)
end


local beacon_inventories = {
  defines.inventory.beacon_modules
}
local function update_beacon(data)
  assert(data.type == "beacon")
  assert(data.target.type == "beacon")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, beacon_inventories)

  data.target.active = (not data.control_enabled) or eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)
end


local furnace_inventories = {
  defines.inventory.furnace_source,
  defines.inventory.furnace_result,
  defines.inventory.furnace_modules
}
local function update_furnace(data)
  assert(data.type == "furnace")
  assert(data.target.type == "furnace")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_ingredients ~= nil)
  assert(data.read_result ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, furnace_inventories)

  local recipe = data.target.get_recipe() or data.target.previous_recipe
  if data.read_ingredients and recipe then
    local ingredients = recipe.ingredients
    for i,ing in pairs(ingredients) do
      circuit_buffer.set_signal(circuit_idx, {signal = {type = ing.type, name = ing.name}, count = ing.amount})
      circuit_idx = circuit_idx + 1
    end
  end

  if data.read_result and recipe then
    local results = recipe.products
    for i, p in pairs(results) do
      local prob = p.probability or 1
      local amount = p.amount
      if amount == nil then
        amount = ((p.amount_min or 0) + (p.amount_max or 1))/2
      end
      amount = amount * prob * data.read_result_multiplier

      circuit_buffer.set_signal(circuit_idx, {signal = {type = p.type, name = p.name}, count = amount})
      circuit_idx = circuit_idx + 1
    end

  end

  data.target.active = (not data.control_enabled) or eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)
end


local lab_inventories = {
  defines.inventory.lab_input,
  defines.inventory.lab_modules
}
local function update_lab(data)
  assert(data.type == "lab")
  assert(data.target.type == "lab")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, lab_inventories)

  local force = data.target.force

  if data.read_tech and force.current_research then
    local current_research = force.current_research
    local multiplier = current_research.research_unit_count
    local ingredients = current_research.research_unit_ingredients
    for i,ing in pairs(ingredients) do
      circuit_buffer.set_signal(circuit_idx, {signal = {type = ing.type, name = ing.name}, count = multiplier * ing.amount})
      circuit_idx = circuit_idx + 1
    end

    if data.read_tech_time_signal then
      circuit_buffer.set_signal(circuit_idx, {signal = data.read_tech_time_signal, count = multiplier * current_research.research_unit_energy/60})
      circuit_idx = circuit_idx + 1
    end
  end

  if data.read_tech_progress and data.read_tech_progress_signal then
    local progress = tonumber(force.research_progress*100)
    circuit_buffer.set_signal(circuit_idx, {signal = data.read_tech_progress_signal, count = progress})
    circuit_idx = circuit_idx + 1
  end

  if data.read_tech_completed and data.read_tech_completed_signal and data.read_tech_completed_state then
    circuit_buffer.set_signal(circuit_idx, {signal = data.read_tech_completed_signal, count = 1})
    circuit_idx = circuit_idx + 1

    data.read_tech_completed_state = false
  end

  
  data.target.active = (not data.control_enabled) or eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)
end


local reactor_inventories = {
  defines.inventory.fuel,
  defines.inventory.burnt_result
}
local function update_reactor(data)
  assert(data.type == "reactor")
  assert(data.target.type == "reactor")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_temperature ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, reactor_inventories)
  
  if data.read_temperature and data.read_temperature_signal then
    local temperature = math.floor(data.target.temperature)
    circuit_buffer.set_signal(circuit_idx, {signal = data.read_temperature_signal, count = temperature})
    circuit_idx = circuit_idx + 1
  end

  local res = true
  -- TODO: Find a better way to prevent stopping when it's currently burning
  if data.target.burner.remaining_burning_fuel <= 2000000/3 and data.control_enabled then
    res = eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)
  end
  data.target.active = res
end


local rocket_silo_inventories = {
  defines.inventory.assembling_machine_input,
  defines.inventory.assembling_machine_output,
  defines.inventory.assembling_machine_modules,
  defines.inventory.rocket_silo_rocket,
  defines.inventory.rocket_silo_result
}
local function update_rocket_silo(data)
  assert(data.type == "rocket-silo")
  assert(data.target.type == "rocket-silo")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.control_launch ~= nil)
  assert(data.control_launch_cond2 ~= nil)
  assert(data.control_launch_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_rocket_progress ~= nil)
  assert(data.read_rocket_launch ~= nil)
  assert(data.read_rocket_launch_mode ~= nil)

  local circuit_buffer = init_circuit_buffer(data)
  local circuit_idx = read_inventories(data, circuit_buffer, rocket_silo_inventories)
  
  if data.read_rocket_progress and data.read_rocket_progress_signal then
    local progress = data.target.rocket_parts
    circuit_buffer.set_signal(circuit_idx, {signal = data.read_rocket_progress_signal, count = progress})
    circuit_idx = circuit_idx + 1
  end

  if data.read_rocket_launch and data.read_rocket_launch_state then
    local output = 1

    if data.read_rocket_launch_output_mode == false then -- launch count
      output = data.target.products_finished
    end

    circuit_buffer.set_signal(circuit_idx, {signal = data.read_rocket_launch_signal, count = output})
    circuit_idx = circuit_idx + 1

    if data.read_rocket_launch_mode == true then -- unique mode
      data.read_rocket_launch_state = false
    end
  end

  data.target.active = (not data.control_enabled) or eval_signal_comp_txt(data, data.control_enabled_cond1, data.control_enabled_cond2, data.control_enabled_cond3)

  if data.control_launch and eval_signal_comp_txt(data, data.control_launch_cond1, data.control_launch_cond2, data.control_launch_cond3) then
    data.target.launch_rocket()
  end
end


return {
  ["assembling-machine"] = update_assembling_machine,
  ["beacon"] = update_beacon,
  ["furnace"] = update_furnace,
  ["lab"] = update_lab,
  ["rocket-silo"] = update_rocket_silo,
  ["reactor"] = update_reactor,
  ["none"] = update_none
}

