extends RigidBody3D 

var universe = load("res://scripts/universe.gd")

# Zmienna do kontrolowania prędkości ruchu
@export var speed = 10.0
# Zmienna do kontrolowania siły
@export var move_force = 10.0
@export var initialVelocity = Vector3.ZERO
var direction = Vector3.ZERO
var new_transform = self.global_transform
var velocity: Vector3

func planetInfo():
	print("Vel: ",velocity,"\tPos: ",self.position,"\tMass: ",self.mass)


func UpdateVelocity(delta_T:float):
	var otherPlanets = get_all_rb3d(get_tree().root)
	for planet in otherPlanets:
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

func getVelMeta():
	var vel:Vector3 = get_meta("initialVelocity")
	return vel

func _ready():
	# Inicjalizacja skryptu
	velocity = self.linear_velocity
	self.linear_velocity = Vector3.ZERO

func get_all_rb3d(node):
	var objects = []
	
	for child in node.get_children():
		
		if child is RigidBody3D and child != self:
			objects.append(child)
		objects += get_all_rb3d(child)  # Rekurencyjne wywołanie funkcji dla dzieci
	return objects
