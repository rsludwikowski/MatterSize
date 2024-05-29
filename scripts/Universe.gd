extends Node

const G_constant = 6.67

var planets = []


func get_all_planets(node,script_path):
	var objects = []
	
	for child in node.get_children():
		
		if child is RigidBody3D and child.get_script() and child.get_script().resource_path == script_path:
			objects.append(child)
			#print("test2")
		objects += get_all_planets(child,script_path)  # Rekurencyjne wywołanie funkcji dla dzieci
	return objects



func find_node_with_script(node, script_path):
	if node.get_script() and node.get_script().resource_path == script_path:
		return node
	
	for child in node.get_children():
		var result = find_node_with_script(child, script_path)
		if result:
			return result
	
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	var target_script_path = "res://scripts/S_Planet.gd"
	#var target_node = find_node_with_script(get_tree().root, target_script_path)
	planets = get_all_planets(get_tree().root,target_script_path)
	print(planets)
	 # Replace with function body.

func get_G():
	return G_constant

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	for planet in planets:
		planet.UpdateVelocity(delta)
	
	for planet in planets:
		planet.UpdatePosition(delta)
	
