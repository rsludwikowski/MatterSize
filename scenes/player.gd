extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0
@export var max_speed: float = 10

var planet: RigidBody3D = null
var in_hill_area: bool = false
var hill_area: Area3D = null
var on_floor = false

var move_direction: int
var input_dir = Vector3.ZERO
var local_gravity = Vector3.ZERO
var local_up_direction = Vector3.ZERO
var last_strong_direction = 0.0

func _ready():
	pass

func _process(delta):
	var a = DebugDraw3D.new_scoped_config().set_thickness(0.15)
	DebugDraw3D.draw_line(self.global_position,self.global_position + local_up_direction * 5,Color(0,0,1))
		

func _physics_process(delta):
	if is_on_the_planet():
		planet = hill_area.get_parent()
		jump()

		local_gravity = (hill_area.global_transform.origin - global_transform.origin).normalized() * hill_area.gravity_strength
		local_up_direction = -local_gravity.normalized()
		apply_central_force(local_gravity * mass)
		var rotate_toward_v:Vector3
		
		#rotation in local up direction
		self.rotate_z( delta  * local_up_direction.signed_angle_to(self.basis.y.normalized(), Vector3(0,0,-1)))
		
		move_direction =  get_input_direction()
		rotate_toward_v = orient_character_to_vector(move_direction)

		
		var rotation_speed_f = (-self.basis.z).signed_angle_to(rotate_toward_v, local_up_direction) * rotation_speed*delta
		self.rotate_object_local(Vector3.UP, rotation_speed_f * 100 * delta)
		
		
		var move_vec = move_speed*rotate_toward_v.normalized()
		move_vec.z = 0
		var relative_vel:Vector3
		
		var planet_p = get_node_and_resource(planet.get_path())
		relative_vel = self.linear_velocity
		relative_vel = self.linear_velocity - planet.current_velocity
	
		
		if relative_vel.length() < max_speed:
			self.apply_central_impulse(move_vec)
	
func _integrate_forces(state: PhysicsDirectBodyState3D):
	pass
	
	
func get_input_direction() -> float:
	var direction: int = 0
	if Input.is_action_pressed("move_right"):
			direction = -1
	elif Input.is_action_pressed("move_left"):
			direction = 1
	return direction


func orient_character_to_vector(input: int):
	var front_dir_vec :Vector3 = Vector3(0,0,-1)
	
	if input == 1:
		front_dir_vec = -front_dir_vec.cross(-local_gravity.normalized()).normalized()
	if input == -1:
		front_dir_vec = front_dir_vec.cross(-local_gravity.normalized()).normalized()
		
	DebugDraw3D.draw_line(self.global_position,self.global_position + (-self.basis.z).normalized()*5,Color(1,1,0))
	DebugDraw3D.draw_line(self.global_position,self.global_position + front_dir_vec.normalized()*5,Color(0,1,1))
	
	return front_dir_vec

func is_on_the_planet() -> bool:
	if in_hill_area and hill_area != null:
		return true
	else:
		return false


func jump():
	if Input.is_action_pressed("jump"):
		var floor_area: CollisionShape3D = $Area3D/CollisionShape3D
		var relative_position = self.global_position - planet.global_position
		if relative_position.length() - planet.planet_radius < floor_area.shape.radius:
			if on_floor:
				on_floor = false
				apply_central_impulse(-local_gravity * jump_initial_impulse)
			

func _on_area_3d_body_entered(body):
	on_floor = true
