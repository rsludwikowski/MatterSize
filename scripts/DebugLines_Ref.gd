@tool
extends Node3D

var fixed_deltaT = 0.01666666666667

var universe = load("res://scripts/space_walk.gd")
var target_script_path = "res://scripts/planet.gd"

@export var steps:int = 10
@export var visualize: bool
var gameStarted:bool = true
@onready var global_planets: Array[Planet] = get_all_planets_list()
@export var referenceBody: RigidBody3D

@export var YYYH: int = 5


var planetIndex:int = 0

class PlanetLines:
	var mass : float
	var Vels : Array 
	var Pos  : Array
	var freeze: bool
	
	func _init(curr_mass,curr_vel,curr_Pos,b_freeze):
		mass = curr_mass
		Vels.append(curr_vel)
		Pos.append(curr_Pos)
		freeze = b_freeze
		
	func Print():
		print("Mass: ",mass,"\tVel0: ",Vels[0],"\tPos0: ",Pos[0])

	#var target_node = find_node_with_script(get_tree().root, target_script_path)


func _process(delta: float) -> void:
	#print("Global planets: ",global_planets)
	if(Engine.is_editor_hint()):
		#print("editor")
		gameStarted = false
	else:
		gameStarted = true
		#print("game")
	
	#print(gameStarted)
	
	
	if visualize:
		var planets: Array = []
		var planets_t = global_planets
		
		rewrite_array(planets_t,planets)
		for pl in planets:
			pl.Print()
		
		DrawOrbits(planets)
		
		var a = DebugDraw3D.new_scoped_config().set_thickness(0.005)
		
		
		#for i in steps:
			#DebugDraw3D.draw_line(self.global_position + Vector3(i,i,i),Vector3(5,5,1) + Vector3(i,i,i),Color(1,1,0))
			
			
			
			
		
		
	
	

#func _notification(what):
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#gameStarted = false
	

func rewrite_array(planets_t,planets:Array):
	#print(planets_t)
	for p in planets_t:
		
		
		var planet_vel :Vector3
		
		planet_vel = p.initial_velocity
		if gameStarted:
			planet_vel = p.current_velocity
		
		#print("planet VEls: " ,planet_vel, "\t",gameStarted)
		planets.append(PlanetLines.new(p.mass,planet_vel,p.global_position,p.freeze))
		if(p == referenceBody):
			planetIndex = planets.size()-1
			print("INDEX: ",planetIndex)
	#for pl in planets:
		#pl.Print()
	
		




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

func UpdatePosition_Lines(curr_planet,delta_T,i):
	curr_planet.Pos.append(curr_planet.Pos[i] + curr_planet.Vels[i+1]*delta_T) 


func CalculateAcceleration(point:Vector3,ignoreBody,planets,i):
	var acceleration = Vector3.ZERO
	for body in planets:
		if body != ignoreBody:
			var sqrDst = (body.Pos[i] - point).length_squared()
			var forceDir = (body.Pos[i] - point).normalized()
			var force = forceDir * universe.G_CONSTANT
			acceleration += force*body.mass/sqrDst
	return acceleration


func UpdateVelocity_Lines(curr_planet,planets,delta_T,i):
	for planet in planets:
		if planet != curr_planet:
			var sqrDst = (planet.Pos[i] - curr_planet.Pos[i]).length_squared()
			var forceDir = (planet.Pos[i] - curr_planet.Pos[i]).normalized()
			var force = forceDir * universe.G_CONSTANT
			var acceleration = force / curr_planet.mass
			curr_planet.Vels.append(curr_planet.Vels[i] + acceleration * delta_T)
			#print(self.linear_velocity)




func DrawOrbits(planets:Array):
	for i in steps:
		#main loop of drawing orbits
		for planet in planets:
			var acceleration = CalculateAcceleration(planet.Pos[i],planet,planets,i)
			if(planet.freeze):
				planet.Vels.append(Vector3.ZERO)
			else:
				planet.Vels.append(planet.Vels[i] + acceleration*fixed_deltaT)
		
		for planet in planets:
			UpdatePosition_Lines(planet,fixed_deltaT,i)
		
	
	for planet in planets:
		#print(planet.Vels.size())
		for i in steps:
			if i == 0:
				continue
			if i%YYYH == 0:
				DebugDraw3D.draw_line(planet.Pos[i-YYYH]-planets[planetIndex].Pos[i-YYYH]+ referenceBody.global_position,planet.Pos[i]-planets[planetIndex].Pos[i]+referenceBody.global_position,Color(1,1,0))
				
			#print(planet.Pos[i],"  ",i)
			
	





func get_all_planets_list() -> Array[Planet]:
	var planets: Array[Planet] = []
	var nodes = get_tree().get_nodes_in_group("Planets")
	for planet_node in nodes:
		var planet = planet_node as Planet
		if planet:
			planets.append(planet)
	return planets
