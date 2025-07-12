# bus_wars
**It is a simple 2D isometric game. For now, it uses the Godot game engine.
The core gameplay is a blend of a bus driving simulator and a visual novel with a few simple role-playing elements.
The core idea is that the player drives a bus in the city or other regions, which act as separate levels. The levels themselves are large sandboxes with roads and traffic control systems like traffic lights, etc. The levels have many bus stops which are connected through multiple bus routes. The roads will have traffic systems with simple cars, large vehicles, trucks, and other buses. The player must compete on each level with other bus companies to drive passengers to their desired destination bus stops.

In addition to competing companies, there will be the player’s own company as his employer, and besides the player, there will be other bus drivers from the same company who will have their own routes. The routes built by the player will influence the routes of other drivers in the company, because routes within the same company cannot intersect. The same rule applies to other companies as well, so the routes of drivers from the same company cannot include the same bus stops in their routes. However, the routes of different companies can — and mostly must — intersect.

Bus stops will have multiple defining parameters such as how many passengers they can hold, the danger level, and faith. Passengers will have their own properties: name, destination, danger level, and faith. Passengers can have destinations that require multiple routes to reach. The danger level of passengers inside the bus will influence the probability of a riot on the bus. The faith attribute of a passenger will influence the probability of choosing the player’s bus and decrease the probability of a riot inside the bus.
The additional mechanic for the future is the donation to the city, which will increase faith level of some districts and decrease the danger level. Donation categories can be: education, law, force, army, theology etc.

The core bus gameplay mechanics are simple vehicle driving. The physics are basic: when the acceleration button is pressed, the bus will start to slowly accelerate depending on the bus’s weight and engine power.

At the beginning, the player has to build their own bus by selecting from these parameters:

    Material: influences body weight, depends on power source

    Passenger section count: influences total passenger capacity and body weight

    Tire material: influences acceleration, braking power, and steering stability; also affects steering at high speed

    Engine power: influences acceleration and maximum speed; depends on power source

    Power source: determines available engine power levels. Available options are: steam, gas, hydrogen, battery, alien, psychic, chaos**
