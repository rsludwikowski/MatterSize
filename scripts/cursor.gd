
extends Control



var mouse_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouse_pos = get_viewport().get_mouse_position()

	print(mouse_pos)
	var camera = $"../Cameras/camera_space"
	
	#ray casting positions
	mouse_pos = camera.project_ray_origin(mouse_pos)
	
	
	
