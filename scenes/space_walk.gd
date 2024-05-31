extends Node3D

@onready var label: Label = $Panel/Label
@onready var player = get_tree().get_nodes_in_group("Player")

func _process(_delta):
	label.text = "gravity_force: %s" % str(player)
