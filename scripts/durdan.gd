extends CharacterBody2D

class_name Player

# Durdan Movement and Gunning Script
# (far too complicated)
#
# Object:
# Moves Durdan at a quadratic velocity and rotates him to face the mouse.
#
# Clarifications:
# Quadratic/Parabolic Velocity: Velocity follows an upside-down parabola, with the vertex being the peak
# velocity, the y axis being velocity, and the x axis being time. Alternatively speaking, the acceleration
# decreases linearly with an initial velocity greater than 0, with one positive zero and one zero at the
# origin in the velocity function
#
# Global Variables:
# PackedScene Bullet: Pointer to the bullet scene
# GameManager game_manager: Pointer to the root/main node, also known as the game or gamemanager node.
# float maxspeed: Maximum speed of movement
# float maxveltime: Time in seconds to reach maximum speed
# float deltatime: Time in seconds since session beginning.
# int framecount: Number of frames since session beginning.
# Array rdlu[float*4]: Utility variables for the time since input pressed and depressed
# Array inputstrings[float*4]: Includes the four input.getactionstrength strings in order needed for looping
# Array velocitymultiplier[float*4]: Contains the four sign multipliers needed for looping
# bool firing: Set to true if the firing button is being held down
# float moment_firing: Temporary push helper variable that helps with calculating delay in consecutive shots
# float health: The health of the player. Decreases when taking damage.
# bool using_mouse: Holds whether the keyboard/mouse or controller is default. If true, keyboard/mouse is default
# float previous_rotation: Holds the rotation of the player in the previous frame for when angle is nan
#
# Signals:
# you_died(bool deded): Emitted when the health of the player reaches 0. Used to show death menu.
#
# Functions:
# Vector2 cart_to_polar_from_object(Vector2 coords, Vector2 obj): Returns polar coordinates of coords with obj as the origin.
# Vector2 polar_rad_to_deg(float rads): Returns polar coordinates rads with the phi part in degrees. Helper function.
# float vel(float x): Returns the velocity function of x, based on quadratic velocity.
# do_the_delta_input_thing(float delta): Sets l, u, d, and r based on the inputs and previous variable assignments.
# accel_thingy(): Calculates the velocity of Durdan with the l, u, d, and r variables.
# gunner_thingy(): Handles firing and instantiates bullets.
# damage_thingy(float damage): Decreases health by damage.
# _physics_process(float delta): Moves and rotates Durdan properly and fires his bullets.

@export var Bullet : PackedScene = preload("res://scenes/Other Things/bullet.tscn")
@export var Goo : Area2D

@export var game_manager : GameManager

@export var maxsped : float = 400 # b
var maxspeed : float = maxsped
@export var maxveltime : float = 0.75 # m

var acceleration : float = 1500

var deltatime : float = 0
var framecount : int = 0
var rldu = [0.0,0.0,0.0,0.0]
var last_frame = [0,0,0,0]
var inputstrings = ["right", "left", "down", "up"]
var velocitymultiplier = [1, -1, 1, -1]
var velocityarray = [0.0,0.0,0.0,0.0]
var accelarray = [0.0,0.0,0.0,0.0]
var firing : bool = false
var moment_firing : int = 0
var health : int = 100
var using_mouse : bool = true
var previous_rotation : float = 0
var in_goo : bool = false
var exit_goo : bool = false
var inputvec : Vector2 = Vector2(0,0)

signal you_died(deded : bool)

func _ready():
	Goo.body_exited.connect(on_Goo_body_exited)

# Function Vector2 cart_to_polar_from_object(Vector2 coords, Vector2 obj)
# Reoriginizes obj to be the origin
# Converts coords to polar with hypotenuse(x,y) and atan(y/x)
# Restores correct angles
func cart_to_polar_from_object(coords: Vector2, obj: Vector2):
	var x = coords.x - obj.x
	var y = coords.y - obj.y
	var coordr = sqrt(pow(x, 2)+pow(y, 2))
	var coordphi = atan(y/x)
	if x < 0:
		coordphi = coordphi+PI
	elif x > 0 and y < 0:
		coordphi = coordphi+2*PI
	
	return Vector2(coordr, coordphi)

# Function Vector2 cart_to_polar(Vector2 coords)
# Converts coords to polar with hypotenuse(x,y) and atan(y/x)
# Restores correct angles
# Functionally the same as cart_to_polar_from_object but without location reset
# Used in flick_stick()
func cart_to_polar(coords: Vector2):
	var coordr = sqrt(pow(coords.x, 2)+pow(coords.y, 2))
	var coordphi = atan(coords.y/coords.x)
	if coords.x < 0:
		coordphi = coordphi+PI
	elif coords.x > 0 and coords.y < 0:
		coordphi = coordphi+2*PI
	
	return Vector2(coordr, coordphi)
	
func quadratic_formula(a : float, b : float, c : float):
	return (-b+sqrt(b*b-4*a*c))/(2*a)

# Function Vector2 polar_rad_to_deg(Vector2 rads)
# Returns Vector2 with same polar coords and converted phi rads into degrees
func polar_rad_to_deg(rads: Vector2):
	return Vector2(rads.x, rads.y*(180/PI))

# Function Vector2 flick_stick()
# Returns the direction the right joystick is pointing for use with joystick controls.
# Uses cart_to_polar to get exact angle. Joystick controls points the gun at the direction the right
# stick faced last. Still kinda jank.
func flick_stick():
	var direction = Input.get_vector("joystick aim left", "joystick aim right", "joystick aim up", "joystick aim down")
	return cart_to_polar(direction)

# Function float vel(float x)
# Velocity function v(x) = -(b/m^2)x^2 + (b/m)x (kinda just a magic function lol)
# Produces upside down parabola with vertex at (maxveltime, maxspeed) and zeros at (0,0) and (1*maxveltime, 0)
func vel(x: float):
	var a = -maxspeed/(maxveltime*maxveltime)
	var b = maxspeed/maxveltime
	return a*pow(x,2) + 2*b*x
	

func fortitude(four : int, vector : Vector2):
	if four == 0 or four == 1:
		return vector.x
	elif four == 2 or four == 3:
		return vector.y
	else:
		return "you're gay"

# Function void float do_the_delta_input_thing(float delta)
# Sets global variabl rldu[i] based on previous values and the total time delta.
# If input is depressed, rldu[i] is set to the amount of seconds since the beginning of depression,
# until x = 1, at which the velocity stays at v(1) until the input is released.
# Once input is released, rdlu[i] is multiplied by -1 and progressively added to until zero.
# This is for deacceleration purposes.
func do_the_delta_input_thing(delta):
	inputvec  = Vector2(-Input.get_action_strength("left")+Input.get_action_strength("right"), -Input.get_action_strength("up")+Input.get_action_strength("down")).normalized()
	
	if inputvec == Vector2.ZERO:
		if velocity.length() > acceleration*delta:
			velocity -= velocity.normalized()*acceleration*delta*11/16
		else:
			velocity = Vector2.ZERO
	else:
		velocity += inputvec*acceleration*delta*2
		if velocity.length() > maxspeed:
			velocity = velocity.normalized() * maxspeed
	
	if Input.get_action_strength("neutral special"):
		firing = true
	else:
		firing = false
	if Input.is_action_just_pressed("neutral special"):
		moment_firing = framecount
	exit_goo = false
	

# Function void gunner_thingy()
# Currently fires bullets at a rate of four times per second. fps variable is the frames per second, derived
# from delta. If the fifteen frame modulos of the current framecount and the moment_firing are equal,
# then instantiate one bullet and add it to the root node in the main class. Also set the transform plane
# to be equal to Durdan's (gun's) transform plane at that moment.
func gunner_thingy(delta):
	var fps = int(1/delta)
	if firing and (int(framecount) % (fps/4))-(int(moment_firing) % (fps/4)) == 0:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = $gunner.global_transform

# Function void damage_thingy(float damage)
# Called by bullets to deal damage to the player. Simply decreases the health of the player and emits the
# you_died signal if the health drops at or below zero, which functionally kills the player.
func damage_thingy(damage):
	health -= damage
	if health <= 0:
		health = 0
		emit_signal("you_died", true)

func hazard_thingy():
	if in_goo:
		maxspeed = maxsped*0.5
	elif !in_goo:
		maxspeed = maxsped
		
func on_Goo_body_exited(body : Node2D):
	if body != self:
		return
	exit_goo = true

# Function void _input(InputEvent event)
# Called every time an input occurs. Here it is used to detect if the keyboard and mouse or controller
# is the main input option to be able to switch between mouse aiming and right joystick aiming.
func _input(event : InputEvent):
	if(event is InputEventKey or event is InputEventMouseButton):
		using_mouse = true
	elif(event is InputEventJoypadButton or event is InputEventJoypadMotion):
		using_mouse = false

# Function void _physics_process(float delta)
# deltatime is total time since session open, mousepos is the mouse position
# Calls do_the_delta_input_thing() to set rldu[i]
# objposition and objrotation get Durdans position and rotation respectively
# mousepolar is the degree version of the polar coordinates of mousepos
# Then internal velocity is set to accel_thingy and then move and slide is called.
# If the player is using the mouse, the rotation is set to the angle in mousepolar.
# Else if the player is using the controller, the rotation is set to the angle of
# flick_stick(). If this value is nan, the rotation stays the same as the previous
# frame. The current rotation is then stored in previous_rotation.
func _physics_process(delta):
	
	hazard_thingy()
	deltatime += delta
	framecount += 1
	
	var mousepos = get_viewport().get_mouse_position()
	
	
	var objposition = self.get_position()
	var objrotation = self.get_rotation_degrees()
	var mousepolar = polar_rad_to_deg(cart_to_polar_from_object(mousepos, objposition))
	
#	hazard_thingy()
	if using_mouse:
		look_at(get_global_mouse_position())
	elif !using_mouse:
		if (is_nan(polar_rad_to_deg(flick_stick()).y)):
			self.set_rotation_degrees(previous_rotation)
		else:
			self.set_rotation_degrees(polar_rad_to_deg(flick_stick()).y)
			
	do_the_delta_input_thing(delta)
	
	move_and_slide()
	gunner_thingy(delta)
	previous_rotation = rotation_degrees
