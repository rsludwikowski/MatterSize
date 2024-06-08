extends Control

@export var camera_frame: PhantomCamera3D
@export var camera_group: PhantomCamera3D

var mouse_pos : Vector3
var ray_origin
var ray_end
var active_camera :PhantomCamera3D
var plane3d :Plane = Plane(Vector3(0,0,0),Vector3(1,0,0),Vector3(0,1,0))

var collision_mask:int = 1 
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
	
	
	
	
	var mv_pos = get_viewport().get_mouse_position()

	#print(mv_pos)
	var camera:Camera3D = $"../Cameras/camera_space"
	
	#print(camera.global_position)
	#ray casting positions
	ray_origin = camera.project_ray_origin(mv_pos)
	#print("Ray origin: ",ray_origin)
	var ray_dir = camera.project_ray_normal(mv_pos)
	
	ray_end = ray_origin + ray_dir * 100000
	
	mouse_pos = plane3d.intersects_ray(ray_origin,ray_end)

	
