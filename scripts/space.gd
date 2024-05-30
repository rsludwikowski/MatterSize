extends Node3D

var planets

func _ready():
	planets = get_tree().get_nodes_in_group("Planets")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
