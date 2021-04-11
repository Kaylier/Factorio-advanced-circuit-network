local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

data:extend({
  {
    --- PrototypeBase
    type = "constant-combinator",
    name = "controller-combinator",

    --- Prototype/Entity
    icon = "__controlable-automation__/graphics/icons/controller-combinator.png",
    icon_size = 64,
    icon_mipmaps = 4,

    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "controller-combinator",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.1, result = "controller-combinator"},

    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/combinator.ogg",
        volume = 0.45
      },
      -- max_sounds_per_type = 2,
      fade_in_ticks = 4,
      fade_out_ticks = 20,
      audible_distance_modifier = 0.2,
      match_speed_to_activity = true
    },
    vehicle_impact_sound = sounds.generic_impact,
    open_sound = sounds.machine_open,
    close_sound = sounds.machine_close,


    --- Prototype/EntityWithHealth
    corpse = "controller-combinator-remnants",
    damaged_trigger_effect = hit_effects.entity(),
    dying_explosion = "constant-combinator-explosion",
    max_health = 120,

    --- Prototype/ConstantCombinator
    item_slot_count = 32, -- Should be enough
    activity_led_light = {
      intensity = 0,
      size = 1,
      color = {r = 1.0, g = 1.0, b = 1.0}
    },
    activity_led_light_offsets = {
      {0.296875, -0.40625},
      {0.25, -0.03125},
      {-0.296875, -0.078125},
      {-0.21875, -0.46875}
    },
    activity_led_sprites = {
      north = util.draw_as_glow
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-N.png",
        width = 8,
        height = 6,
        frame_count = 1,
        shift = util.by_pixel(9, -12),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-N.png",
          width = 14,
          height = 12,
          frame_count = 1,
          shift = util.by_pixel(9, -11.5)
        }
      },
      east = util.draw_as_glow
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-E.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(8, 0),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-E.png",
          width = 14,
          height = 14,
          frame_count = 1,
          shift = util.by_pixel(7.5, -0.5)
        }
      },
      south = util.draw_as_glow
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-S.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-9, 2),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-S.png",
          width = 14,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-9, 2.5)
        }
      },
      west = util.draw_as_glow
      {
        filename = "__base__/graphics/entity/combinator/activity-leds/constant-combinator-LED-W.png",
        width = 8,
        height = 8,
        frame_count = 1,
        shift = util.by_pixel(-7, -15),
        hr_version =
        {
          scale = 0.5,
          filename = "__base__/graphics/entity/combinator/activity-leds/hr-constant-combinator-LED-W.png",
          width = 14,
          height = 16,
          frame_count = 1,
          shift = util.by_pixel(-7, -15)
        }
      }
    },

    circuit_wire_connection_points = {
      {
        shadow =
        {
          red = util.by_pixel(25, 20),
          green = util.by_pixel(9, 20)
        },
        wire =
        {
          red = util.by_pixel(9, 7.5),
          green = util.by_pixel(-6.5, 7.5)
        }
      },
      {
        shadow =
        {
          red = util.by_pixel(1, 11),
          green = util.by_pixel(1, -2)
        },
        wire =
        {
          red = util.by_pixel(-15, -0.5),
          green = util.by_pixel(-15, -13.5)
        }
      },
      {
        shadow =
        {
          red = util.by_pixel(7, -6),
          green = util.by_pixel(23, -6)
        },
        wire =
        {
          red = util.by_pixel(-8.5, -17.5),
          green = util.by_pixel(7, -17.5)
        }
      },
      {
        shadow =
        {
          red = util.by_pixel(32, -5),
          green = util.by_pixel(32, 8)
        },
        wire =
        {
          red = util.by_pixel(16, -16.5),
          green = util.by_pixel(16, -3.5)
        }
      }
    },
    circuit_wire_max_distance = 9,

    sprites = make_4way_animation_from_spritesheet({ layers =
    {
      {
        filename = "__controlable-automation__/graphics/entity/controller-combinator/controller-combinator.png",
        width = 58,
        height = 52,
        frame_count = 1,
        shift = util.by_pixel(0, 5),
        hr_version =
        {
          scale = 0.5,
          filename = "__controlable-automation__/graphics/entity/controller-combinator/hr-controller-combinator.png",
          width = 114,
          height = 102,
          frame_count = 1,
          shift = util.by_pixel(0, 5)
        }
      },
      {
        filename = "__controlable-automation__/graphics/entity/controller-combinator/controller-combinator-shadow.png",
        width = 50,
        height = 34,
        frame_count = 1,
        shift = util.by_pixel(9, 6),
        draw_as_shadow = true,
        hr_version =
        {
          scale = 0.5,
          filename = "__controlable-automation__/graphics/entity/controller-combinator/hr-controller-combinator-shadow.png",
          width = 98,
          height = 66,
          frame_count = 1,
          shift = util.by_pixel(8.5, 5.5),
          draw_as_shadow = true
        }
      }
    }
  })
}
})

