extends Node3D
var bodies
# Called when the node enters the scene tree for the first time.
func _ready():
	bodies = get_tree().get_nodes_in_group("Planets")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in bodies:
		body.update_velocity(bodies,delta)
	
	for body in bodies:
		body.update_position(delta)
