@tool
extends Node3D

var fixed_deltaT = 0.01666666666667

var Universe = load("res://scripts/Universe.gd")
var target_script_path = "res://scripts/S_Planet.gd"

var steps = 10
var visualize
var gameStarted:bool = true




class Planet:
	var mass : float
	var Vels : Array 
	var Pos  : Array
	
	func _init(curr_mass,curr_vel,curr_Pos):
		mass = curr_mass
		Vels.append(curr_vel)
		Pos.append(curr_Pos)
	
	func Print():
		print("Mass: ",mass,"\tVel0: ",Vels[0],"\tPos0: ",Pos[0])




	

	#var target_node = find_node_with_script(get_tree().root, target_script_path)


func _process(delta: float) -> void:
	
	if(Engine.is_editor_hint()):
		print("editor")
		gameStarted = false
	else:
		gameStarted = true
		print("game")
	
	print(gameStarted)
	visualize = self.get_meta("visualize")
	
	if visualize:
		var planets: Array = []
		var planets_t = get_all_planets(get_tree().root,target_script_path)
		
		rewrite_array(planets_t,planets)
		#for pl in planets:
			#pl.Print()
		
		DrawOrbits(planets)
		
		var a = DebugDraw3D.new_scoped_config().set_thickness(0.005)
		steps = self.get_meta("steps")
		
		#for i in steps:
			#DebugDraw3D.draw_line(self.global_position + Vector3(i,i,i),Vector3(5,5,1) + Vector3(i,i,i),Color(1,1,0))
			
			
			
			
		
		
	
	





#func _notification(what):
	#if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#gameStarted = false
	

func rewrite_array(planets_t,planets:Array):
	print(planets_t)
	for p in planets_t:
		
		
		var planet_vel :Vector3
		
		planet_vel = p.linear_velocity
		if gameStarted:
			planet_vel = p.velocity
		
		print("planet VEls: " ,planet_vel, "\t",gameStarted)
		planets.append(Planet.new(p.mass,planet_vel,p.global_position))
		
	for pl in planets:
		pl.Print()
	
		




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


func UpdateVelocity_Lines(curr_planet,planets,delta_T,i):
	
	for planet in planets:
		if planet != curr_planet:
			var sqrDst = (planet.Pos[i] - curr_planet.Pos[i]).length_squared()
			var forceDir = (planet.Pos[i] - curr_planet.Pos[i]).normalized()
			var force = forceDir * Universe.G_constant
			var acceleration = force / curr_planet.mass
			curr_planet.Vels.append(curr_planet.Vels[i] + acceleration * delta_T)
			#print(self.linear_velocity)




func DrawOrbits(planets:Array):
	for i in steps:
		#main loop of drawing orbits
		for planet in planets:
			UpdateVelocity_Lines(planet,planets,fixed_deltaT,i)
		
		for planet in planets:
			UpdatePosition_Lines(planet,fixed_deltaT,i)
		
	
	for planet in planets:
		print(planet.Vels.size())
		for i in steps:
			if i == 0:
				continue
			if i%5 == 0:
				DebugDraw3D.draw_line(planet.Pos[i-5],planet.Pos[i],Color(1,1,0))
				
			#print(planet.Pos[i],"  ",i)
			
	
