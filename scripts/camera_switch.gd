extends Node

@export var zoom_increment: int = 10
@export var camera_1_player: PhantomCamera3D
@export var camera_2_planets: PhantomCamera3D
@export var camera_3_sun: PhantomCamera3D
@export var host: PhantomCameraHost

var active_camera = "camera_3"
var zoom_min: int = 0
var zoom_max: int = 1000

@onready var cameras: Dictionary = {
	"camera_1": camera_1_player,
	"camera_2": camera_2_planets,
	"camera_3": camera_3_sun
	}
	
func _ready():
	host._follow_target_physics_based = true
	set_group_camera_to_all_planets()

func _process(_delta):
	set_camera_zoom(active_camera)
	toggle_camera()

func toggle_camera():
	# Sprawdź, która kamera została aktywowana
	for key in cameras:
		if Input.is_action_pressed(key):
			active_camera = key
			break
	# Ustaw priorytety kamer
	for cam in cameras:
		if cam == active_camera:
			cameras[cam].priority = 20
		else:
			cameras[cam].priority = 0

	# Dodatkowe działanie dla "camera_2"
	if active_camera == "camera_2":
		set_group_camera_to_all_planets()
	
	# Debugging: wyświetlenie priorytetów kamer
	#for cam in cameras:
		#print(cam, "priority:", cameras[cam].priority)
		
func set_camera_zoom(camera):
	var zooming = 0
	var is_zooming = false
	if Input.is_action_just_pressed("zoom_in"):
		zooming = zoom_increment
		is_zooming = true
	elif Input.is_action_just_pressed("zoom_out"):
		zooming = -zoom_increment
		is_zooming = true
		
	if true: 
		if cameras[camera].follow_mode == PhantomCamera3D.FollowMode.GROUP:
			var distance = cameras[camera].auto_follow_distance_max
			distance += zooming
			if is_in_range(distance):
				cameras[camera].auto_follow_distance_max = distance
				print(cameras[camera].auto_follow_distance_max)
		elif cameras[camera].follow_mode == PhantomCamera3D.FollowMode.FRAMED:
			var distance = cameras[camera].follow_distance
			distance += zooming
			if is_in_range(distance):
				cameras[camera].follow_distance = distance
				print(cameras[camera].follow_distance)
		elif cameras[camera].follow_mode == PhantomCamera3D.FollowMode.THIRD_PERSON:
			var distance = cameras[camera].spring_length
			distance += zooming
			if is_in_range(distance):
				cameras[camera].spring_length = distance
				print(cameras[camera].follow_distance)
		else:
			var distance = cameras[camera].follow_offset.z
			distance += zooming
			if is_in_range(distance):
				cameras[camera].follow_offset.z = distance
				print(cameras[camera].follow_offset.z)
	
func is_in_range(distance):
	if distance > zoom_min and distance < zoom_max:
		return true
	else:
		return false
		
func set_group_camera_to_all_planets():
	var targets_node_3d: Array[Node3D] = []
	var targets = get_tree().get_nodes_in_group("Planets")
	targets += get_tree().get_nodes_in_group("Player")
	#print(targets)
	
	for target in targets:
		var target_node = target as Node3D
		targets_node_3d.append(target_node)
	cameras["camera_2"].set_follow_targets(targets_node_3d)
