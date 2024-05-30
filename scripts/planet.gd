extends RigidBody3D

@export var initial_velocity: Vector3
@export var planet_radius: float = 1.0
@export var color: Color

var current_velocity: Vector3

var direction: Vector3
const RADIUS_SCALE = 1.0
const GRAVITATIONAL_CONSTANT = 6.67430e-11

var overlapping_areas = []

func _ready():
	var hill_area = create_hill_area(pow(planet_radius,2) / sqrt(planet_radius))
	hill_area.connect("area_entered", Callable(self, "_on_area_entered"))
	hill_area.connect("area_exited", Callable(self, "_on_area_exited"))

	set_planet_radius(planet_radius)
	create_material(color)

	#var planet_mass = ($Area3D.gravity * planet_radius * planet_radius) / GRAVITATIONAL_CONSTANT
	#mass = planet_mass
	#print(planet_mass)

	current_velocity = initial_velocity

func _process(_delta):
	pass



func _integrate_forces(state):
	update_velocity(get_tree().get_nodes_in_group("Planets"), state.step)
	update_position(state.step)

func set_planet_radius(r):
	planet_radius = r
	var coll_shape = $CollisionShape3D
	var mesh_instance = $MeshInstance3D

	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = r
	sphere_mesh.height = 2 * r

	mesh_instance.mesh = sphere_mesh

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = r
	coll_shape.shape = sphere_shape

func get_planet_radius():
	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		return shape.radius
	else:
		print("Error in get_planet_radius: Collision shape is not a SphereShape3D")
		return -1

func get_planet_hill_radius():
	var shape = $Area3D/CollisionShape3D.shape
	if shape is SphereShape3D:
		return shape.radius
	else:
		print("Error in get_planet_hill_radius: Collision shape is not a SphereShape3D")
		return -1

func create_hill_area(radius):
	var hill_area = Area3D.new()
	hill_area.name = "HillArea"
	add_child(hill_area)

	var hill_collision_shape = CollisionShape3D.new()
	hill_area.add_child(hill_collision_shape)

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius
	hill_collision_shape.shape = sphere_shape

	var hill_mesh_instance = MeshInstance3D.new()
	hill_mesh_instance.name = "HillMeshInstance"
	hill_area.add_child(hill_mesh_instance)

	var hill_sphere_mesh = SphereMesh.new()
	hill_sphere_mesh.radius = radius
	hill_sphere_mesh.height = 2 * radius
	hill_mesh_instance.mesh = hill_sphere_mesh

	var hill_material = StandardMaterial3D.new()
	hill_material.albedo_color = Color(1.0, 0.0, 0.0, 0.5) 
	hill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hill_mesh_instance.material_override = hill_material

	hill_area.gravity = 0
	hill_area.gravity_point = true
	
	return hill_area

func update_velocity(planets, delta):
	for planet in planets:
		if planet != self:
			direction = planet.global_transform.origin - self.global_transform.origin
			var distance = direction.length()
			if distance == 0:
				continue
			var force_magnitude = (GRAVITATIONAL_CONSTANT * mass * planet.mass) / (distance * distance)
			var force = direction.normalized() * force_magnitude
			var acceleration = force / mass
			current_velocity += acceleration * delta
	
	for area in overlapping_areas:
		if area is Area3D and area.gravity != 0:
			var gravity_dir = (area.get_global_transform().origin - global_transform.origin).normalized()
			current_velocity += gravity_dir * area.gravity * delta

func update_position(delta):
	self.global_transform.origin += current_velocity * delta
	
func UpdateVelocity(delta_T):
	var planets = get_tree().get_nodes_in_group("Planets")
	for planet in planets:
		#if planet != self:
		var sqrDst = (planet.global_position - self.global_position).length_squared()
		var forceDir = (planet.global_position - self.global_position).normalized()
		var force = forceDir * $"..".G_CONSTANT
		var acceleration = force / self.mass
		self.linear_velocity += acceleration * delta_T
			#print(self.linear_velocity)

func UpdatePosition(delta_T):
	self.position += self.linear_velocity * delta_T

func create_material(color):
	var mesh_instance = $MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.1
	material.roughness = 0.8
	mesh_instance.material_override = material

func explosion_on_collision(body):
	if body is RigidBody3D:
		#var direction = (body.global_transform.origin - global_transform.origin).normalized()
		var relative_velocity = (current_velocity - body.linear_velocity).length()

		# Ustawienie minimalnej i maksymalnej prędkości początkowej cząsteczek
		$Explosion.initial_velocity_min = current_velocity.length() + relative_velocity / 2
		$Explosion.initial_velocity_max = relative_velocity / 2
		# Ustawienie kierunku emisji cząsteczek
		$Explosion.direction = direction
	else:
		var relative_velocity = current_velocity.length()
		$Explosion.initial_velocity_min = current_velocity.length() + relative_velocity / 2
		$Explosion.initial_velocity_max = relative_velocity / 2
	# Rozpoczęcie emisji cząsteczek
	
	$Explosion.scale_amount_min = sqrt(planet_radius)
	$Explosion.scale_amount_max = planet_radius/3
	$Explosion.emitting = true
	
func _on_body_entered(body):
	#print("Body ", body.name, " is colliding")
	print("BOOM!")
	explosion_on_collision(body)
	#if body is RigidBody3D:
		## Obliczenie nowych prędkości po zderzeniu
		#var m1 = mass
		#var m2 = body.mass
		#var v1_initial = current_velocity
		#var v2_initial = body.linear_velocity
#
		## Wektor normalny zderzenia
		#var collision_normal = (body.global_transform.origin - global_transform.origin).normalized()
#
		## Składowe prędkości wzdłuż normalnej zderzenia
		#var v1_normal = collision_normal.dot(v1_initial)
		#var v2_normal = collision_normal.dot(v2_initial)
#
		## Składowe prędkości po zderzeniu
		#var v1_normal_after = ((m1 - m2) * v1_normal + 2 * m2 * v2_normal) / (m1 + m2)
		#var v2_normal_after = ((m2 - m1) * v2_normal + 2 * m1 * v1_normal) / (m1 + m2)
#
		## Nowe prędkości wzdłuż normalnej zderzenia
		#var v1_final = v1_initial + collision_normal * (v1_normal_after - v1_normal)
		#var v2_final = v2_initial + collision_normal * (v2_normal_after - v2_normal)
#
		## Aktualizacja prędkości planet
		#current_velocity = v1_final
		#linear_velocity = v1_final
		#body.linear_velocity = v2_final
	#else:
		#current_velocity = Vector3(0,0,0)
		#initial_velocity = Vector3(0,0,0)

func _on_body_exited(body):
	pass#print("Body ", body.name, " is exiting")

func _on_area_entered(area):
	#print("Area ", area.name, " is colliding")
	if area not in overlapping_areas:
		overlapping_areas.append(area)

func _on_area_exited(area):
	if area in overlapping_areas:
		overlapping_areas.erase(overlapping_areas.find(area))
