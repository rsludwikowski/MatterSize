extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0

var planet: RigidBody3D = null
var in_hill_area: bool = false
var hill_area: Area3D = null
var move_direction = Vector3.ZERO
var local_gravity = Vector3.ZERO
var last_strong_direction = Vector3.FORWARD

func _ready():
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if in_hill_area and hill_area != null:
		
		local_gravity = (hill_area.global_transform.origin - global_transform.origin).normalized() * hill_area.gravity_strength
		state.apply_central_force(local_gravity)
		
		move_direction = get_model_oriented_input()
		if move_direction.length() > 0.2:
			last_strong_direction = move_direction.normalized()
		
		orient_character_to_direction(last_strong_direction,state.step)
		
		if is_jumping(state):
			apply_central_impulse(-local_gravity * jump_initial_impulse)
		elif is_on_floor(state):
			apply_movement(state)
	# Debugging: Check if the character is moving
	if state.linear_velocity.length() > 0:
		print("Character is moving. Velocity: ", state.linear_velocity)
	else:
		print("Character is not moving.")



func get_model_oriented_input() -> Vector3:
	var input_left_right := (
		Input.get_action_strength("move_left")
		- Input.get_action_strength("move_right")
	)
	var input_forward := Input.get_action_strength("move_forward")
	var raw_input = Vector2(input_left_right, input_forward)
	var input: Vector3 = Vector3.ZERO
	
	input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	
	input = transform.basis * input
	return input

func orient_character_to_direction(direction: Vector3, delta: float) -> void:
	var left_axis = -local_gravity.cross(direction)
	var rotation_basis = Basis(left_axis,-local_gravity,direction).orthonormalized()
	var current_rotation = transform.basis.get_rotation_quaternion()
	var target_rotation = rotation_basis.get_rotation_quaternion()
	var new_rotation = current_rotation.slerp(target_rotation, delta * rotation_speed)
	transform.basis = Basis(new_rotation)
	
	
func is_jumping(state: PhysicsDirectBodyState3D):
	return Input.is_action_just_pressed("jump") and is_on_floor(state)

func is_on_floor(state: PhysicsDirectBodyState3D):
	for i in range(state.get_contact_count()):
		var contact_normal = state.get_contact_local_normal(i)
		if contact_normal.dot(-local_gravity) > 0.5:
			return true
	return false

func is_falling(state: PhysicsDirectBodyState3D):
	return not is_on_floor(state) and state.linear_velocity.dot(local_gravity) > 0

func apply_movement(state: PhysicsDirectBodyState3D):
	# Apply movement force
	if move_direction.length() > 0.2:
		var force = move_direction.normalized() * move_speed
		state.apply_central_force(force)
		#print("Applying force: ", force)
	else:
		pass#print("No movement input detected")
