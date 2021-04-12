
local function build_none(screen, data)
  local main_frame = screen.add{
    type = "frame",
    name = "gui-controller-combinator",
    caption = {"entity-name.controller-combinator"},
  }
  main_frame.auto_center = true

  local content_frame = main_frame.add{
    type = "frame",
    style = "inside_shallow_frame_with_padding"
  }.add{
    type = "flow",
    direction = "vertical",
    style = "inset_frame_container_vertical_flow"
  }

  local flow = content_frame.add{
    type = "flow",
    direction = "horizontal",
    style = "status_flow"
  }
  flow.style.vertical_align = "center"
  do
    flow.add{
      type = "sprite",
      sprite = "utility/status_not_working"
    }
    flow.add{
      type = "label",
      caption = {"gui.not-attached"},
      tooltip = {"gui.not-attached-tooltip"}
    }
  end
  local preview_frame = content_frame.add{
    type = "frame",
    style = "entity_frame_without_padding"
  }
  do
    local preview = preview_frame.add{
      type = "entity-preview",
    }
    preview.entity = data.controller
    preview.style.natural_height = 100
    preview.style.horizontally_stretchable = true
    preview.style.horizontally_squashable = true
  end
  return main_frame
end


local function build_base(screen, data)
  local main_frame = screen.add{
    type = "frame",
    name = "gui-controller-combinator",
    caption = {"entity-name.controller-combinator"}
  }
  main_frame.auto_center = true

  local content_frame = main_frame.add{
    type = "frame",
    style = "inside_shallow_frame_with_padding"
  }.add{
    type = "flow",
    direction = "vertical",
    style = "inset_frame_container_vertical_flow"
  }

  local flow = content_frame.add{
    type = "flow",
    direction = "horizontal",
    style = "status_flow"
  }
  flow.style.vertical_align = "center"
  do
    flow.add{
      type = "sprite",
      sprite = "utility/status_working"
    }
    flow.add{
      type = "label",
      caption = {"gui.attached-to", data.target.name, {"entity-name." .. data.target.name}}
    }
  end

  local preview_frame = content_frame.add{
    type = "frame",
    style = "entity_frame_without_padding"
  }
  do
    local preview = preview_frame.add{
      type = "entity-preview",
    }
    preview.entity = data.target
    preview.style.natural_height = 100
    preview.style.horizontally_stretchable = true
    preview.style.horizontally_squashable = true
    local preview = preview_frame.add{
      type = "entity-preview",
    }
    preview.entity = data.controller
    preview.style.natural_height = 100
    preview.style.horizontally_stretchable = true
    preview.style.horizontally_squashable = true
  end
  return {main_frame, content_frame}
end


local function build_control_enable(content_frame, data, endline)
  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-enable",
    caption = {"gui.enable"},
    state = data.control_enabled
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-enable-frame",
      style = "player_input_horizontal_flow",
      visible = data.control_enabled
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.condition"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-enable-cond1",
      elem_type = "signal",
      signal = data.control_enabled_cond1
    }
    subframe.add{
      type = "drop-down",
      name = "gui-controller-combinator-enable-cond2",
      items = {">", "<", "=", "≥", "≤", "≠"},
      selected_index = data.control_enabled_cond2
    }.style.minimal_width = 51
    --[[
    subframe.add{
    type = "choose-elem-button",
    name = "gui-controller-combinator-enable-cond3",
    elem_type = "signal",
    signal = data.control_enabled_cond3
    }
    ]]
    subframe.add{
      type = "textfield",
      name = "gui-controller-combinator-enable-cond3",
      text = data.control_enabled_cond3,
      numeric = true,
      lose_focus_on_confirm = true
    }
    if endline then
      content_frame.add{
        type = "line",
        name = "gui-controller-combinator-enable-endline",
        visible = data.control_enabled
      }
    end
  end
end


local function build_read_inventory(content_frame, data)
  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-inventory",
    caption = {"gui.read-inventory"},
    state = data.read_inventory
  }
end


local function build_assembling_machine(screen, data)
  assert(data.type == "assembling-machine")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  build_read_inventory(content_frame, data)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-ingredients",
    caption = {"gui.read-ingredients"},
    state = data.read_ingredients
  }

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-result",
    caption = {"gui.read-result"},
    tooltip = {"gui.read-result-description"},
    state = data.read_result
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-result-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_result
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-multiplier"},
      tooltip = {"gui.output-multiplier-description"},
      style = "bold_label"
    }
    local logval = data.read_result_multiplier
    -- actual values: -1, 1, 10, 100, 1000, 10000, 100000, 1000000...
    if logval >= 0 then
      logval = math.log(logval, 10)
    end
    subframe.add{
      type = "slider",
      name = "gui-controller-combinator-result-multiplier",
      elem_type = "signal",
      minimum_value = -1,
      maximum_value = 9,
      value = logval,
      discrete_slider = true
    }
    subframe.add{
      type = "label",
      name = "gui-controller-combinator-result-multiplier-label",
      caption = data.read_result_multiplier,
      style = "bold_label"
    }
  end

  return main_frame
end


local function build_beacon(screen, data)
  assert(data.type == "beacon")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  build_read_inventory(content_frame, data)

  return main_frame
end


local function build_furnace(screen, data)
  assert(data.type == "furnace")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  build_read_inventory(content_frame, data)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-ingredients",
    caption = {"gui.read-ingredients"},
    state = data.read_ingredients
  }

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-result",
    caption = {"gui.read-result"},
    tooltip = {"gui.read-result-description"},
    state = data.read_result
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-result-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_result
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-multiplier"},
      tooltip = {"gui.output-multiplier-description"},
      style = "bold_label"
    }
    local logval = data.read_result_multiplier
    -- actual values: -1, 1, 10, 100, 1000, 10000, 100000, 1000000...
    if logval >= 0 then
      logval = math.log(logval, 10)
    end
    subframe.add{
      type = "slider",
      name = "gui-controller-combinator-result-multiplier",
      elem_type = "signal",
      minimum_value = -1,
      maximum_value = 9,
      value = logval,
      discrete_slider = true
    }
    subframe.add{
      type = "label",
      name = "gui-controller-combinator-result-multiplier-label",
      caption = data.read_result_multiplier,
      style = "bold_label"
    }
  end

  return main_frame
end


local function build_lab(screen, data)
  assert(data.type == "lab")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  build_read_inventory(content_frame, data)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-tech",
    caption = {"gui.read-tech"},
    state = data.read_tech
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-tech-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_tech
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.time-output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-tech-time-signal",
      elem_type = "signal",
      signal = data.read_tech_time_signal
    }
    content_frame.add{
      type = "line",
      name = "gui-controller-combinator-tech-endline",
      visible = data.read_tech
    }
  end

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-tech-progress",
    caption = {"gui.read-tech-progress"},
    tooltip = {"gui.read-tech-progress-description"},
    state = data.read_tech_progress
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-tech-progress-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_tech_progress
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-tech-progress-signal",
      elem_type = "signal",
      signal = data.read_tech_progress_signal
    }
    content_frame.add{
      type = "line",
      name = "gui-controller-combinator-tech-progress-endline",
      visible = data.read_tech_progress
    }
  end

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-tech-completed",
    caption = {"gui.read-tech-completed"},
    state = data.read_tech_completed
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-tech-completed-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_tech_completed
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-tech-completed-signal",
      elem_type = "signal",
      signal = data.read_tech_completed_signal
    }
  end

  return main_frame
end


local function build_reactor(screen, data)
  assert(data.type == "reactor")
  assert(data.control_enabled ~= nil)
  assert(data.control_enabled_cond2 ~= nil)
  assert(data.control_enabled_cond3 ~= nil)
  assert(data.read_inventory ~= nil)
  assert(data.read_temperature ~= nil)

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  build_read_inventory(content_frame, data)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-temperature",
    caption = {"gui.read-temperature"},
    state = data.read_temperature
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-temperature-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_temperature
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-temperature-signal",
      elem_type = "signal",
      signal = data.read_temperature_signal
    }
  end

  return main_frame
end


local function build_rocket_silo(screen, data)
  assert(data.type == "rocket-silo")
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

  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  build_control_enable(content_frame, data, true)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-launch",
    caption = {"gui.launch"},
    state = data.control_launch
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-launch-frame",
      style = "player_input_horizontal_flow",
      visible = data.control_launch
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.condition"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-launch-cond1",
      elem_type = "signal",
      signal = data.control_launch_cond1
    }
    subframe.add{
      type = "drop-down",
      name = "gui-controller-combinator-launch-cond2",
      items = {">", "<", "=", "≥", "≤", "≠"},
      selected_index = data.control_launch_cond2
    }.style.minimal_width = 51
    --[[
    subframe.add{
    type = "choose-elem-button",
    name = "gui-controller-combinator-launch-cond3",
    elem_type = "signal",
    signal = data.control_launch_cond3
    }
    ]]
    subframe.add{
      type = "textfield",
      name = "gui-controller-combinator-launch-cond3",
      text = data.control_launch_cond3,
      numeric = true,
      lose_focus_on_confirm = true
    }
    content_frame.add{
      type = "line",
      name = "gui-controller-combinator-launch-endline",
      visible = data.control_launch
    }
  end

  build_read_inventory(content_frame, data)

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-rocket-progress",
    caption = {"gui.read-rocket-progress"},
    state = data.read_rocket_progress
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-rocket-progress-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_rocket_progress
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-rocket-progress-signal",
      elem_type = "signal",
      signal = data.read_rocket_progress_signal
    }
    content_frame.add{
      type = "line",
      name = "gui-controller-combinator-rocket-progress-endline",
      visible = data.read_rocket_progress
    }
  end

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-rocket-launch",
    caption = {"gui.read-rocket-launch"},
    state = data.read_rocket_launch
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-rocket-launch-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_rocket_launch
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "bold_label"
    }
    subframe.add{
      type = "choose-elem-button",
      name = "gui-controller-combinator-rocket-launch-signal",
      elem_type = "signal",
      signal = data.read_rocket_launch_signal
    }
    local bulletframe = subframe.add{
      type = "flow",
      direction = "vertical"
    }
    bulletframe.add{
      type = "radiobutton",
      name = "gui-controller-combinator-rocket-launch-one",
      caption = {"gui-decider.one"},
      tooltip = {"gui.one-mode-description"},
      state = data.read_rocket_launch_output_mode
    }
    bulletframe.add{
      type = "radiobutton",
      name = "gui-controller-combinator-rocket-launch-count",
      caption = {"gui.count-mode"},
      tooltip = {"gui.count-mode-description"},
      state = not data.read_rocket_launch_output_mode
    }
    local subframe2 = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-rocket-launch-frame2",
      style = "player_input_horizontal_flow",
      visible = data.read_rocket_launch
    }
    subframe2.style.vertical_align = "center"
    subframe2.add{
      type = "label",
      caption = {"gui.output-mode"},
      style = "bold_label"
    }
    subframe2.add{
      type = "radiobutton",
      name = "gui-controller-combinator-rocket-launch-unique",
      caption = {"gui-control-behavior-modes-guis.pulse-mode"},
      tooltip = {"gui.pulse-mode-description"},
      state = data.read_rocket_launch_mode
    }
    subframe2.add{
      type = "radiobutton",
      name = "gui-controller-combinator-rocket-launch-hold",
      caption = {"gui-control-behavior-modes-guis.hold-mode"},
      tooltip = {"gui.hold-mode-description"},
      state = not data.read_rocket_launch_mode
    }
  end

  return main_frame
end


return {
  ["assembling-machine"] = build_assembling_machine,
  ["beacon"] = build_beacon,
  ["furnace"] = build_furnace,
  ["lab"] = build_lab,
  ["rocket-silo"] = build_rocket_silo,
  ["reactor"] = build_reactor,
  ["none"] = build_none
}

