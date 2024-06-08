extends Node

@export var camera_frame: PhantomCamera3D
@export var camera_group: PhantomCamera3D
@export var host: PhantomCameraHost
func _ready():
	host._follow_target_physics_based = false
	set_group_camera_to_all_planets()

func _process(delta):
	toggle_camera()

func toggle_camera():
	if Input.is_action_pressed("camera_frame"):
		camera_frame.priority = 0
		camera_group.priority = 20
	elif Input.is_action_pressed("camera_group"):
		set_group_camera_to_all_planets()
		camera_frame.priority = 20
		camera_group.priority = 0
	else:
		pass

func set_group_camera_to_all_planets():
	var targets_node_3d: Array[Node3D] = []
	var targets = get_tree().get_nodes_in_group("Planets")
	targets += get_tree().get_nodes_in_group("Player")
	print(targets)
	
	for target in targets:
		var target_node = target as Node3D
		targets_node_3d.append(target_node)
	camera_group.set_follow_targets(targets_node_3d)
