extends Node2D

var shells := []
#var directions: Dictionary = {
#	"left": Vector2.LEFT,
#	"up": Vector2.UP,
#	"right": Vector2.RIGHT,
#	"down": Vector2.DOWN,
#	"zero": Vector2.ZERO
#}
var direction := Vector2.ZERO

#### BUILT-IN ####

func _ready() -> void:
	shells = get_tree().get_nodes_in_group("shells") as Array[RigidBody2D]

#func _process(delta: float) -> void:
#	print(direction, " ", _find_dir_name(direction))

#### LOGIC ####

#func _find_dir_name(dir: Vector2) -> String:
#	var dir_array = directions.values()
#	var index = dir_array.find(dir)
#	if index == -1 : 
#		return "nope"
#	var dir_keys_array = directions.keys()
#	var dir_key = dir_keys_array[index]
#	return dir_key

#### INPUTS ####

func _unhandled_key_input(event: InputEvent) -> void:
	if event.keycode in [Key.KEY_LEFT, Key.KEY_UP, Key.KEY_RIGHT, Key.KEY_DOWN]:
		# using event.is_action_pressed instead of Input would result in the key considered being released afer a few secs even if still pressed
		# yet it's still an InputEvent so we can put this code here instead of polling every tick with _physics_process or _process 
		direction = Vector2(
			int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
			int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
		).normalized()
		for shell in shells:
			shell.apply_force(direction * 1000)
	
	
	if event.is_action_pressed("ui_accept"):
		for shell in shells:
			match shell.owner.name:
				"Move Right":
					shell.apply_central_impulse(Vector2(-1000, -100))
				"Balloon":
					shell.apply_central_impulse(Vector2(randi_range(-500, 500), 400))
				"Spinning":
					shell.apply_torque_impulse(20000)
				"No Gravity":
					shell.apply_central_impulse(Vector2(randi_range(-500, 500), randi_range(-500, 500)))
				_:
					shell.apply_central_impulse(Vector2(randi_range(-500, 500), -1000))

#### SIGNAL RESPONSES ####
