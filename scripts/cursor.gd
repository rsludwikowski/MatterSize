
extends Control

@export var camera_frame: PhantomCamera3D
@export var camera_group: PhantomCamera3D

var mouse_pos
var active_camera :PhantomCamera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(camera_frame.priority>camera_group.priority):
		#print("CAMERA_FRAME")
		active_camera = camera_frame
	else:
		#print("CAMERA_GROUP")
		active_camera = camera_group
	
	
	
	
	mouse_pos = get_viewport().get_mouse_position()

	print(mouse_pos)
	var camera = $"../Cameras/camera_space"
	
	print(camera.global_position)
	#ray casting positions
	mouse_pos = camera.project_ray_origin(mouse_pos)
	print(mouse_pos)
	
	
	
