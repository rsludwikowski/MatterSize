@tool
extends RigidBody3D

@export var initial_velocity: Vector3
@export var planet_radius: float
@export var color: Color

@onready var hill_area: Area3D = $HillArea
@onready var hill_area_shape: CollisionShape3D = $HillArea/HillAreaShape
@onready var hill_area_surface: MeshInstance3D = $HillArea/HillAreaSurface

@onready var planet_surface: MeshInstance3D = $PlanetSurface
@onready var planet_shape: CollisionShape3D = $PlanetShape

var current_velocity: Vector3

var direction: Vector3
const RADIUS_SCALE = 1.0
var universe = load("res://scripts/universe.gd")

var overlapping_areas = []
var velocity: Vector3

func _ready():
	update_hill_area_radius(pow(planet_radius,2) / sqrt(planet_radius))
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
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = r
	sphere_mesh.height = 2 * r

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = r
	
	planet_surface.mesh = sphere_mesh
	planet_shape.shape = sphere_shape


func update_hill_area_radius(radius):

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius

	var hill_sphere_mesh = SphereMesh.new()
	hill_sphere_mesh.radius = radius
	hill_sphere_mesh.height = 2 * radius

	var hill_material = StandardMaterial3D.new()
	hill_material.albedo_color = Color(1.0, 0.0, 0.0, 0.5) 
	hill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	hill_area_shape.shape = sphere_shape
	hill_area_surface.mesh = hill_sphere_mesh
	hill_area_surface.material_override = hill_material

	hill_area.gravity = 5
	hill_area.gravity_point = true

func update_radius(radius):
	# Aktualizacja CollisionShape3D
	if planet_shape.shape is SphereShape3D:
		planet_shape.shape.radius = radius

		# Aktualizacja MeshInstance3D
		if planet_surface.mesh is SphereMesh:
			var sphere_mesh = planet_surface.mesh
			sphere_mesh.radius = radius
			planet_surface.mesh = sphere_mesh
			
func update_velocity(planets, delta):
	for planet in planets:
		if planet != self:
			direction = planet.global_transform.origin - self.global_transform.origin
			var distance = direction.length()
			if distance == 0:
				continue
			var force_magnitude = (universe.G_CONSTANT * mass * planet.mass) / (distance * distance)
			var force = direction.normalized() * force_magnitude
			var acceleration = force / mass
			current_velocity += acceleration * delta

	
	for area in overlapping_areas:
		if area is Area3D and area.gravity != 0:
			var gravity_dir = (area.get_global_transform().origin - global_transform.origin).normalized()
			current_velocity += gravity_dir * area.gravity * delta

func update_position(delta):
	self.global_transform.origin += current_velocity * delta
	
func UpdateVelocity(delta_T:float):
	var planets = get_tree().get_nodes_in_group("Planets")
	for planet in planets:
		if planet != self:
			var sqrDst = (planet.global_position - self.global_position).length_squared()
			var forceDir = (planet.global_position - self.global_position).normalized()
			var force = forceDir * universe.G_CONSTANT
			var acceleration = force / self.mass
			velocity += acceleration * delta_T

func UpdateVelocity_2(acceleration:Vector3, time_step:float):
	velocity+= acceleration*time_step
	print(velocity)

func UpdatePosition(delta_T):
	move_and_collide(velocity*delta_T)

func create_material(color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.1
	material.roughness = 0.8
	planet_surface.material_override = material

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
