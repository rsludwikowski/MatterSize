extends RigidBody3D

@export var hill_radius: float
@export var initial_velocity: Vector3
var current_velocity: Vector3
@export var planet_radius: float
@export var color: Color
const RADIUS_SCALE = 1.0
const GRAVITATIONAL_CONSTANT = 0.000667

func _ready():
	# Połączenie sygnałów
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	self.connect("body_exited", Callable(self, "_on_body_exited"))

	# Połączenie sygnałów dla Area3D
	var hill_area = create_hill_area()
	hill_area.connect("area_entered", Callable(self, "_on_area_entered"))
	hill_area.connect("area_exited", Callable(self, "_on_area_exited"))

	set_planet_radius(planet_radius)
	create_material(color)

	hill_radius = planet_radius + sqrt(planet_radius)

	var planet_mass = $Area3D.gravity * planet_radius * planet_radius / GRAVITATIONAL_CONSTANT
	mass = planet_mass
	print(planet_mass)

	current_velocity = initial_velocity

func _process(_delta):
	pass

func set_planet_radius(r):
	planet_radius = r
	var coll_shape = $CollisionShape3D
	var mesh_instance = $MeshInstance3D

	# Tworzenie nowej instancji SphereMesh dla każdej planety
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = r
	sphere_mesh.height = 2 * r

	mesh_instance.mesh = sphere_mesh

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = r
	coll_shape.shape = sphere_shape

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

func create_hill_area():
	# Tworzenie Area3D
	var hill_area = Area3D.new()
	hill_area.name = "HillArea"
	add_child(hill_area)

	# Tworzenie CollisionShape3D dla Area3D
	var hill_collision_shape = CollisionShape3D.new()
	hill_area.add_child(hill_collision_shape)

	# Tworzenie i przypisywanie kształtu kolizji
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = hill_radius
	hill_collision_shape.shape = sphere_shape

	# Tworzenie wizualizacji (MeshInstance3D)
	var hill_mesh_instance = MeshInstance3D.new()
	hill_mesh_instance.name = "HillMeshInstance"
	hill_area.add_child(hill_mesh_instance)

	var hill_sphere_mesh = SphereMesh.new()
	hill_sphere_mesh.radius = hill_radius
	hill_sphere_mesh.height = 2 * hill_radius
	hill_mesh_instance.mesh = hill_sphere_mesh

	# Opcjonalne: ustawienie materiału dla wizualizacji obszaru
	var hill_material = StandardMaterial3D.new()
	hill_material.albedo_color = Color(1.0, 0.0, 0.0, 0.5)  # Półprzezroczysty czerwony kolor
	hill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hill_mesh_instance.material_override = hill_material

	return hill_area

func update_velocity(planets, delta):
	var this = self
	for planet in planets:
		if planet != this:
			var distance = (planet.global_transform.origin - this.global_transform.origin).length()
			var force_dir = (planet.global_transform.origin - this.global_transform.origin).normalized()
			var force = (force_dir * GRAVITATIONAL_CONSTANT * this.mass * planet.mass) / (distance * distance)
			var acceleration = force / this.mass
			current_velocity += acceleration * delta

func update_position(delta):
	self.global_transform.origin += current_velocity * delta

func create_material(color):
	var mesh_instance = $MeshInstance3D
	# Tworzenie nowego materiału
	var material = StandardMaterial3D.new()
	# Ustawienia materiału
	material.albedo_color = color
	material.metallic = 0.1
	material.roughness = 0.8
	# Dodawanie materiału do mesha
	mesh_instance.material_override = material

func _on_body_entered(body):
	print("Body ", body.name, " is colliding")

func _on_body_exited(body):
	print("Body ", body.name, " is exiting")

func _on_area_entered(area):
	print("Area ", area.name, " is colliding")

func _on_area_exited(area):
	print("Area ", area.name, " is exiting")
