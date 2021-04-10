
local function update_none(data)
  return
end

local function update_nuclear_reactor(data)
  assert(data.type == "nuclear-reactor")
  assert(data.target.name == "nuclear-reactor")

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

  -- Reset circuit output
  local circuit_buffer = data.controller.get_control_behavior()
  for idx = 1,circuit_buffer.signals_count do
    circuit_buffer.set_signal(idx, nil)
  end

  if data.read_inventory then
    local idx = 2
    local slot1 = data.target.get_fuel_inventory().get_contents()
    for k,v in pairs(slot1) do
      circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
      idx = idx + 1
    end
    local slot1 = data.target.get_burnt_result_inventory().get_contents()
    for k,v in pairs(slot1) do
      circuit_buffer.set_signal(idx, {signal = {type = "item", name = k}, count = v})
      idx = idx + 1
    end
    assert(idx <= 4)
  end

  if data.read_temperature and data.read_temperature_signal then
    local temperature = math.floor(data.target.temperature)
    circuit_buffer.set_signal(1, {signal = data.read_temperature_signal, count = temperature})
  end
end

return {
  --["rocket-silo"] = build_controller_combinator_gui,
  ["nuclear-reactor"] = update_nuclear_reactor,
  ["none"] = update_none
}
