extends Node2D

@export var scroll_speed := 2.5

@onready var sky: TextureRect = $Sky

func _process(delta: float) -> void:
	sky.position.x -= delta * scroll_speed
	if sky.position.x <= - sky.size.x * sky.scale.x / 2:
		sky.position.x = 0
