extends RigidBody3D

var hill_radius: float
var initial_velocity: Vector3
var current_velocity: Vector3
var planet_radius: float
const RADIUS_SCALE = 1.0

func _ready():
	initial_velocity = Vector3(0, 0, 0)
	current_velocity = initial_velocity
	
	# Pobierz masę ustawioną w inspektorze
	var planet_mass = self.mass  # Używamy self.mass aby upewnić się, że pobieramy lokalną masę instancji
	var r = calculate_radius_from_mass(planet_mass)
	print("Planet: ", self.name, " mass: ", planet_mass, " radius: ", r)
	set_planet_radius(r)

func _process(_delta):
	pass

func set_planet_radius(r):
	planet_radius = r
	var coll_shape = get_node("CollisionShape3D")
	var mesh_instance = get_node("MeshInstance3D")
	
	# Tworzenie nowej instancji SphereMesh dla każdej planety
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = r
	sphere_mesh.height = 2*r
	
	mesh_instance.mesh = sphere_mesh
	
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = r
	coll_shape.shape = sphere_shape
	
	# Dodatkowe skalowanie planety
	self.scale = Vector3(r, r, r)

func calculate_radius_from_mass(mass):
	return RADIUS_SCALE * pow(mass, 1.0 / 3.0)

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

func update_velocity(planets, delta):
	var this = self
	for planet in planets:
		if planet != this:
			var distance = (planet.global_transform.origin - this.global_transform.origin).length()
			var force_dir = (planet.global_transform.origin - this.global_transform.origin).normalized()
			var force = (force_dir * 0.5 * this.mass * planet.mass) / (distance * distance)
			var acceleration = force / this.mass
			current_velocity += acceleration * delta

func update_position(delta):
	self.global_transform.origin += current_velocity * delta
