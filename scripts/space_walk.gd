extends Node3D

@onready var label1: Label = $Panel/Label1
@onready var label2: Label = $Panel/Label2
@onready var player: Node = get_tree().get_nodes_in_group("Player")[0]
@onready var masses: Array[Node] = get_tree().get_nodes_in_group("MassObjects")
const G_CONSTANT: float = 6.67


func _ready():
	for object in masses:
		print(object)

func _process(_delta):
	label1.text = "Pos: %s" % str(player.position)
	label2.text = "Basis\nx: %s \ny %s\nz: %s" % [str(player.basis.x),
	str(player.basis.y),
	str(player.basis.z)]

func _physics_process(delta):
	for object in masses:
		var acceleration = calculate_acceleration(object.global_position,object)
		object.update_velocity(acceleration,delta)
	
	for object in masses:
		object.update_position_old(delta)
	
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
	for object in masses:
		if object != ignoreBody:
			var sqrDst = (object.global_position - point).length_squared()
			var forceDir = (object.global_position - point).normalized()
			var forceMagnitude = G_CONSTANT * (ignoreBody.mass * object.mass) / sqrDst
			var force = forceDir * forceMagnitude
			acceleration += force / ignoreBody.mass
	return acceleration
