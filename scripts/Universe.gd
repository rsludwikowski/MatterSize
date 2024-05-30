extends Node3D

const G_CONSTANT = 6.67

var planets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	planets = get_tree().get_nodes_in_group("Planets")
	print(planets)

func get_G():
	return G_CONSTANT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for planet in planets:
		var acceleration = CalculateAcceleration(planet.global_position,planet)
		planet.UpdateVelocity_2(acceleration,delta)
		#planet.UpdateVelocity(delta)
	
	
	
	for planet in planets:
		planet.UpdatePosition(delta)
	



func CalculateAcceleration(point:Vector3,ignoreBody):
	var acceleration = Vector3.ZERO
	for body in planets:
		if body != ignoreBody:
			var sqrDst = (body.global_position - point).length_squared()
			var forceDir = (body.global_position - point).normalized()
			var force = forceDir * G_CONSTANT
			acceleration += force*body.mass/sqrDst
	return acceleration
