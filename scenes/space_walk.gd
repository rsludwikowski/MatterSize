extends Node3D

@onready var label: Label = $Panel/Label
@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	label.text = "In Hill field: %s" % str(player.in_hill_area)
