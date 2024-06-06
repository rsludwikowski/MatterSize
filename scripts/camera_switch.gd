extends Node

@export var camera_1_frame: PhantomCamera3D
@export var camera_2_group: PhantomCamera3D
@export var camera_3_frame_sun: PhantomCamera3D
@export var host: PhantomCameraHost

var active_camera = "camera_1"
@onready var cameras: Dictionary = {
	"camera_1": camera_1_frame,
	"camera_2": camera_2_group,
	"camera_3": camera_3_frame_sun}
	
func _ready():
	host._follow_target_physics_based = true
	set_group_camera_to_all_planets()

func _process(delta):
	toggle_camera()

func toggle_camera():
	# Sprawdź, która kamera została aktywowana
	for key in cameras:
		if Input.is_action_pressed(key):
			active_camera = key
			break
	# Ustaw priorytety kamer
	for key in cameras:
		if key == active_camera:
			cameras[key].priority = 20
		else:
			cameras[key].priority = 0

	# Dodatkowe działanie dla "camera_2"
	if active_camera == "camera_2":
		set_group_camera_to_all_planets()

	# Debugging: wyświetlenie priorytetów kamer
	for key in cameras:
		print(key, "priority:", cameras[key].priority)

func set_group_camera_to_all_planets():
	var targets_node_3d: Array[Node3D] = []
	var targets = get_tree().get_nodes_in_group("Planets")
	targets += get_tree().get_nodes_in_group("Player")
	#print(targets)
	
	for target in targets:
		var target_node = target as Node3D
		targets_node_3d.append(target_node)
	cameras["camera_2"].set_follow_targets(targets_node_3d)
extends Node

@export var camera_frame: PhantomCamera3D
@export var camera_group: PhantomCamera3D

func _ready():
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
