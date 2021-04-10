
data:extend({
  {
    type = "corpse",
    name = "controller-combinator-remnants",
    icon = "__controlable-automation__/graphics/icons/controller-combinator.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "not-on-map"},
    subgroup = "circuit-network-remnants",
    order = "a-d-a",
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 1,
    tile_height = 1,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet (1,
    {
      filename = "__controlable-automation__/graphics/entity/controller-combinator/controller-combinator-remnants.png",
      line_length = 1,
      width = 60,
      height = 56,
      frame_count = 1,
      variation_count = 1,
      axially_symmetrical = false,
      direction_count = 4,
      shift = util.by_pixel(0, 0),
      hr_version =
      {
        filename = "__controlable-automation__/graphics/entity/controller-combinator/hr-controller-combinator-remnants.png",
        line_length = 1,
        width = 118,
        height = 112,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 4,
        shift = util.by_pixel(0, 0),
        scale = 0.5
      }
    })
  }
})

