extends TextureRect

@export var hue_speed: float = 0.2
var hue: float = 0.0
var time: float = 0.0

func _process(delta: float) -> void:
	time += hue_speed * delta
	hue = (sin(time) + 1.0) * 0.5 # Map sine output from [-1, 1] to [0, 1]

	var new_color = Color.from_hsv(hue, 0.15, 0.9, 1.0)
	modulate = new_color
