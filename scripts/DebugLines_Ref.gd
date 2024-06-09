@tool
extends Node3D

var fixed_deltaT = 0.01666666666667

@export var universe: Node
@export var visualize: bool
@export var steps:int = 10
@export var referenceBody: RigidBody3D
@export var YYYH: int = 5

@onready var global_planets: Array[Planet] = get_all_planets_list()
var gameStarted:bool = true
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

func _ready():
	pass
func _process(delta: float) -> void:
	if(Engine.is_editor_hint()):
		#print("editor")
		gameStarted = false
	else:
		gameStarted = true
		#print("game")
	
	#print(gameStarted)
	
	
	if visualize:
		var planets_preditions: Array = []
		var planets_in_scene = global_planets
		
		planets_preditions = planets_predictions_init(planets_in_scene)
		var a = DebugDraw3D.new_scoped_config().set_thickness(0.8)
		DrawOrbits(planets_preditions)
		

func planets_predictions_init(planets_in_scene):
	var planets_path_predictions: Array= []
	for p in planets_in_scene:
		
		
		var planet_vel :Vector3
		
		planet_vel = p.initial_velocity
		if gameStarted:
			planet_vel = p.current_velocity
		
		planets_path_predictions.append(
			PlanetLines.new(p.mass,planet_vel,p.global_position,p.freeze)
			)
			
		if(p == referenceBody):
			planetIndex = planets_path_predictions.size()-1
			print("INDEX: ",planetIndex)
	
	return planets_path_predictions
	

func get_all_planets(node,script_path):
	var objects = []
	
	for child in node.get_children():
		
		if child is RigidBody3D and child.get_script() and child.get_script().resource_path == script_path:
			objects.append(child)
			#print("test2")
		objects += get_all_planets(child,script_path)  # Rekurencyjne wywołanie funkcji dla dzieci
	return objects


func UpdatePosition_Lines(curr_planet,delta_T,i):
	curr_planet.Pos.append(curr_planet.Pos[i] + curr_planet.Vels[i+1]*delta_T) 


func CalculateAcceleration(point:Vector3,ignoreBody,planets,i):
	var acceleration = Vector3.ZERO
	for body in planets:
		if body != ignoreBody:
			var sqrDst = (body.Pos[i] - point).length_squared()
			var forceDir = (body.Pos[i] - point).normalized()
			var forceMagnitude = universe.G_CONSTANT * (ignoreBody.mass * body.mass) / sqrDst
			var force = forceDir * forceMagnitude
			acceleration += force / ignoreBody.mass
	return acceleration


func UpdateVelocity_Lines(curr_planet,planets,delta_T,i):
	for planet in planets:
		if planet != curr_planet:
			var sqrDst = (planet.Pos[i] - curr_planet.Pos[i]).length_squared()
			var forceDir = (planet.Pos[i] - curr_planet.Pos[i]).normalized()
			var forceMagnitude = universe.G_CONSTANT * (curr_planet.mass * planet.mass) / sqrDst
			var force = forceDir * forceMagnitude
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
