extends Node3D

@onready var label1: Label = $Panel/Label1
@onready var label2: Label = $Panel/Label2
@onready var player: Node = get_tree().get_nodes_in_group("Player")[0]
@onready var planets: Array[Planet] = get_all_planets_list()
const G_CONSTANT: float = 6.67


func _ready():
	planets = get_all_planets_list()
	for planet in planets:
		print(planet)

func _process(_delta):
	label1.text = "Pos: %s" % str(player.position)
	label2.text = "Basis\nx: %s \ny %s\nz: %s" % [str(player.basis.x),
	str(player.basis.y),
	str(player.basis.z)]

func _physics_process(delta):
	for planet in planets:
		var acceleration = calculate_acceleration(planet.global_position,planet)
		planet.update_velocity(acceleration,delta)
	
	for planet in planets:
		planet.update_position_old(delta)
	
func get_all_planets_list() -> Array[Planet]:
	var planets: Array[Planet] = []
	var nodes = get_tree().get_nodes_in_group("Planets")
	for planet_node in nodes:
		var planet = planet_node as Planet
		if planet:
			planets.append(planet)
	return planets


func calculate_acceleration(point:Vector3,ignoreBody) -> Vector3:
	var acceleration = Vector3.ZERO
	for body in planets:
		if body != ignoreBody:
			var sqrDst = (body.global_position - point).length_squared()
			var forceDir = (body.global_position - point).normalized()
			var forceMagnitude = G_CONSTANT * (ignoreBody.mass * body.mass) / sqrDst
			var force = forceDir * forceMagnitude
			acceleration += force / ignoreBody.mass
	return acceleration
