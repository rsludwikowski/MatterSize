@tool
extends RigidBody3D

class_name Planet

@export var initial_velocity: Vector3 = Vector3(0,0,0)
@export var planet_radius: float = 3.0
@export var hill_area_radius: float = 6.0
@export var gravity_strength: float = 9.8
@export var planet_material: Material
@export var planet_hill_material: Material
@onready var hill_area: Area3D = $HillArea
@onready var hill_area_shape: CollisionShape3D = $HillArea/HillAreaShape
@onready var hill_area_surface: MeshInstance3D = $HillArea/HillAreaSurface

@onready var planet_surface: MeshInstance3D = $PlanetSurface
@onready var planet_shape: CollisionShape3D = $PlanetShape

var old_planet_radius: float = planet_radius
var old_hill_area_radius: float = hill_area_radius
var current_velocity: Vector3

var direction: Vector3

@onready var particle_emitter: CPUParticles3D = $Explosion
var overlapping_areas = []

func _ready():
	
	update_planet_material()
	update_hill_area_material()
	
	set_planet_radius(planet_radius)
	update_hill_area_radius(hill_area_radius)
	current_velocity = initial_velocity

func _process(_delta):
	if Engine.is_editor_hint():
		if planet_radius != old_planet_radius or hill_area_radius != old_hill_area_radius:
			update_planet_material()
			update_hill_area_material()
			set_planet_radius(planet_radius)
			update_hill_area_radius(hill_area_radius)
			old_planet_radius = planet_radius
			old_hill_area_radius = hill_area_radius
		

func _integrate_forces(state):
	var colliding_bodies = get_colliding_bodies()
	for body in colliding_bodies:
		if body is Planet:
			particle_emitter.call("explosion_on_collision", body)
	#update_velocity(state.step)
	#update_position(state.step)

func set_planet_radius(r: float) -> void:
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = r
	sphere_mesh.height = 2 * r

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = r
	
	planet_surface.mesh = sphere_mesh
	planet_shape.shape = sphere_shape


func update_hill_area_radius(radius) -> void:

	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius

	var hill_sphere_mesh = SphereMesh.new()
	hill_sphere_mesh.radius = radius
	hill_sphere_mesh.height = 2 * radius
	
	hill_area_shape.shape = sphere_shape
	hill_area_surface.mesh = hill_sphere_mesh
	hill_area.gravity = self.gravity_strength


func update_radius(radius) -> void:
	# Aktualizacja CollisionShape3D
	if planet_shape.shape is SphereShape3D:
		planet_shape.shape.radius = radius

		# Aktualizacja MeshInstance3D
		if planet_surface.mesh is SphereMesh:
			var sphere_mesh = planet_surface.mesh
			sphere_mesh.radius = radius
			planet_surface.mesh = sphere_mesh

func update_position_old(delta) -> void:
	self.global_transform.origin += current_velocity * delta

func update_velocity(acceleration:Vector3, time_step:float) -> void:
	current_velocity+= acceleration*time_step
	if(self.freeze):
		current_velocity = Vector3.ZERO

func update_position(delta_T) -> void:
	move_and_collide(current_velocity*delta_T)
	
	
#region Materials
func update_planet_material() -> void:
	var material: StandardMaterial3D
	if planet_material:
		material = planet_material
		material.metallic = 0.1
		material.roughness = 0.8
	else:
		material = StandardMaterial3D.new()
		material.albedo_color = get_random_color()
		material.metallic = 0.1
		material.roughness = 0.8
	
	planet_surface.material_override = material

func get_random_color() -> Color:
	var r = randf()
	var g = randf()
	var b = randf()
	return Color(r, g, b, 1.0)

func update_hill_area_material() -> void:
	var hill_material: Material
	if planet_hill_material:
		hill_material = planet_hill_material
	else:
		hill_material = Material.new()

	hill_material.albedo_color = Color(0.0, 0.0, 0.0, 0.5) 
	hill_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hill_area_surface.material_override = hill_material
#endregion


func get_gravity_direction(position) -> Vector3:
	var planet_position = global_transform.origin
	return (planet_position - position).normalized()
	
