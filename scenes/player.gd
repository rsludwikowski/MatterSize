extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0
@export var max_speed: float = 10

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
		#print(planet)
		#apply_gravity(state)
		
		
		
		local_gravity = (hill_area.global_transform.origin - global_transform.origin).normalized() * hill_area.gravity_strength
		state.apply_central_force(local_gravity * mass)
		
		
		
		
		
		
		
		#move_direction = get_input_direction()
		#if abs(move_direction) > 0.1:
			#last_strong_direction += move_direction * move_speed * state.step
		#
		#orient_character_to_direction(last_strong_direction,state.step)
		#
		##move_character(state)
		#if is_jumping(state):
			#apply_central_impulse(-local_gravity * jump_initial_impulse)
		#elif is_on_floor(state):
			#apply_movement(state)


func _process(delta):
	var a = DebugDraw3D.new_scoped_config().set_thickness(0.15)
	DebugDraw3D.draw_line(self.global_position,self.global_position - local_gravity.normalized()*5,Color(0,0,1))
		

func _physics_process(delta):
	var rotate_toward_v:Vector3
	self.rotate_z((-local_gravity.normalized()).signed_angle_to(self.basis.y.normalized(),Vector3(0,0,-1)))
	
	#print((-local_gravity.normalized()).signed_angle_to(self.basis.y.normalized(),Vector3(0,0,-1)))
	#self.rotate(self.global_transform.basis.y,self.global_transform.basis.y.angle_to(-local_gravity.normalized())) 
	
	if Input.is_action_pressed("move_right"):
			rotate_toward_v =orient_character_new(-1)
	elif Input.is_action_pressed("move_left"):
			rotate_toward_v = orient_character_new(1)
	else:
			rotate_toward_v =orient_character_new(0)
	
	var rotation_speed_f = (-self.basis.z).signed_angle_to(rotate_toward_v,-local_gravity.normalized())*rotation_speed*delta
	#print(rotation_speed_f)
	self.rotate_object_local(Vector3.UP,rotation_speed_f*pow(10,2)*delta)
	
	
	var move_vec = move_speed*rotate_toward_v.normalized()
	move_vec.z = 0
	#self.move_and_collide(move_vec*delta)
	var relative_vel:Vector3
		
	if in_hill_area and hill_area != null and planet != null:
		var planet_p = get_node_and_resource(planet.get_path())
		#print(planet_p)
		relative_vel = self.linear_velocity
		relative_vel = self.linear_velocity - planet.getVelocity()
		print(relative_vel.length())
	
		
	if relative_vel.length() < max_speed:
		self.apply_central_impulse(move_vec)
	
	
func get_input_direction() -> float:
	var input_left = Input.get_action_strength("move_left")
	var input_right = Input.get_action_strength("move_right")
	return input_right - input_left


func orient_character_new(input: int):
	var front_dir_vec :Vector3 = Vector3(0,0,-1)
	
	
	if input == 1:
		
		front_dir_vec = -front_dir_vec.cross(-local_gravity.normalized()).normalized()
	if input == -1:
		
		front_dir_vec = front_dir_vec.cross(-local_gravity.normalized()).normalized()
		
	
	
	
	
	DebugDraw3D.draw_line(self.global_position,self.global_position + (-self.basis.z).normalized()*5,Color(1,1,0))
	
	DebugDraw3D.draw_line(self.global_position,self.global_position + front_dir_vec.normalized()*5,Color(0,1,1))
	
	
	return front_dir_vec

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
