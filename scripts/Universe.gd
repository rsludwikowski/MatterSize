extends Node

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
		planet.UpdateVelocity(delta)
	
	for planet in planets:
		planet.UpdatePosition(delta)
	
