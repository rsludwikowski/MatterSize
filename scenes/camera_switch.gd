extends Node

@export var camera_frame: PhantomCamera3D
@export var camera_group: PhantomCamera3D

func _ready():
	pass

func _process(delta):
	toggle_camera()

func toggle_camera():
	if Input.is_action_pressed("camera_frame"):
		camera_frame.priority = 0
		camera_group.priority = 20
	elif Input.is_action_pressed("camera_group"):
		camera_frame.priority = 20
		camera_group.priority = 0
	else:
		pass
