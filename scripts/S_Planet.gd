extends RigidBody3D 

var universe = load("res://scripts/universe.gd")

# Zmienna do kontrolowania prędkości ruchu
@export var speed = 10.0
# Zmienna do kontrolowania siły
@export var move_force = 10.0
@export var initialVelocity = Vector3.ZERO
var direction = Vector3.ZERO
var new_transform = self.global_transform


func UpdateVelocity(delta_T):
	var otherPlanets = get_all_rb3d()
	for planet in otherPlanets:
		var sqrDst = (planet.global_position - self.global_position).length_squared()
		var forceDir = (planet.global_position - self.global_position).normalized()
		var force = forceDir * universe.G_CONSTANT
		var acceleration = force / self.mass
		self.linear_velocity += acceleration * delta_T
		#print(self.linear_velocity)

func UpdatePosition(delta_T):
	self.position += self.linear_velocity * delta_T

func _ready():
	pass

func get_all_rb3d():
	return get_tree().get_nodes_in_group("Planets")
