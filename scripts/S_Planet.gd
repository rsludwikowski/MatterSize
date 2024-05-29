extends RigidBody3D 

var Universe = load("res://scripts/Universe.gd")

# Zmienna do kontrolowania prędkości ruchu
var speed = 10.0
# Zmienna do kontrolowania siły
var move_force = 10.0
var direction = Vector3.ZERO
var new_transform = self.global_transform
var initialVelocity = Vector3.ZERO



func UpdateVelocity(delta_T):
	var otherPlanets = get_all_rb3d(get_tree().root)
	for planet in otherPlanets:
		var sqrDst = (planet.global_position - self.global_position).length_squared()
		var forceDir = (planet.global_position - self.global_position).normalized()
		var force = forceDir * Universe.G_constant
		var acceleration = force / self.mass
		self.linear_velocity += acceleration * delta_T
		#print(self.linear_velocity)
		
		

func UpdatePosition(delta_T):
	self.position += self.linear_velocity * delta_T


func _ready():
	# Inicjalizacja skryptu
	self.set_meta("initialVelocity",initialVelocity)
	#print(self.get_meta("metadata/initialVelocity"))
	if initialVelocity != Vector3.ZERO:
		self.linear_velocity = initialVelocity
	pass

#
#func _physics_process(delta):
	#
	##direction = Vector3.ZERO
	##
	##
	##if Input.is_action_pressed("ui_right"):
		##direction.x += 1
	##if Input.is_action_pressed("ui_left"):
		##direction.x -= 1
	##if Input.is_action_pressed("ui_down"):
		##direction.z += 1
	##if Input.is_action_pressed("ui_up"):
		##direction.z -= 1
	##
	###if direction != Vector3.ZERO:
		###var new_transform = self.global_transform
		###new_transform.origin += direction*delta
		###self.global_transform = new_transform
	####move_rigidbody_to(new_transform)
	##move_and_collide(direction*delta)
	#
	#UpdateVelocity(get_all_rb3d(get_tree().root),delta)
	#UpdatePosition(delta)
#
	#
	#
	#
	##
##func integrate_forces(state):
	##direction = Vector3.ZERO
	##
	##if Input.is_action_just_pressed("ui_select"):
		##print("SPacja kliknięta")
		##print(get_all_rb3d(get_tree().root))
	##
	##
	##if Input.is_action_pressed("ui_right"):
		##direction.x += 1
	##if Input.is_action_pressed("ui_left"):
		##direction.x -= 1
	##if Input.is_action_pressed("ui_down"):
		##direction.z += 1
	##if Input.is_action_pressed("ui_up"):
		##direction.z -= 1
##
##
##
	##var new_transform = self.global_transform
	##new_transform.origin += direction
	##self.global_transform = new_transform
	### Normalizowanie kierunku, aby ruch nie był szybszy po przekątnej
	##if direction.length() > 0:
		##direction = direction.normalized() * move_force
##
	### Dodanie siły do obiektu
	####apply_central_force(direction)
##
	### Ograniczenie prędkości obiektu
	##if linear_velocity.length() > speed:
		##linear_velocity = linear_velocity.normalized() * speed
#



func get_all_rb3d(node):
	var objects = []
	
	for child in node.get_children():
		
		if child is RigidBody3D and child != self:
			objects.append(child)
			#print("test2")
		objects += get_all_rb3d(child)  # Rekurencyjne wywołanie funkcji dla dzieci
	return objects
