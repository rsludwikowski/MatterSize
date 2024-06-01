extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0

var planet: RigidBody3D = null
var in_hill_area: bool = false
var hill_area: Area3D = null

var move_direction = 0
var input_dir = Vector3.ZERO
var local_gravity = Vector3.ZERO
var last_strong_direction = 0

func _ready():
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if in_hill_area and hill_area != null:
		planet = hill_area.get_parent()
		#apply_gravity(state)
		local_gravity = (hill_area.global_transform.origin - global_transform.origin).normalized() * hill_area.gravity_strength
		state.apply_central_force(local_gravity * mass)
		
		move_direction = get_input_direction()
		if abs(move_direction) > 0.1:
			last_strong_direction += move_direction * move_speed * state.step
		
		orient_character_to_direction(last_strong_direction,state.step)
		
		#move_character(state)
		if is_jumping(state):
			apply_central_impulse(-local_gravity * jump_initial_impulse)
		elif is_on_floor(state):
			apply_movement(state)



func get_input_direction() -> float:
	var input_left = Input.get_action_strength("move_left")
	var input_right = Input.get_action_strength("move_right")
	return input_right - input_left

func orient_character_to_direction(angle: float, delta: float) -> void:
	var direction_to_planet_center = (planet.global_transform.origin - global_transform.origin).normalized()
	var up_direction = -direction_to_planet_center

	# Obrót w płaszczyźnie XY wokół osi Z
	var forward_direction = Vector3(cos(angle), sin(angle), 0).normalized()

	# Obliczenie prawej ręki jako iloczynu wektorowego kierunku naprzód i w górę
	var right_direction = forward_direction.cross(up_direction).normalized()
	forward_direction = up_direction.cross(right_direction).normalized()

	var rotation_basis = Basis(
		forward_direction,
		up_direction,
		right_direction
	).orthonormalized()

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
	if abs(move_direction) > 0.1:
		var tangent_force = Vector3(-sin(last_strong_direction), cos(last_strong_direction), 0) * move_speed
		state.apply_central_force(tangent_force)
		print("Applying tangential force: ", tangent_force)
	else:
		print("No movement input detected")
