extends Node2D

var shells: Array[Shell]
var direction := Vector2.ZERO
var force: int = 1000:
	set(f):
		force = f
		_reset_force_based_shells(f)
var impulse: int = 500
#	set(i):
#		impulse = i
#		_reset_impulse_based_shells(i)

@onready var ui: CanvasLayer = $UI
#### BUILT-IN ####

func _ready() -> void:
	for shell in get_tree().get_nodes_in_group("shells"):
		if shell is Shell: shells.append(shell)
	ui.force_changed.connect(func(f): force = f)
	ui.impulse_changed.connect(func(i): impulse = i)
	ui.reset_button_pressed.connect(_reset_shells_position)
	
	print(shells.find("Switch Force Offset"))

#### LOGIC ####

func _reset_shells_position() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	for shell in shells:
		shell.freeze = true
		tween.tween_property(shell, "global_position", shell.starting_position, 0.1)
		tween.parallel().tween_property(shell, "rotation", 0, 0.1)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	for shell in shells:
		shell.freeze = false if not shell.ignore_unfreeze else true

func _reset_force_based_shells(_force) -> void:		# because for is a keyword and f is ugly
	shells.shuffle()
	for shell in shells:
			match shell.owner.name:		# These are the "default" value I set in the editor
				"Force Up":
					shell.constant_force = Vector2(0, -_force)
				"Force Up Left":
					shell.constant_force = Vector2(-_force, -_force)
				"Switch Central Force":
					shell.constant_force = Vector2(_force, 0)
				"Torque":
					shell.constant_torque = -_force
				"Torque No Grav":
					shell.constant_torque = -_force
#func _reset_impulse_based_shells(_i) -> void:
#	for shell in shells:
#			match shell.owner.name:
#				_:
#					pass

#### INPUTS ####

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		_reset_shells_position()
		ui.press_reset_button()
	
	for shell in shells:
		shell.apply_force(direction * force)
	if event.keycode in [Key.KEY_LEFT, Key.KEY_UP, Key.KEY_RIGHT, Key.KEY_DOWN]:
		# using event.is_action_pressed instead of Input would result in the key considered being released afer a few secs even if still pressed
		# yet it's still an InputEvent so we can put this code here instead of polling every tick with _physics_process or _process 
		direction = Vector2(
			int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
			int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		).normalized()
		
	
	if event.is_action_pressed("impulse"):
		for shell in shells:
			match shell.owner.name:
				"Offset Impulse":
					shell.apply_impulse(Vector2(0, 6), Vector2(randi_range(-impulse, impulse), -impulse * 2))
				"Torque Impulse":
					shell.apply_torque_impulse(impulse * 20)
				"Switch Central Force":		# just reverting the constant_force would result in setting it as Vector2.ZERO
					shell.add_constant_central_force(- shell.constant_force * 2)
				_:
					shell.apply_central_impulse(Vector2(randi_range(-impulse, impulse), -impulse))

#### SIGNAL RESPONSES ####
