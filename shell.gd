extends RigidBody2D

@export var max_speed := 600.0
@export var ignore_unfreeze := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $"../Label"
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var dragging: bool = false:
	set(_dragging):
		dragging = _dragging
		freeze = dragging if not ignore_unfreeze else true
		set_random_animation_speed()
		if not _dragging:
			apply_central_impulse(impulse)

var impulse: Vector2:
	set(_impulse):
		impulse = _impulse.clamp(Vector2.ZERO, Vector2(max_speed, max_speed))

#### BUILT-IN ####

func _ready() -> void:
	randomize()
	label.text = get_parent().name
	set_random_animation_speed()

func _process(_delta: float) -> void:
	label.position = position + Vector2(- label.size.x / 2, - 24)

func _physics_process(_delta: float) -> void:
	if dragging: 
		global_transform.origin = get_global_mouse_position()

#### LOGIC ####

func set_random_animation_speed() -> void:
	animation_player.speed_scale = randf_range(-1.5, 1.5)

func drag_or_drop(_impulse: Vector2, mouse_event_was_to_drag: bool = false) -> void:
	impulse = _impulse
	dragging = mouse_event_was_to_drag

#### INPUTS ####

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		drag_or_drop(Input.get_last_mouse_velocity(), event.pressed)

func _unhandled_input(event: InputEvent) -> void:
	# sometimes the shell hasn't quite caught up with the mouse when we release the button, sticking to it
	# we want to drop it when we unpress anyway
	if dragging and event is InputEventMouse:
		if event is InputEventMouseButton and not event.pressed:
			drag_or_drop(Input.get_last_mouse_velocity())

#### SIGNAL RESPONSES ####

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT and dragging:
		drag_or_drop(Input.get_last_mouse_velocity())

func _on_body_entered(body: Node) -> void:
	set_random_animation_speed()
	particles.rotation = get_angle_to(body.position) + PI
	particles.emitting = true
	
	audio_stream_player.pitch_scale = randf_range(0.8, 1.2)
	audio_stream_player.play()
