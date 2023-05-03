extends Effect_Area

@onready var water: Sprite2D = $Water

func _ready() -> void:
	super()

func _process(_delta: float) -> void:
	_zoom_changed()

func _zoom_changed() -> void:
	water.material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)

func _on_water_item_rect_changed() -> void:
	water.material.set_shader_parameter("scale", water.scale)
