extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0
@export var damping_factor: float = 4 # Współczynnik tłumienia

var planet: RigidBody3D = null
var in_hill_area: bool = false
var hill_area: Area3D = null

var move_direction
var input_dir = Vector3.ZERO
var local_gravity = Vector3.ZERO
var last_strong_direction = 0.0

func _ready():
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if in_hill_area and hill_area != null:
		planet = hill_area.get_parent()
		local_gravity = (hill_area.global_transform.origin - global_transform.origin).normalized() * hill_area.gravity_strength
		state.apply_central_force(local_gravity * mass)
		
		move_direction = get_input_direction()
		if abs(move_direction) > 0.1:
			last_strong_direction += move_direction * move_speed * state.step
		
		orient_character_to_direction(last_strong_direction,state.step)
		
		if is_jumping(state):
			apply_central_impulse(-local_gravity * jump_initial_impulse)
		elif is_on_floor(state):
			apply_movement(state)
			apply_damping(state)



func get_input_direction():
	var input_direction = 0.0

	if Input.is_action_pressed("move_left"):
		input_direction += 1
	if Input.is_action_pressed("move_right"):
		input_direction -= 1

	return input_direction * rotation_speed

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
	var direction_to_planet_center = (planet.global_transform.origin - global_transform.origin).normalized()
	var up_direction = -direction_to_planet_center

	var right_direction = up_direction.cross(Vector3.FORWARD).normalized()
	var forward_direction = right_direction.cross(up_direction).normalized()

	var movement_direction = right_direction * last_strong_direction * move_speed * state.step

	state.apply_central_force(movement_direction * mass)

func apply_damping(state: PhysicsDirectBodyState3D):
	# Tłumienie prędkości liniowej przy kontakcie z planetą
	state.linear_velocity *= damping_factor
