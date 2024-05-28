extends RigidBody3D
var hill_radius: float
var planet_radius: float
var planet_mass: float
var initial_velocity: Vector3
var current_velocity: Vector3
# Called when the node enters the scene tree for the first time.
func _ready():

	hill_radius = get_planet_hill_radius()
	planet_radius = get_planet_radius()
	current_velocity = initial_velocity
	#print(name, " hill radius ", hill_radius)
	#print(name, "planet radius ",planet_radius)
	#var planets = get_tree().get_nodes_in_group("Planets")
	#for planet in planets:
		#print(planet.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var planets = get_tree().get_nodes_in_group("Planets")
	update_position(delta)
	update_velocity(planets,delta)

func get_planet_radius():
	var shape = $CollisionShape3D.shape
	var radius: float
	if shape is SphereShape3D:
		radius = shape.radius
		return radius
	else:
		print("get_planet_radius error")
		return -1

func get_planet_hill_radius():
	var shape = $Area3D/CollisionShape3D.shape
	var radius: float
	if shape is SphereShape3D:
		radius = shape.radius
		return radius
	else:
		print("get_planet__hill_radius error")
		return -1

func update_velocity(planets, delta):
	var this = get_node(".")
	for planet in planets:
		if planet != this:
			var sqr_dst = (planet.global_position - this.global_position).length()
			var force_dir = (planet.global_position - this.global_position).normalized()
			var force = (force_dir * 1.1 * this.mass * planet.mass) / sqr_dst
			var acceleration = force / this.mass
			current_velocity += acceleration * delta
			print(acceleration, current_velocity)
		else:
			print("nope")

func update_position(delta):
	position += current_velocity * delta
