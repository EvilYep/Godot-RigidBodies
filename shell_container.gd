@icon("res://Assets/shell_icon.png")
class_name ShellContainer
extends Node2D

@onready var label: Label = $Label
@onready var shell: RigidBody2D = $Shell

func _ready() -> void:
	label.text = name

func _process(_delta: float) -> void:
	label.position = shell.position + Vector2(- label.size.x / 2, - 24)
