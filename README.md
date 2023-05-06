# Godot 4 RigidBody2D and Area2D playground

## Demo Video (Click to view on Youtube)
[![Watch the video](https://img.youtube.com/vi/1XOT3yVzKwc/maxresdefault.jpg)](https://youtu.be/1XOT3yVzKwc)

## Test it directly

Download an exported version of this project :  
https://github.com/EvilYep/Godot-RigidBodies/blob/main/Export/Rigid%20Bodies.exe


# Get Started
1. Clone this repository locally
2. Open the project in [Godot 4](https://godotengine.org/)
3. Play around and tweak stuff
# How it works
This is a sandbox I developed to figure out and learn about physics in Godot.  
Shells are Rigidbodies with disctinct properties and you can affect them to see the results.  

- You can drag'n'drop (or even "drag'n'throw" shells with the click of your mouse)
- You can set the values of `force` (default: `1000`) and `impulse` (default: `500`) with the sliders and adjust how fast time pasts
- Pressing the Spacebar or clicking its representation in the UI will apply a impulse in a random direction to every shell according to the method `shell.apply_central_impulse(Vector2(randi_range(-impulse, impulse), randi_range(-impulse, impulse)))`  
IMPORTANT : some specific shells react to the spacebar in other ways IN ADDITION of this impulse (details below)
- Pressing or clicking the Arrow Keys will apply a constant force to every shell in the direction pressed (continuous press is thus advised for better results) according to the method `shell.apply_force(direction * force)`
- Clicking the reset button or pressing the Enter key will reset every shell to its original position
- The dropdown menu allows you to add certain "Effect Areas" to the scene, impacting the behaviour of Shells inside their area  
# RigidBodies
Each Shell is an instance of a `Shell` scene that includes a RigidBody2D with distinct properties.  
As stated before, in addition to reacting to a random impulse when the spacebar is pressed, some shells also have other properties which will be detailed here:  
## Existing Shells
NOTE : For the shells which name begins with "Switch", the spacebar action inverts the forces applied to them  
| **Name** | Properties
| --- | --- 
| **Normal** | Godot 4 default RigidBody2D and base for all the others. Only modifications are: <br/> It has Freeze Mode set to `Kinematic`, Contact Monitor set to `true`, max contacts `5`, Continuous CD set to `Cast Shape` (change this if you encounter performance issues), and is `pickable`.
| **Not Pickable** | 'Pickable' set to `false` from the editor
| **Freeze Static** | Freeze set to `true`, Freeze mode set to `Static` from the editor
| **Freeze Kinematic** | Freeze set to `true`, Freeze mode set to `Kinematic` from the editor
| **Very Heavy** | Mass set to `50` kg from the editor
| **Very Light** | Mass set to `0.25` kg from the editor
| **Force Up** | Constant Forces/Force set to `(0, -force)` from the editor <br/> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Force Up Left** | Constant Forces/Force set to `(-force/2, -force)` from the editor <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Force Antigrav** | Constant Forces/Force set to `(0, -980)` from the editor
| **Switch Central Force** | Constant Forces/Force set to `(force, 0)` from the editor <br /> When the SpaceBar is pressed, apply a force according to `shell.add_constant_central_force(- shell.constant_force * 2)` <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Switch Force Offset** | Constant Force applied at `_ready()` with the method `shell.add_constant_force(Vector2(-force, 0), Vector2(0, 6))` <br /> When the SpaceBar is pressed, resets the shell `constant_force` and `constant_torque` then apply a force according to `shell.add_constant_force(- previous_shell_constant_force, Vector2(0, 6))` <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Switch Torque** | Constant Forces/Torque set to `force` from the editor <br /> When the SpaceBar is pressed, apply a torque according to `shell.add_constant_torque(- shell.constant_torque * 2)` <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **No Gravity** | Gravity Scale set to `0` from the editor
| **Torque** | Constant Forces/Torque set to `-force` from the editor <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Torque No Grav** | Constant Forces/Torque set to `-force` and Gravity Scale set to `0` from the editor <br /> Reacts to changes to `force` made with the slider (resets and apply new `force`)
| **Offset Impulse** | Like "Normal", when SpaceBar is pressed, apply an impulse according to `shell.apply_impulse(Vector2(0, 6), Vector2(randi_range(-impulse, impulse), -impulse * 2))`
| **Torque Impulse** | Like "Normal", when SpaceBar is pressed, apply an impulse according to `shell.apply_torque_impulse(impulse * 20)`
| **Frictionless** | Physics Material/Friction set to `0` from the editor
| **Rough** | Physics Material/Rough set to `true` from the editor
| **Frictionless Rough** | Physics Material/Friction set to `0` and Physics Material/Rough set to `true` from the editor
| **Bouncy** | Physics Material/Bounce set to `1` from the editor
| **Absorb Bounce** | Physics Material/Bounce set to `1` and Absorbent set to `true` from the editor
| **Bouncy No Grav** | Like "Bouncy" but Gravity Scale set to `0` from the editor
| **Bouncy Frictionless** | Physics Material/Friction set to `0` and Physics Material/Bounce set to `1` from the editor
| **Bouncy No Damping** | Like "Bouncy" but Linear/Damp Mode set to `replace` and Damp set to `0`
| **Rotation Locked** | Rotated 90° and Lock Rotation set to `true` from the editor
## Add a Shell
- Instantiate a `Shell` scene within the `Main` scene
- Name it and place it
- To edit its properties, right-click on it in the scene tree, and toggle `Editable Children`
- Dropdown the "ShellContainer" and edit the actual "Shell" inside it (the actual RigidBody2D)
- Alternatively, you can tweak its properties from code, there are many examples in the `main.gd` script
# Area2Ds
Every "Area" you can instantiate with the dropdown menu basically consists of an `Area2D` including a `CollisionShape` extending the `Effect_Area` script, which automatically handles instantiating, connecting signals and interactions with Shells  

They all have Monitoring set to `true`, Area2D/Priority set to `1`, are set on Collision Layer/Mask respectively `3` ("area") and `2` ("shell"), and belong in a group called `areas`

You'll see some of them have AnimatedSprites, Particles or even shaders, but all of this is absolutely unnecessary. It was only used to create graphics and a visual feedback
## Existing Areas
| **Name** | Properties
| --- | --- 
| **Antigrav Pad** | Gravity/SpaceOverride set to `combine`, Gravity/Direction set to `0, -1` from the editor
| **Inverse Grav Pad** | Gravity/SpaceOverride set to `combine`, Gravity/Direction set to `0, -2` from the editor
| **Black Hole** | Gravity and LinearDamp/SpaceOverride set to `combine`, Gravity/Point set to `true`, Point Center set to `0, 0`, Gravity set to `3920` (4 x normal Gravity), Linear Damp set to `10` from the editor
| **Repulsive Field** | Gravity/SpaceOverride set to `combine`, Gravity/Point set to `true`, Point Center set to `0, 0`, Gravity set to `-3920` from the editor
| **Pool** | LinearDamp and AngularDamp/SpaceOverride set to `combine`, Linear Damp set to `25`, Angular Damp set to `50` from the editor 
## Add your Area
- Create a new scene with an `Area2D` as the root node. **IMPORTANT:** Name the `Area2D` node in `PascalCase` and save it in `snake_case` in `res://Areas/`
- Add a `CollisionShape2D` as a child, rename it `CollisionShape` and choose the shape of your choice
- Attach a script to it extending the `Effect_Area` script.
- Implement an override of the `_ready()` function to position your Area on the screen. Don't forget to call the parent script with `super()`<br />__Example :__<br />`extends Effect_Area`<br /><br />`func _ready():`<br />&ensp;&ensp;&ensp;&ensp;`super()`<br />&ensp;&ensp;&ensp;&ensp;`position = Vector2(110, 346.5)`
- Make sur to add it to the group `areas` and to set its Collision Mask/Layer to respectively `3` and `2`
- Add a value for your area in the `enum Area` in `main.gd` line 3. Use capital letters and underscores, like the other areas are already set up.
- __Optional :__ Add a tooltip that will appear when you hover your mouse above the option for your area in the dropdown menu <br /> Go to `UI/ui.gd`, line 19, you'll soon see how you can add your own
- __Optional :__ Add a visual representation of your area : Sprites, Particles, Shaders...
## Credits

Background Art :  
https://opengameart.org/content/superpowers-assets-background-elements  
HUD :  
https://greatdocbrown.itch.io/gamepad-ui  
https://opengameart.org/content/unfinished-user-interfaces  
https://hugues-laborde.itch.io/ui-pixel-art-01  
FX :  
https://kronbits.itch.io/particle-pack  
https://ppeldo.itch.io/2d-pixel-art-game-spellmagic-fx  