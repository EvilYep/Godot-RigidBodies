class_name Effect_Area
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	tree_exiting.connect(_on_tree_exiting)
	_force_shell_update()

func _force_shell_update() -> void:
	for shell in get_tree().get_nodes_in_group("shells"):
		_force_individual_shell_update(shell)

func _force_individual_shell_update(shell: Node2D) -> void:
	if shell is Shell:
		# Sometimes shells don't "react" in they're already in the zone when it changes, this fixes that
		shell.apply_central_impulse(Vector2.ZERO)

func _reset_area_constants() -> void:
	gravity_space_override = Area2D.SPACE_OVERRIDE_DISABLED
	angular_damp_space_override = Area2D.SPACE_OVERRIDE_DISABLED
	linear_damp_space_override = Area2D.SPACE_OVERRIDE_DISABLED

#### SIGNALS ####

func _on_body_entered(body: Node2D) -> void:
	_force_individual_shell_update(body)

func _on_body_exited(body: Node2D) -> void:
	_force_individual_shell_update(body)

func _on_tree_exiting() -> void:
	_reset_area_constants()
	_force_shell_update()


