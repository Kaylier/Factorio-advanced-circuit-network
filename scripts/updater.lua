
local function update_none(data)
  return
end


local function update_reactor(data)
  assert(data.type == "reactor")
  assert(data.target.type == "reactor")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_temperature ~= nil)

  -- circuit output reservations:
  -- 1: temperature
  -- 2+: inventory

  -- Reset circuit output
  local circuit_buffer = data.controller.get_control_behavior()
  for idx = 1,circuit_buffer.signals_count do
    circuit_buffer.set_signal(idx, nil)
  end

  if data.read_inventory then
    local idx = 2
    local content = data.target.get_fuel_inventory().get_contents()
    for k,v in pairs(content) do
      circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
      idx = idx + 1
    end
    local content = data.target.get_burnt_result_inventory().get_contents()
    for k,v in pairs(content) do
      circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
      idx = idx + 1
    end
    assert(idx <= 4)
  end

  if data.read_temperature and data.read_temperature_signal then
    local temperature = math.floor(data.target.temperature)
    circuit_buffer.set_signal(1, {signal = data.read_temperature_signal, count = temperature})
  end

  local res = true
  -- TODO: Find a better way to prevent stopping when it's currently burning
  if data.target.burner.remaining_burning_fuel <= 2000000/3 and data.control_enabled then

    local cond1 = 0
    local cond2 = 2
    local cond3 = 0
    if data.control_enabled_cond1 then
      cond1 = data.controller.get_merged_signal(data.control_enabled_cond1)
    end
    if data.control_enabled_cond2 then
      cond2 = data.control_enabled_cond2
    end
    if data.control_enabled_cond3 then
      cond3 = tonumber(data.control_enabled_cond3)
    end
    if cond2 == 1 then
      res = (cond1 > cond3)
    elseif cond2 == 2 then
      res = (cond1 < cond3)
    elseif cond2 == 3 then
      res = (cond1 == cond3)
    elseif cond2 == 4 then
      res = (cond1 >= cond3)
    elseif cond2 == 5 then
      res = (cond1 <= cond3)
    elseif cond2 == 6 then
      res = (cond1 ~= cond3)
    end
  end
  data.target.active = res
end


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

  -- circuit output reservations:
  -- 1: rocket progress
  -- 2: rocket progress
  -- 3+: inventory

  -- Reset circuit output
  local circuit_buffer = data.controller.get_control_behavior()
  for idx = 1,circuit_buffer.signals_count do
    circuit_buffer.set_signal(idx, nil)
  end

  if data.read_inventory then
    local idx = 3
    local inventories = {
      defines.inventory.assembling_machine_input,
      defines.inventory.assembling_machine_output,
      defines.inventory.assembling_machine_modules,
      defines.inventory.rocket_silo_rocket,
      defines.inventory.rocket_silo_result,
    }
    for i,inventory_name in pairs(inventories) do
      local inventory = data.target.get_inventory(inventory_name)
      if inventory then
        local content = inventory.get_contents()
        for k,v in pairs(content) do
          circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
          idx = idx + 1
        end
      end
    end
  end

  if data.read_rocket_progress and data.read_rocket_progress_signal then
    local progress = data.target.rocket_parts
    circuit_buffer.set_signal(1, {signal = data.read_rocket_progress_signal, count = progress})
  end

  if data.read_rocket_launch and data.read_rocket_launch_state then
    local output = 1

    if data.read_rocket_launch_output_mode == false then -- launch count
      output = data.target.products_finished
    end

    circuit_buffer.set_signal(2, {signal = data.read_rocket_launch_signal, count = output})

    if data.read_rocket_launch_mode == true then -- unique mode
      data.read_rocket_launch_state = false
    end
  end

  local res = true
  if data.control_enabled then
    local cond1 = 0
    local cond2 = 2
    local cond3 = 0
    if data.control_enabled_cond1 then
      cond1 = data.controller.get_merged_signal(data.control_enabled_cond1)
    end
    if data.control_enabled_cond2 then
      cond2 = data.control_enabled_cond2
    end
    if data.control_enabled_cond3 then
      cond3 = tonumber(data.control_enabled_cond3)
    end
    if cond2 == 1 then
      res = (cond1 > cond3)
    elseif cond2 == 2 then
      res = (cond1 < cond3)
    elseif cond2 == 3 then
      res = (cond1 == cond3)
    elseif cond2 == 4 then
      res = (cond1 >= cond3)
    elseif cond2 == 5 then
      res = (cond1 <= cond3)
    elseif cond2 == 6 then
      res = (cond1 ~= cond3)
    end
  end
  data.target.active = res

  if data.control_launch then
    local res = false
    local cond1 = 0
    local cond2 = 1
    local cond3 = 0
    if data.control_launch_cond1 then
      cond1 = data.controller.get_merged_signal(data.control_launch_cond1)
    end
    if data.control_launch_cond2 then
      cond2 = data.control_launch_cond2
    end
    if data.control_launch_cond3 then
      cond3 = tonumber(data.control_launch_cond3)
    end
    if cond2 == 1 then
      res = (cond1 > cond3)
    elseif cond2 == 2 then
      res = (cond1 < cond3)
    elseif cond2 == 3 then
      res = (cond1 == cond3)
    elseif cond2 == 4 then
      res = (cond1 >= cond3)
    elseif cond2 == 5 then
      res = (cond1 <= cond3)
    elseif cond2 == 6 then
      res = (cond1 ~= cond3)
    end
    if res then
      data.target.launch_rocket()
    end
  end

end


return {
  ["rocket-silo"] = update_rocket_silo,
  ["reactor"] = update_reactor,
  ["none"] = update_none
}
