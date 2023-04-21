extends Control

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

#### BUILT-IN ####

func _ready() -> void:
	pass

#### LOGIC ####

func animate_key_pressed(dir: String) -> void:
	animation_player.play("press_" + dir)

func animate_key_release(dir: String) -> void:
	animation_player.play_backwards("press_" + dir)

#### INPUTS ####


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		animation_player.play("press_spacebar")
	
	if event.is_action_pressed("ui_left"):
		animate_key_pressed("left")
	if event.is_action_pressed("ui_up"):
		animate_key_pressed("up")
	if event.is_action_pressed("ui_right"):
		animate_key_pressed("right")
	if event.is_action_pressed("ui_down"):
		animate_key_pressed("down")
		
	if event.is_action_released("ui_left"):
		animate_key_release("left")
	if event.is_action_released("ui_up"):
		animate_key_release("up")
	if event.is_action_released("ui_right"):
		animate_key_release("right")
	if event.is_action_released("ui_down"):
		animate_key_release("down")

#### SIGNAL RESPONSES ####
