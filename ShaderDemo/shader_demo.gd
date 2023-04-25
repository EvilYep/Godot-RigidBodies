extends Node2D

#### ACCESSORS ####

#### BUILT-IN ####

func _ready() -> void:
	for shell in get_tree().get_nodes_in_group("shells"):
		shell.freeze = true
		shell.set_anim_speed(0.1)

#### VIRTUALS ####

#### LOGIC ####

#### INPUTS ####

#### SIGNAL RESPONSES ####
