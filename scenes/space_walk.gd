extends Node3D

@onready var label1: Label = $Panel/Label1
@onready var label2: Label = $Panel/Label2
@onready var player: Node = get_tree().get_nodes_in_group("Player")[0]

func _process(_delta):
	label1.text = "Pos: %s" % str(player.position)
	label2.text = "Basis\nx: %s \ny %s\nz: %s" % [str(player.basis.x),
	str(player.basis.y),
	str(player.basis.z)]
