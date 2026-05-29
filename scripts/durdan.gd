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
# Note: All functions beginning with "thingy_" relate to plsayer movement or interaction in some way.
#
#
# IMPORTS
#
#
@onready var gun : Gun = $neutralSpecial
@onready var sword : Melee = $flamingLance
#
# CONSTANTS
#
# float MAX_SPEED: The maximum speed of the player under normal conditions
# float ACCELERATION: The acceleration of the player until maximum speed is reached.
# float THETA: A magic adjustment number that goes into the algorithm that fixes the angle of the
#		gun so that it shoots at the cursor.
@export var MAX_SPEED : float = 400.0
@export var ACCELERATION : float = 1500.0
var brackets = preload("res://scenes/Universals/brackets.tscn")
var braces = preload("res://scenes/Universals/curly_brace.tscn")
var THETA : float = 0.9


# FLAGS



# bool is_in_goo: Whether or not the player is in goo. This is set by the goo itself.
# bool illinois: Whether or not the gun is allowed to fire.
# bool is_using_mouse: Determines if the player is using a mouse or a controller.
var is_in_goo : bool = false
var is_using_mouse : bool = true
var is_sprinting : bool = false
var is_movin_over : bool = false
var is_push_flipped : bool = false
var is_cutscene_running : bool = false
var is_bracketed : bool = false
var not_locked_in : bool = false

# STATUS VARIABLES


# float current_max_speed: The current maximum speed of the player under present conditions, based
# on the maximum speed under normal conditions.
var current_max_speed : float = MAX_SPEED
var current_acceleration : float = ACCELERATION
var movin_rotation : float
var cutscene_firing_buffer : int = 0
var lock_on_location : Vector2 

# int health: The health of the player.
var health : float:
	get:
		return health
	set(new_health):
		health = new_health
		sig_set_healthbar.emit(health*100/max_hp)

var max_hp : float = 500
var atk : int = 50
var def : int = 50
var bracket

# float previous_rotation: Stores the rotation of the player on the last frame in case the mouse
# is directly on top of the player or another action that would otherwise result in gay behavior.
var previous_rotation : float = 0


# Array interactables: An array of all the interactable things that the player can interact with in
# his current position.
var interactables : Array[Interactable] = []

#var ability_callable_map : Dictionary = {Aeon.PlayerAbilities.NONE : "none", Aeon.PlayerAbilities.ALIGNMENT : "alignment", Aeon.PlayerAbilities.FONT_SIZE : "font_size"}

var firing_on = false


enum AlignmentStyles {
	ALIGN_LEFT,
	ALIGN_CENTER,
	ALIGN_RIGHT,
	ALIGN_JUSTIFY
}



# SIGNALS
#
#
# signal you_died: Sent out by thingy_damage when the player dies. Received by the game manager in
# 		on_player_death
# signal open_chest(int chestID): Sent out when the player opens a chest. Received by the game
# signal open_chest(int chestID): Sent out when the player opens a chest. Received by the game
# 		manager in on_player_opened_chest.
signal sig_you_died()
signal sig_open_chest(chest : Chest)
signal sig_open_door(doorID : int)
signal sig_set_healthbar(health : float)
signal sig_open_stamp_menu()


# READY


# Called on node instantiation. Connects the interaction area signals to methods that deal with
# interactions.
func _ready() -> void:
	$areaInteraction.area_entered.connect(_on_interaction_area_area_entered)
	$areaInteraction.area_exited.connect(_on_interaction_area_area_exited)
	gun.atk_power = atk
	braces = preload("res://scenes/Universals/curly_brace.tscn")
	brackets = preload("res://scenes/Universals/brackets.tscn")
	health = max_hp

# Signal Calls


# These functions add or take away possible interactions that the player can interact with at the 
# current moment to the interactables array. If and only if the player is inside the interactable 
# area, the player can interact with it.
func _on_interaction_area_area_entered(area : Area2D) -> void:
	if area.get_parent() is Interactable:
		interactables.append(area.get_parent())
	elif area is PowerUp:
		pick_up(area)
func _on_interaction_area_area_exited(area : Area2D) -> void:
	if area.get_parent() is Interactable:
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
		if interactables[0] is Chest and !interactables[0].is_locked:
			print("openous intentions")
			sig_open_chest.emit(interactables[0])
			interactables[0].is_opened = true
		elif interactables[0] is Door and Aeon.player_inventory["keys"] >= 1:
			print("openous intentions")
			sig_open_door.emit(interactables[0])
			interactables[0].is_opened = true
			Aeon.player_inventory["keys"] -= 1
		elif interactables[0] is Stamp:
			sig_open_stamp_menu.emit()
	elif (event.is_action_pressed("sprint")) and is_sprinting == false:
		is_sprinting = true
		current_max_speed = MAX_SPEED*2
		current_acceleration = ACCELERATION*2
	elif (event.is_action_released("sprint")) and is_sprinting == true:
		is_sprinting = false
		current_max_speed = MAX_SPEED
		print("ooiejpgqiohporeihgqpoweihgpoi")
		current_acceleration = ACCELERATION/2



# SUPPLEMENTARY FUNCTIONS


# Returns the direction the right joystick is pointing for use with joystick controls.
# Joystick controls points the gun at the direction the right stick faced last. Still kinda jank.
# Not necessary right now as I do not test with controler
func flick_stick_angle() -> float:
	var direction : Vector2 = Input.get_vector("joystick aim left", "joystick aim right", "joystick aim up", "joystick aim down")
	return atan2(direction.y, direction.x)


func thingy_large_push(rot : float, flip : bool) -> void:
	is_movin_over = true
	if flip:
		movin_rotation = -rot
		is_push_flipped = true
	else:
		movin_rotation = rot
		is_push_flipped = false

func spawn_brackets():
	if !is_bracketed:
		var b_ = brackets.instantiate()
		print(b_)
		b_.owner = self
		b_.host = self
		add_child(b_)
		is_bracketed = true
		bracket = b_
		bracket.busted.connect(_on_bracket_busted)
		print(bracket)
	else:
		bracket.switch_brackets()


	

func _on_bracket_busted():
	is_bracketed = false

# THINGY FUNCTIONS
# Functions that update every frame or something like that


func pick_up(powerup : PowerUp):
	print(powerup.power_up_type)
	apply_buff(powerup.power_up_type)
	powerup.queue_free()
	

func apply_buff(buff_type : Aeon.PowerUpTypes):
	match buff_type:
		Aeon.PowerUpTypes.DMG_UP:
			atk += 30
		Aeon.PowerUpTypes.DEF_UP:
			def += 30
		Aeon.PowerUpTypes.HEAL:
			health += 50


# Called by bullets to deal damage to the player. Simply decreases the health of the player and 
# emits theyou_died signal if the health drops at or below zero, which functionally kills the player.
func thingy_damage(damage) -> void:
	health -= Aeon.calculate_damage(damage, def)
	sig_set_healthbar.emit(health*100/max_hp)
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
	var input_vector  = Vector2(-Input.get_action_strength("left")+Input.get_action_strength("right"), -Input.get_action_strength("up")+Input.get_action_strength("down")).normalized()
	if is_movin_over:
		velocity = (Vector2.ONE*MAX_SPEED).rotated(movin_rotation+PI/2) if !is_push_flipped else (Vector2.ONE*MAX_SPEED).rotated(movin_rotation-PI/2)
		is_movin_over = false
	if input_vector == Vector2.ZERO:
		if velocity.length() > current_acceleration*delta:
			velocity -= velocity.normalized()*current_acceleration*delta*11/16
		else:
			velocity = Vector2.ZERO
	else:
		if velocity.length() > current_max_speed+1:
			velocity -= input_vector*current_acceleration*delta*2
			return
		else:
			velocity += input_vector*current_acceleration*delta*2
		if velocity.length() > current_max_speed:
			velocity = velocity.normalized() * current_max_speed


# SPECIALS

func alignment(direction : AlignmentStyles):
	print("aligning fufufufu")
	match direction:
		AlignmentStyles.ALIGN_LEFT:
			pass
		AlignmentStyles.ALIGN_CENTER:
			pass
		AlignmentStyles.ALIGN_RIGHT:
			pass
		AlignmentStyles.ALIGN_JUSTIFY:
			pass

func font_size(size : int):
	print("sizing xdxdxdxd: ", size)
	pass








# PROCESS





# The main function, called every frame. This function first adjust the player to be facing the mouse at all times,
# or else facing a reasonable controller direction (TODO). Then, it detects hazards, sets velocity, adjust the gun,
# and fires it if applicable, then moves the player.
func _physics_process(delta) -> void:
	if !is_cutscene_running:
		# For facing the mouse {
		
		if not_locked_in:
			if is_using_mouse:
				look_at(get_global_mouse_position())
				gun.adjust(get_global_mouse_position())
			elif !is_using_mouse:
				if (is_nan(flick_stick_angle())):
					set_rotation(previous_rotation)
				else:
					set_rotation(flick_stick_angle())
		else:
			look_at(lock_on_location)
			gun.adjust(lock_on_location)
		
	#	}
	#   Thingy Calls (no particular order)
		#thingy_hazard()
		thingy_velocity(delta)
		
		if Input.is_action_just_pressed("neutral special"):
			if cutscene_firing_buffer == 0:
				if !firing_on:
					gun.fire_continuously()
					firing_on = true
				else:
					gun.fire_continuously(false)
					firing_on = false
					print("project hail mary")
			elif cutscene_firing_buffer > 0:
				cutscene_firing_buffer -= 1
		if Input.is_action_just_pressed("melee"):
			sword.attack()
		if velocity.length() > current_max_speed: velocity = velocity.normalized()*current_max_speed
		move_and_slide()
		previous_rotation = rotation
	else:
		velocity = Vector2.ZERO
		cutscene_firing_buffer = 0
