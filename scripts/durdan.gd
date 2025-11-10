extends CharacterBody2D

class_name Player

# Durdan Movement and Gunning Script: InvertiGO
#
# Object:
# Moves Durdan and rotates him to face the mouse. Fires bullets at the mouse when clicked
#
# Node Structure:
# player
# |_ areaInteraction: Area2D that marks where the player can interact with chests, etc.
#    |_ areaInteractionCollider
# |_ durdanSprite: Sprite2D of the player.
# |_ neutralSpecialSprite: Sprite2D of the player's gun.
#    |_ gunner: Marker2D that marks where bullets come out.
#    |_ noGunZone: Area2D that prohibits firing if the gun is inside a wall.
#       |_ noGunZoneCollider
# |_ playerCollider
#
#
# Note: All functions beginning with "thingy_" relate to player movement or interaction in some way.
#
#
# IMPORTS
#
#
# PackedScene Bullet: The scene for the bullet that is fired off by the player
@export var bullet : PackedScene = preload("res://scenes/Other Things/bullet.tscn")
@onready var gun : Gun = $neutralSpecial
#
# CONSTANTS
#
# float MAX_SPEED: The maximum speed of the player under normal conditions
# float ACCELERATION: The acceleration of the player until maximum speed is reached.
# float THETA: A magic adjustment number that goes into the algorithm that fixes the angle of the
#		gun so that it shoots at the cursor.
@export var MAX_SPEED : float = 400.0
@export var ACCELERATION : float = 1500.0
var THETA : float = 0.9


# FLAGS



# bool is_in_goo: Whether or not the player is in goo. This is set by the goo itself.
# bool illinois: Whether or not the gun is allowed to fire.
# bool is_using_mouse: Determines if the player is using a mouse or a controller.
var is_in_goo : bool = false
var is_in_illinois : bool = false
var is_using_mouse : bool = true
var is_sprinting : bool = false


# STATUS VARIABLES


# float current_max_speed: The current maximum speed of the player under present conditions, based
# on the maximum speed under normal conditions.
var current_max_speed : float = MAX_SPEED

# int health: The health of the player.
var health : int = 100

# float previous_rotation: Stores the rotation of the player on the last frame in case the mouse
# is directly on top of the player or another action that would otherwise result in gay behavior.
var previous_rotation : float = 0

# Vector2 input_vector: The direction the player is holding on the arrow keys, WASD, D-pad or
# joystick.
var input_vector : Vector2 = Vector2.ZERO

# Array interactables: An array of all the interactable things that the player can interact with in
# his current position.
var interactables : Array[Interactable] = []

var inventory : Dictionary = {}




# SIGNALS
#
#
# signal you_died: Sent out by thingy_damage when the player dies. Received by the game manager in
# 		on_player_death
# signal open_chest(int chestID): Sent out when the player opens a chest. Received by the game
# 		manager in on_player_opened_chest.
signal sig_you_died()
signal sig_open_chest(chest : Chest)
signal sig_open_door(doorID : int)
signal sig_change_inventory(item : String, bywhat : int)
signal sig_query_inventory()
signal sig_set_healthbar(health : float)


# READY


# Called on node instantiation. Connects the interaction area signals to methods that deal with
# interactions.
func _ready() -> void:
	$areaInteraction.area_entered.connect(_on_interaction_area_area_entered)
	$areaInteraction.area_exited.connect(_on_interaction_area_area_exited)
	sig_set_healthbar.emit(100.0)


# Signal Calls


# These functions add or take away possible interactions that the player can interact with at the 
# current moment to the interactables array. If and only if the player is inside the interactable 
# area, the player can interact with it.
func _on_interaction_area_area_entered(area : Area2D) -> void:
	interactables.append(area.get_parent())
func _on_interaction_area_area_exited(area : Area2D) -> void:
	interactables.erase(area.get_parent())

# Called every time an input occurs. Here it is used to detect if the keyboard and mouse or
# controller is the main input option to be able to switch between mouse aiming and right joystick
# aiming. It also detects if the interact button is pressed while in an interactable area. If so,
# the chest will open by emitting a signal to get the chest contents.
func _input(event : InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton):
		is_using_mouse = true
	elif (event is InputEventJoypadButton or event is InputEventJoypadMotion):
		is_using_mouse = false
	if (event.is_action_pressed("interact") and interactables != []):
		if interactables[0] is Chest:
			print("openous intentions")
			sig_open_chest.emit(interactables[0])
			interactables[0].is_opened = true
		elif interactables[0] is Door and inventory["keys"] >= 1:
			print("openous intentions")
			sig_open_door.emit(interactables[0])
			interactables[0].is_opened = true
			sig_change_inventory.emit("keys", -1)
	elif (event.is_action_pressed("sprint")) and is_sprinting == false:
		is_sprinting = true
		MAX_SPEED *= 2
		ACCELERATION *= 2
	elif (event.is_action_released("sprint")) and is_sprinting == true:
		is_sprinting = false
		MAX_SPEED /= 2
		ACCELERATION /= 2



# SUPPLEMENTARY FUNCTIONS


# Returns the direction the right joystick is pointing for use with joystick controls.
# Joystick controls points the gun at the direction the right stick faced last. Still kinda jank.
# Not necessary right now as I do not test with controler
func flick_stick_angle() -> float:
	var direction : Vector2 = Input.get_vector("joystick aim left", "joystick aim right", "joystick aim up", "joystick aim down")
	return atan2(direction.y, direction.x)






# THINGY FUNCTIONS
# Functions that update every frame or something like that






# Called by bullets to deal damage to the player. Simply decreases the health of the player and 
# emits theyou_died signal if the health drops at or below zero, which functionally kills the player.
func thingy_damage(damage) -> void:
	health -= damage
	sig_set_healthbar.emit(health)
	if health <= 0:
		health = 0
		sig_you_died.emit()

# Called every frame. The hazard triggers are set by the hazards themselves. This function only
# changes the properties of the player to reflect these occurances.
func thingy_hazard() -> void:
	if is_in_goo:
		current_max_speed = MAX_SPEED*0.5
	elif !is_in_goo:
		current_max_speed = MAX_SPEED



# Sets the velocity of the player based on the inputs and prior state. The function gets a vector of
# the player inputs (arrow keys, WASD, d-pad, joystick) and checks to see if the vector is zero. If
# it is, the velocity will decrease according to acceleration. If not, the velocity will increase
# according to acceleration up to current_max_speed. All vectors are normalized before tampered with.
func thingy_velocity(delta) -> void:
	input_vector  = Vector2(-Input.get_action_strength("left")+Input.get_action_strength("right"), -Input.get_action_strength("up")+Input.get_action_strength("down")).normalized()
	if input_vector == Vector2.ZERO:
		if velocity.length() > ACCELERATION*delta:
			velocity -= velocity.normalized()*ACCELERATION*delta*11/16
		else:
			velocity = Vector2.ZERO
	else:
		if velocity.length() > current_max_speed+1:
			velocity -= input_vector*ACCELERATION*delta*2
			return
		else:
			velocity += input_vector*ACCELERATION*delta*2
		if velocity.length() > current_max_speed:
			velocity = velocity.normalized() * current_max_speed




# PROCESS





# The main function, called every frame. This function first adjust the player to be facing the mouse at all times,
# or else facing a reasonable controller direction (TODO). Then, it detects hazards, sets velocity, adjust the gun,
# and fires it if applicable, then moves the player.
func _physics_process(delta) -> void:
	sig_query_inventory.emit()
	# For facing the mouse {
	
	if is_using_mouse:
		pass
		look_at(get_global_mouse_position())
	elif !is_using_mouse:
		if (is_nan(flick_stick_angle())):
			self.set_rotation_degrees(previous_rotation)
		else:
			self.set_rotation(flick_stick_angle())
	
#	}
	print(velocity)

#   Thingy Calls (no particular order)
	thingy_hazard()
	thingy_velocity(delta)
	gun.adjust(get_global_mouse_position(), THETA)
	if Input.is_action_just_pressed("neutral special") and !is_in_illinois:
		gun.fire()
	
	move_and_slide()
	previous_rotation = rotation_degrees
