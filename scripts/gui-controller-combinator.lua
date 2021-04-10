
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
      caption = {"gui.attached-to", data.type, {"entity-name." .. data.type}}
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



local function build_nuclear_reactor(screen, data)
  local base = build_base(screen, data)
  local main_frame, content_frame = base[1], base[2]

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-enable",
    caption = {"gui.enable"},
    state = data.control_enabled or false
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-enable-frame",
      style = "player_input_horizontal_flow",
      visible = data.control_enabled or false
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.condition"},
      style = "caption_label"
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
      selected_index = data.control_enabled_cond2 or 2
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
      text = data.control_enabled_cond3 or "0",
      numeric = true,
      lose_focus_on_confirm = true
    }
    content_frame.add{
      type = "line",
      name = "gui-controller-combinator-enable-endline",
      visible = data.control_enabled or false
    }
  end

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-inventory",
    caption = {"gui.read-inventory"},
    state = data.read_inventory or false
  }

  content_frame.add{
    type = "checkbox",
    name = "gui-controller-combinator-temperature",
    caption = {"gui.read-temperature"},
    state = data.read_temperature or false
  }
  do
    local subframe = content_frame.add{
      type = "flow",
      name = "gui-controller-combinator-temperature-frame",
      style = "player_input_horizontal_flow",
      visible = data.read_temperature or false
    }
    subframe.style.vertical_align = "center"
    subframe.add{
      type = "label",
      caption = {"gui.output-signal"},
      style = "caption_label"
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

return {
  --["rocket-silo"] = build_controller_combinator_gui,
  ["nuclear-reactor"] = build_nuclear_reactor,
  ["none"] = build_none
}
