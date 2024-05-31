extends Node3D

@onready var camera_scene = $"../Planets/Planet3/camera_space"
@onready var camera_character = $"../Player".get_node("camera_character")

func _ready():
	# Upewnij się, że tylko jedna kamera jest aktywna na początku
	camera_scene.current = true
	camera_character.current = false

func _input(event):
	if Input.is_action_just_pressed("camera_scene"):
		set_current_camera(camera_scene)
		print("camera_scene")
	elif Input.is_action_just_pressed("camera_player"):
		set_current_camera(camera_character)
		print("camera_player")

func set_current_camera(camera):
	# Ustaw wszystkie kamery na nieaktywne
	camera_scene.current = false
	camera_character.current = false

	# Ustaw wybraną kamerę na aktywną
	camera.current = true
