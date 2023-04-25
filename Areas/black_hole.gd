extends Effect_Area

var strength: float
var time: float = 0

@onready var event_horizon: Sprite2D = $EventHorizon

func _ready() -> void:
	super()
	position = Vector2(500, 79)

func _process(delta: float) -> void:
	time += delta * 2.5
	strength = sin(time)
	event_horizon.rotation_degrees += 20 * delta
	event_horizon.material.set_shader_parameter("strength", strength)
