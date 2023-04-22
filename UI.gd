extends CanvasLayer

signal force_changed(force)
signal impulse_changed(impulse)
signal reset_button_pressed

var key_states: Dictionary = {
	"left": false,
	"up": false,
	"right": false,
	"down": false
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var force_slider: HSlider = $ForceSlider
@onready var force_label: Label = $ForceSlider/ForceLabel
@onready var impulse_slider: HSlider = $ImpulseSlider
@onready var impulse_label: Label = $ImpulseSlider/ImpulseLabel
@onready var reset_button: TextureButton = $ResetButton

#### BUILT-IN ####

#### LOGIC ####

func animate_key_pressed(dir: String) -> void:
	animation_player.queue("press_" + dir)

func animate_key_release(dir: String) -> void:
	if animation_player.is_playing():
		await animation_player.animation_finished 
	animation_player.play_backwards("press_" + dir)

# Simulate the button pressed when the user presses the Enter key. This is used ONLY for visual feedback
func press_reset_button() -> void:
	var old_texture = reset_button.texture_normal
	reset_button.texture_normal = reset_button.texture_pressed
	await get_tree().create_timer(0.2).timeout
	reset_button.texture_normal = old_texture

func _pop_label(label: Label) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(label, "scale", Vector2(0.7, 0.7), 0.05)
	tween.tween_property(label, "scale", Vector2(0.5, 0.5), 0.15)

#### INPUTS ####


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("impulse"):
		animation_player.play("press_spacebar")
		_pop_label(impulse_label)
	
	for key in key_states.keys():
		if event.is_action_released("ui_" + key) and key_states[key]:
			key_states[key] = false
			animate_key_release(key)
		elif event.is_action_pressed("ui_" + key) and not key_states[key]:
			key_states[key] = true
			animate_key_pressed(key)

#### SIGNAL RESPONSES ####

func _on_force_slider_value_changed(force: float) -> void:
	force_label.text = "Force : " + str(force)
	force_changed.emit(force)
	force_slider.release_focus()


func _on_impulse_slider_value_changed(impulse: float) -> void:
	impulse_label.text = "Impulse : " + str(impulse)
	impulse_changed.emit(impulse)
	impulse_slider.release_focus()

func _on_reset_button_pressed() -> void:
	reset_button_pressed.emit()
	reset_button.release_focus()
