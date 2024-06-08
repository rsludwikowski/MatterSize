extends RigidBody3D

@export var move_speed: float = 5.0
@export var jump_initial_impulse = 40
@export var rotation_speed = 8.0
@export var max_speed: float = 10

var cursor
var planet: Planet = null
var in_hill_area: bool = false
var hill_area: Area3D = null
var on_floor = false
var local_gravity = Vector3.ZERO

func _ready():
	cursor = $"../../Cursor"
	pass

func _process(delta):
	#var a = DebugDraw3D.new_scoped_config().set_thickness(0.15)
	DebugDraw3D.draw_line(self.global_position,self.global_position - local_gravity.normalized()*5,Color(0,0,1))
		

func _physics_process(delta):
	
	var forward_vec:Vector3 = rotate_toward_cursor(delta)
	
	if in_hill_area and hill_area != null:
		planet = hill_area.get_parent()
		jump()
		
		local_gravity = (planet.global_transform.origin - global_transform.origin).normalized() * planet.gravity_strength
		apply_central_force(local_gravity * mass)
		var rotate_toward_v:Vector3
		self.rotate_z( delta * rotation_speed * (-local_gravity.normalized()).signed_angle_to(self.basis.y.normalized(),Vector3(0,0,-1)))
	
		move_player(forward_vec,delta)

	
func get_input_direction() -> float:
	var input_left = Input.get_action_strength("move_left")
	var input_right = Input.get_action_strength("move_right")
	return input_right - input_left


func is_jumping(state: PhysicsDirectBodyState3D):
	return Input.is_action_just_pressed("jump") and is_on_floor(state)

func jump():
	if Input.is_action_pressed("jump"):
		var floor_area: CollisionShape3D = $Area3D/CollisionShape3D
		var relative_position = self.global_position - planet.global_position
		if relative_position.length() - planet.planet_radius < floor_area.shape.radius:
			if on_floor:
				on_floor = false
				apply_central_impulse(-local_gravity * jump_initial_impulse)
			
func is_on_floor(state: PhysicsDirectBodyState3D):
	for i in range(state.get_contact_count()):
		var contact_normal = state.get_contact_local_normal(i)
		if contact_normal.dot(-local_gravity) > 0.5:
			return true
	return false

func is_falling(state: PhysicsDirectBodyState3D):
	return not is_on_floor(state) and state.linear_velocity.dot(local_gravity) > 0

func _on_area_3d_body_entered(body):
	on_floor = true

func rotate_toward_cursor(delta) -> Vector3:
	
	var cursor_point = cursor.mouse_pos
	
	if(cursor_point != null):

		DebugDraw3D.draw_line(self.global_position,cursor_point)
		var floor_plane:Plane = Plane(self.global_position, self.global_position + self.basis.z, self.global_position + self.basis.x)
		
		var normal_vec
		if(floor_plane.distance_to(cursor_point)>0):
			normal_vec = -floor_plane.normal
		else:
			normal_vec = floor_plane.normal
			
		var rotate_vec:Vector3 = self.global_position - (floor_plane.intersects_ray(cursor_point,normal_vec))
		
		var rotation_speed_f = (self.basis.z).signed_angle_to(rotate_vec,-local_gravity.normalized())*rotation_speed*delta
		self.rotate_object_local(Vector3.UP,rotation_speed_f*pow(10,2)*delta)
		
		return rotate_vec
	else:
		return self.global_position


func move_player(forward_vec:Vector3,delta):
	var move_vec = move_speed*get_input_direction()*(-self.basis.z) * sign(self.basis.y.y * forward_vec.x)*-1
	move_vec.z = 0
	
	var relative_vel:Vector3
		
	if in_hill_area and hill_area != null and planet != null:
		var planet_p = get_node_and_resource(planet.get_path())
		relative_vel = self.linear_velocity
		relative_vel = self.linear_velocity - planet.current_velocity
	
	if relative_vel.length() < max_speed:
		self.apply_central_impulse(move_vec*delta*100)
	
