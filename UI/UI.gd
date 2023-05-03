extends CanvasLayer

signal force_changed(force)
signal impulse_changed(impulse)
signal reset_button_pressed
signal spacebar_button_pressed
signal dir_button_pressed(dir: String)
signal dir_button_released
signal area_selected(area: int)

var key_states: Dictionary = {
	"left": false,
	"up": false,
	"right": false,
	"down": false
}

var tooltips: Dictionary = {
	"None": "",
	"Antigrav Pad": "Area2D adding a -gravity force with a 'combine' Space Override\nProbably the same result as disabling gravity with a 'replace' Space Override",
	"Inverse Grav Pad": "Same as the above but adding -gravity 2 times,\nthus effectively reverting gravity",
	"Black Hole": "Area2D with gravity_point set as true and a high gravity value",
	"Pool": "Area2D with Linear and Angular Damp",
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var force_slider: HSlider = $ForceSlider
@onready var force_label: Label = $ForceSlider/ForceLabel
@onready var impulse_slider: HSlider = $ImpulseSlider
@onready var impulse_label: Label = $ImpulseSlider/ImpulseLabel
@onready var reset_button: TextureButton = $ResetButton
@onready var area_option_button: OptionButton = $AreaOptionButton

#### BUILT-IN ####

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("DirectionButtons"):
		var dir = button.name.trim_suffix("Button").to_lower()
		button.button_down.connect(_on_direction_button_down.bind(dir))
		button.button_up.connect(_on_direction_button_up.bind(dir))

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

func _pop_label(label: Label, time: float) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(label, "scale", Vector2(0.7, 0.7), time / 4)
	tween.parallel().tween_property(label, "rotation", randf_range(- PI / 6,  PI / 6),time / 4)
	tween.parallel().tween_property(label, "theme_override_colors/font_color", Color.from_hsv(randf_range(0.0, 1.0), 1.0, 1.0, 1.0), time / 4)
	
	tween.tween_property(label, "scale", Vector2(0.5, 0.5), time * 3 / 4)
	tween.parallel().tween_property(label, "rotation", 0, time * 3 / 4)
	tween.parallel().tween_property(label, "theme_override_colors/font_color", Color.WHITE, time * 3 / 4)
	
	await tween.finished
	tween.kill()
	if key_states.values().has(true) and label.name == "ForceLabel":
		_pop_label(label, time)

func populate_area_option_button(key: String, index: int) -> void:
	area_option_button.add_item(key)
	area_option_button.get_popup().set_item_tooltip(index, tooltips[key])

#### INPUTS ####

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("impulse"):
		animation_player.play("press_spacebar")
		_pop_label(impulse_label, 0.2)
	
	for key in key_states.keys():
		if event.is_action_released("ui_" + key) and key_states[key]:
			key_states[key] = false
			animate_key_release(key)
		elif event.is_action_pressed("ui_" + key) and not key_states[key]:
			key_states[key] = true
			animate_key_pressed(key)
			_pop_label(force_label, 2.0)

#### SIGNAL RESPONSES ####

func _on_direction_button_down(dir: String) -> void:
	key_states[dir] = true
	animation_player.play("press_" + dir)
	dir_button_pressed.emit(dir)
	_pop_label(force_label, 1.0)

func _on_direction_button_up(dir: String) -> void:
	key_states[dir] = false
	animation_player.play_backwards("press_" + dir)
	dir_button_released.emit()
	
func _on_reset_button_pressed() -> void:
	reset_button_pressed.emit()
	reset_button.release_focus()

func _on_space_bar_button_pressed() -> void:
	animation_player.play("press_spacebar")
	spacebar_button_pressed.emit()
	_pop_label(impulse_label, 0.2)
	
func _on_force_slider_value_changed(force: float) -> void:
	force_label.text = "Force : " + str(force)
	force_changed.emit(force)
	force_slider.release_focus()

func _on_impulse_slider_value_changed(impulse: float) -> void:
	impulse_label.text = "Impulse : " + str(impulse)
	impulse_changed.emit(impulse)
	impulse_slider.release_focus()

func _on_area_option_button_item_selected(index: int) -> void:
	area_selected.emit(index)
