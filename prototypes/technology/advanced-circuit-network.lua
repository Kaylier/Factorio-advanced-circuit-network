
data:extend({
  {
    --- PrototypeBase
    type = "technology",
    name = "advanced-circuit-network",
    order = "a-d-e",

    --- Prototype/Technology
    icon = "__controlable-automation__/graphics/technology/advanced-circuit-network.png",
    icon_size = 256,
    icon_mipmaps = 4,

    unit = {
      count = 200,
      time = 30,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      }
    },
    effects = {{ type = "unlock-recipe", recipe = "controller-combinator" }},
    prerequisites = {"circuit-network", "advanced-electronics"}
  }
})

