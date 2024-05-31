@tool
extends RigidBody3D

@export var initial_velocity: Vector3 = Vector3(0,0,0)
@export var planet_radius: float = 3.0
var old_planet_radius = planet_radius
#@export var color: Color = Color(1.0, 1.0, 1.0, 1.0) 
@export  var gravity_strength: float = 9.8
@export var planet_material: Material
@export var planet_hill_material: Material
@onready var hill_area: Area3D = $HillArea
@onready var hill_area_shape: CollisionShape3D = $HillArea/HillAreaShape
@onready var hill_area_surface: MeshInstance3D = $HillArea/HillAreaSurface

@onready var planet_surface: MeshInstance3D = $PlanetSurface
@onready var planet_shape: CollisionShape3D = $PlanetShape

var current_velocity: Vector3

var direction: Vector3
const RADIUS_SCALE = 1.0
var universe = load("res://scripts/universe.gd")
var space = load("res://scripts/space.gd")

var particle_emitter: Node = null
var overlapping_areas = []

func _ready():
	
	update_planet_material()
	update_hill_area_material()
	
	set_planet_radius(planet_radius)
	update_hill_area_radius(pow(planet_radius,2) / sqrt(planet_radius))
	particle_emitter = get_node("Explosion")
	#hill_area.connect("area_entered", Callable(self, "_on_area_entered"))
	#hill_area.connect("area_exited", Callable(self, "_on_area_exited"))

	#var planet_mass = ($Area3D.gravity * planet_radius * planet_radius) / GRAVITATIONAL_CONSTANT
	#mass = planet_mass
	#print(planet_mass)

	current_velocity = initial_velocity

func _process(_delta):
	if Engine.is_editor_hint():
		update_planet_material()
		update_hill_area_material()
		if planet_radius != old_planet_radius:
			set_planet_radius(planet_radius)
			update_hill_area_radius(pow(planet_radius,2) / sqrt(planet_radius))
			
		old_planet_radius = planet_radius
		

func _integrate_forces(state):
	var colliding_bodies = get_colliding_bodies()
	for body in colliding_bodies:
		if body is RigidBody3D:
			print("BOOM!")
			var contact_position = state.get_contact_local_position(0)  # Use the first contact point
			var global_contact_position = state.transform.origin + contact_position
			print("Local position: ", contact_position, " Global position: ", global_contact_position)
			particle_emitter.call("explosion_on_collision", body, global_contact_position)
	update_velocity(state.step)
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
	
	hill_area_shape.shape = sphere_shape
	hill_area_surface.mesh = hill_sphere_mesh
	hill_area.gravity = gravity_strength


func update_radius(radius):
	# Aktualizacja CollisionShape3D
	if planet_shape.shape is SphereShape3D:
		planet_shape.shape.radius = radius

		# Aktualizacja MeshInstance3D
		if planet_surface.mesh is SphereMesh:
			var sphere_mesh = planet_surface.mesh
			sphere_mesh.radius = radius
			planet_surface.mesh = sphere_mesh
			
func update_velocity(delta):
	var planets = get_tree().get_nodes_in_group("Planets")
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
			current_velocity += acceleration * delta_T

func UpdateVelocity_2(acceleration:Vector3, time_step:float):
	current_velocity+= acceleration*time_step
	print(current_velocity)

func UpdatePosition(delta_T):
	move_and_collide(current_velocity*delta_T)

func update_planet_material():
	var material: Material
	if planet_material:
		material = planet_material
	else:
		material = Material.new()
	#material.albedo_color = color
	material.metallic = 0.1
	material.roughness = 0.8
	planet_surface.material_override = material

func update_hill_area_material():
	var hill_material: Material
	if planet_hill_material:
		hill_material = planet_hill_material
	else:
		hill_material = Material.new()

	hill_material.albedo_color = Color(0.0, 0.0, 0.0, 0.5) 
	hill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hill_area_surface.material_override = hill_material

func get_gravity_direction(position) -> Vector3:
	var planet_position = global_transform.origin
	return (planet_position - position).normalized()
	
