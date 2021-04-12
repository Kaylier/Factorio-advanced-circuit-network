# Factorio mod: Advanced circuit network

This mod adds a new entity: the controller combinator.
When a controller combinator is placed facing a machine, it allow the user to control the machine and to output information to the circuit network.

Note: if several controller are on the same machine, only one effectively control it.

## Description
### Assembling machines
Concerns: assembling machine 1/2/3, Oil refinery, Chemical plant and Centrifuge.

Possible output signal:
- Items in input, output and module slots
- Recipe ingredients
- Recipe output (if random, returns the average output)

Possible control options:
- Disable crafting
- Set recipe (recipe signal? spill items?)

### Beacons
Possible output signal:
- Items in module slots

Possible control options:
- Disable

### Furnaces
Possible output signal:
- Items in input, output and module slots
- Recipe ingredient
- Recipe output (if random, returns the average output)

Possible control options:
- Disable smelting

### Labs
Possible output signal:
- Items in input and module slots
- Technology science pack and time requirement
- Technology progress
- Pulse when a technology is completed

Possible control options:
- Disable

Note: In case of several forces on the map, the last user of the controller defines which force is considered.

### Nuclear reactor
Possible output signal:
- Items in fuel and burnt slots
- Temperature

Possible control options:
- Disable auto-refueling

### Rocket silo
Possible output signal:
- Items in input, rocket, output and module slots
- Rocket progress
- Rocket launch (unique or continuous)

Possible control options:
- Disable crafting
- Launch rocket

Note: The vanilla auto-launch system acts as a OR condition with the controller. Remember to disable it if you don't want it.

Note 2: if you want a standalone controller, activating the silo on a condition on its inventory, you'll need to connect a cable to create the link between the output and the input (to a pole for ex).


## Localization
Available languages: English, French


## Known bugs
- signal-everything, signal-anything and signal-each resets to no signal. These are invalid signals and shouldn't show, but I don't know how to hide them.


## License
All graphics are derived from Factorio assets, Wube Software Ltd. retains all rights and license to these assets.
The rest is under MIT License.

