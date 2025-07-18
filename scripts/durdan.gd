extends CharacterBody2D

class_name Player

# Durdan Movement and Gunning Script: InvertiGO
#
# Object:
# Moves Durdan and rotates him to face the mouse. Fires bullets at the mouse when clicked
#
# Node Structure:
# player
# |_ areaOfPlayerInteraction
# |_ playerAura
#    |_ Dot x50: auraDots that serve as the aura of the player.
# |_ playerBody
#    |_ playerSprite: Sprite2D of the player.
#    |_ neutralSpecialSprite: Sprite2D of the player's gun.
#       |_ gunner: Marker2D that marks where bullets come out.
# |_ playerCollider
#
#
# Note: All functions beginning with "thingy_" relate to player movement or interaction in some way.
#
# GLOBAL VARIABLES
#
# PackedScene Bullet: The scene for the bullet that is fired off by the player
@export var Bullet : PackedScene = preload("res://scenes/Other Things/bullet.tscn")

# float max_speed: The maximum speed of the player under normal conditions
@export var max_speed : float = 400

# float current_max_speed: The current maximum speed of the player under present conditions, based
# on the maximum speed under normal conditions.
var current_max_speed : float = max_speed

# float acceleration: The acceleration of the player until maximum speed is reached.
var acceleration      : float = 1500

# bool firing: Whether or not the gun is firing. This is set by the _input() function to call for
# the player to fire.
var firing            : bool = false

# int health: The health of the player.
var health            : int = 100

# bool is_using_mouse: Determines if the player is using a mouse or a controller.
var is_using_mouse : bool = true

# float previous_rotation: Stores the rotation of the player on the last frame in case the mouse
# is directly on top of the player or another action that would otherwise result in gay behavior.
var previous_rotation : float = 0

# bool is_in_goo: Whether or not the player is in goo. This is set by the goo itself.
var is_in_goo            : bool = false

# Vector2 input_vector: The direction the player is holding on the arrow keys, WASD, D-pad or
# joystick.
var input_vector          : Vector2 = Vector2(0,0)

# Array interactables: An array of all the interactable things that the player can interact with in
# his current position.
var interactables = []

# float theta: A magic adjustment number that goes into the algorithm that fixes the angle of the
# gun so that it shoots at the cursor.
var theta : float = 0.9

# signal you_died: Sent out by thingy_damage when the player dies. Received by the game manager in
# on_player_death
signal sig_you_died(deded : bool)

# signal open_chest(int chestID): Sent out when the player opens a chest. Received by the game
# manager in on_player_opened_chest.
signal sig_open_chest(chestID : int)

var illinois = false



# ENGINE CALLS


# Called on node instantiation. Connects the interaction area signals to methods that deal with
# interactions.
func _ready():
	$areaInteraction.area_entered.connect(_on_interaction_area_area_entered)
	$areaInteraction.area_exited.connect(_on_interaction_area_area_exited)
	$playerBody/neutralSpecialSprite/noGunZone.body_entered.connect(_on_noGunZone_body_entered)
	$playerBody/neutralSpecialSprite/noGunZone.body_exited.connect(_on_noGunZone_body_exited)


func _on_noGunZone_body_entered(body):
	illinois = true

func _on_noGunZone_body_exited(body):
	illinois = false

# Called every time an input occurs. Here it is used to detect if the keyboard and mouse or
# controller is the main input option to be able to switch between mouse aiming and right joystick
# aiming. It also detects if the interact button is pressed while in an interactable area. If so,
# the chest will open by emitting a signal to get the chest contents.
func _input(event : InputEvent):
	if (event is InputEventKey or event is InputEventMouseButton):
		is_using_mouse = true
	elif (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		is_using_mouse = false
	if (event.is_action_pressed("interact") and interactables != []):
		if interactables[0][0] == 'c':
			print("openous intentions")
			sig_open_chest.emit(int(interactables[0][len(interactables[0])-1]))



# SUPPLEMENTARY FUNCTIONS



# Function Vector2 cart_to_polar(Vector2 coords)
# Converts coords to polar with hypotenuse(x,y) and atan(y/x)
# Restores correct angles
# Functionally the same as cart_to_polar_from_object but without location reset
# Used in flick_stick()
# This is actually unnecessary as there is a Godot way to do it however it's 11:40 pm and idfc
func cart_to_polar(coords: Vector2):
	var coordr = sqrt(pow(coords.x, 2)+pow(coords.y, 2))
	var coordphi = atan(coords.y/coords.x)
	if coords.x < 0:
		coordphi = coordphi+PI
	elif coords.x > 0 and coords.y < 0:
		coordphi = coordphi+2*PI
	
	return Vector2(coordr, coordphi)

# Returns the direction the right joystick is pointing for use with joystick controls.
# Uses cart_to_polar to get exact angle. Joystick controls points the gun at the direction the right
# stick faced last. Still kinda jank. Not necessary right now as I have never tested with controler
func flick_stick():
	var direction = Input.get_vector("joystick aim left", "joystick aim right", "joystick aim up", "joystick aim down")
	return cart_to_polar(direction)






# DO SOMETHING FUNCTIONS





# Called every frame to adjust the gun so that when fired, the bullets pass through the cursor. The algorithm is mostly
# just magic, but it works. It stops attempting to adjust when the cursor gets within 112 pixels, which was tested to be
# a reasonable distance. This was literally made with a teensy bit of precalculus and a lot of trial and error.
func thingy_adjust_gun():
	var d = global_position.distance_to(get_global_mouse_position())
	var s = global_position.distance_to($playerBody/neutralSpecialSprite.global_position)
	var question_mark = asin(d*sin(theta)/sqrt(pow(d,2)+pow(s,2)-2*d*s*cos(theta)))
	var cool_number = (question_mark-0.9)*180/PI
	if d > 112:
		$playerBody/neutralSpecialSprite.rotation_degrees = -cool_number*0.9

# Called by bullets to deal damage to the player. Simply decreases the health of the player and emits the
# you_died signal if the health drops at or below zero, which functionally kills the player.
func thingy_damage(damage):
	health -= damage
	if health <= 0:
		health = 0
		sig_you_died.emit(true)

# Called every frame. The hazard triggers are set by the hazards themselves. This function only changes the properties
# of the player to reflect these occurances.
func thingy_hazard():
	if is_in_goo:
		current_max_speed = max_speed*0.5
	elif !is_in_goo:
		current_max_speed = max_speed

# This function instantiates a bullet scene from the firing point every time the fire button is pressed and directs it in the direction the marker is
# facing. It has no adjustment function
func thingy_he_wields_a_gun():
	var b = Bullet.instantiate()
	owner.add_child(b)
	b.transform = $playerBody/neutralSpecialSprite/gunner.global_transform
	b.is_fired_by_player = true

# Sets the velocity of the player based on the inputs and prior state. The function gets a vector of the player inputs (arrow keys, WASD, d-pad, joystick) and 
# checks to see if the vector is zero. If it is, the velocity will decrease according to acceleration. If not, the velocity will increase according to acceleration
# up to current_max_speed. All vectors are normalized before tampered with.
func thingy_velocity(delta):
	input_vector  = Vector2(-Input.get_action_strength("left")+Input.get_action_strength("right"), -Input.get_action_strength("up")+Input.get_action_strength("down")).normalized()
	if input_vector == Vector2.ZERO:
		if velocity.length() > acceleration*delta:
			velocity -= velocity.normalized()*acceleration*delta*11/16
		else:
			velocity = Vector2.ZERO
	else:
		velocity += input_vector*acceleration*delta*2
		if velocity.length() > current_max_speed:
			velocity = velocity.normalized() * current_max_speed




# PROCESS





# The main function, called every frame. This function first adjust the player to be facing the mouse at all times,
# or else facing a reasonable controller direction (TODO). Then, it detects hazards, sets velocity, adjust the gun,
# and fires it if applicable, then moves the player.
func _physics_process(delta):
	var mousepos = get_viewport().get_mouse_position()
	
	var objposition = self.get_position()
	var objrotation = self.get_rotation_degrees()
	
#	hazard_thingy()
	if is_using_mouse:
		$playerBody.look_at(get_global_mouse_position())
	elif !is_using_mouse:
		if (is_nan(flick_stick().y)):
			self.set_rotation_degrees(previous_rotation)
		else:
			self.set_rotation(flick_stick().y)
	
	thingy_hazard()
	thingy_velocity(delta)
	thingy_adjust_gun()
	if Input.is_action_just_pressed("neutral special") and !illinois:
		thingy_he_wields_a_gun()
	
	move_and_slide()
	previous_rotation = rotation_degrees






# SIGNAL RESPONSES




# These functions add or take away possible interactions that the player can interact with at the current moment to the interactables
# array. If and only if the player is inside the interactable area, the player can interact with it.
func _on_interaction_area_area_entered(area):
	interactables.append(area.get_parent().interactionID)
func _on_interaction_area_area_exited(area):
	interactables.erase(area.get_parent().interactionID)
