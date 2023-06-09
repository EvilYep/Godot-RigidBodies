extends Node2D

enum Area {
	NONE,
	ANTIGRAV_PAD,
	INVERSE_GRAV_PAD,
	BLACK_HOLE,
	REPULSIVE_FIELD,
	POOL,
}

var directions: Dictionary = {
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"right": Vector2.RIGHT,
	"down": Vector2.DOWN,
	"zero": Vector2.ZERO
}

var shells: Array[Shell]
var selected_area: Area = Area.NONE:
	set(_area):
		if selected_area != Area.NONE:
			get_tree().get_first_node_in_group("areas").queue_free()
		selected_area = _area
		if _area != Area.NONE:
			_change_selected_area(Area.find_key(selected_area).to_lower())
var direction := Vector2.ZERO
var impulse: int = 500
var force: int = 1000:
	set(f):
		force = f
		_reset_force_based_shells(f)
var time_scale: float = 1.0:
	set(sc):
		time_scale = sc
		Engine.set_time_scale(sc)

var dir_button_pressed := false

@onready var ui: CanvasLayer = $UI
@onready var areas: Node2D = $Areas

#### BUILT-IN ####

func _ready() -> void:
	_connect_ui()
	for shell in get_tree().get_nodes_in_group("shells"):
		if shell is Shell: shells.append(shell)
		if shell.owner.name == "Switch Force Offset":
			# the other shells are directly "initiated" via tweaking properties in the inspector ==>
			shell.add_constant_force(Vector2(-force, 0), Vector2(0, 6))

func _physics_process(_delta: float) -> void:
	if dir_button_pressed:
		_apply_directional_force()

#### LOGIC ####

func _apply_impulse() -> void:
	for shell in shells:
		match shell.owner.name:
			"Offset Impulse":
				shell.apply_impulse(Vector2(0, 6), Vector2(randi_range(-impulse, impulse), -impulse * 2))
			"Torque Impulse":
				shell.apply_torque_impulse(impulse * 20)
			# For the shells which name begins with "Switch", the spacebar action inverts the forces applied to them
			"Switch Central Force":		# just inverting the constant_force would result in setting it as Vector2.ZERO
				shell.add_constant_central_force(- shell.constant_force * 2)
			"Switch Force Offset":
				var f = shell.constant_force
				shell.constant_force = Vector2(0, 0)
				shell.constant_torque = 0
				shell.add_constant_force(- f, Vector2(0, 6))
			"Switch Torque":
				shell.add_constant_torque(- shell.constant_torque * 2)
			_:
				shell.apply_central_impulse(Vector2(randi_range(-impulse, impulse), randi_range(-impulse, impulse)))

func _reset_shells_position() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	for shell in shells:
		shell.freeze = true
		tween.tween_property(shell, "global_position", shell.starting_position, 0.1)
		if shell.owner.name != "Rotation Locked":
			tween.parallel().tween_property(shell, "rotation", 0, 0.1)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	for shell in shells:
		shell.freeze = false if not shell.ignore_unfreeze else true

func _reset_force_based_shells(_force) -> void:
	shells.shuffle()
	for shell in shells:
		shell.constant_force = Vector2(0, 0)
		shell.constant_torque = 0
		match shell.owner.name:		# These are the "default" value I set in the editor
			"Force Up":
				shell.add_constant_central_force(Vector2(0, -_force))
			"Force Up Left":
				shell.add_constant_central_force(Vector2(-_force/2, -_force))
			"Switch Central Force":
				shell.add_constant_central_force(Vector2(_force, 0))
			"Switch Force Offset":
				shell.add_constant_force(Vector2(-force, 0), Vector2(0, 6))
			"Torque", "Torque No Grav", "Switch Torque":
				shell.add_constant_torque(-_force)

func _apply_directional_force() -> void:
	for shell in shells:
		shell.apply_force(direction * force)

func _apply_direction(dir: String) -> void: 
	dir_button_pressed = true
	direction = directions[dir]

func _reset_direction() -> void:
	dir_button_pressed = false
	direction = Vector2.ZERO

func _change_selected_area(new_selected_area: String) -> void:
	var _area: Area2D = load("res://Areas/" + new_selected_area + ".tscn").instantiate()
	areas.add_child(_area)

func _connect_ui() -> void:
	ui.force_changed.connect(func(f): force = f)
	ui.impulse_changed.connect(func(i): impulse = i)
	ui.time_scale_changed.connect(func(sc): time_scale = sc)
	ui.reset_button_pressed.connect(_reset_shells_position)
	ui.spacebar_button_pressed.connect(_apply_impulse)
	ui.dir_button_pressed.connect(_apply_direction)
	ui.dir_button_released.connect(_reset_direction)
	for area in Area:
		ui.populate_area_option_button(area.to_lower().replace("_", " ").capitalize(), Area.get(area))
	ui.area_selected.connect(_on_selected_area_changed)

#### INPUTS ####

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		_reset_shells_position()
		ui.press_reset_button()
	
	if event.keycode in [Key.KEY_LEFT, Key.KEY_UP, Key.KEY_RIGHT, Key.KEY_DOWN]:
		# using event.is_action_pressed instead of Input would result in the key considered being released afer a few secs even if still pressed
		# yet it's still an InputEvent so we can put this code here instead of polling every tick with _physics_process or _process 
		direction = Vector2(
			int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
			int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
		).normalized()
		
		_apply_directional_force()
	
	if event.is_action_pressed("impulse"):
		_apply_impulse()

#### SIGNAL RESPONSES ####

func _on_selected_area_changed(_area: Area) -> void:
	selected_area = Area.NONE
	_reset_force_based_shells(force)
	selected_area = _area
