extends RigidBody3D

@export var move_speed: float = 5.0
var planet: RigidBody3D = null
var in_hill_area: bool = false
var hill_area: Area3D = null
var gravity_force
var global_direction

var velocity: Vector3 = Vector3.ZERO

func _ready():
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var input_dir: Vector3 = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	if in_hill_area and hill_area != null:
		gravity_force = hill_area.calculate_gravity_force_at_position(global_transform.origin)
		apply_central_force(gravity_force)

	global_direction = (global_transform.basis * input_dir).normalized()
	velocity = global_direction * move_speed
	state.linear_velocity = velocity
	
func set_planet(planet):
	self.planet = planet
