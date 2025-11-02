extends CharacterBody2D

# Object: Simple enemy script that moves enemies at a linear speed and fires volleys at Durdan. May increase in complexity
# 	in the future

# Global Variables:
# CharacterBody2D player: Pointer to the root Durdan node in the main scene.
# PackedScene Bullet: Pointer to the bullet scene.
# ProgressBar healthbar : Literally the healthbar of the enemy
# float speed: Fixed speed for every enemy.
# float bulletscale: Scale for each bullet the enemy shoots.
# float stoppingdist: The minimum distance between the enemy and the player. Enemy stops closer to this distance.
# int shotsps: The enemy's firing rate. Should probably be lower than the players.
# Vector2 playerlastpos: The players position from the previous frame. Not used for anything at the moment.
# bool firing: Set to true if the enemy is firing.
# float moment_firing: Temporary push helper variable that helps with calculating delay in consecutive shots.
# int framecount: Number of frames since session began.
# float health: Total health of the enemy in percent. Always preset to 100.
# float scle: The relative damage the enemy takes to a bullet.
#
# Functions:
# void _ready(): called right off the bat. Currently does nothing useful.
# Vector2 cart_to_polar_from_object(Vector2 coords, Vector2 obj): returns polar coordinates of coords with obj as the origin.
# Vector2 polar_rad_to_deg(float rads): returns polar coordinates rads with the phi part in degrees. Helper function.
# float dist(float x, float y): returns the distance formula (pythagoras based) given x and y coordinates.
# float accel_thingy(): returns the end velocity vector for the enemy
# void gunner_thingy(float delta): instantiates bullets at a set interval. Functionally the same as the player's,
# 	but with scale
# void damage_thingy(float damage): Decreases the health of the enemy and unalives it at 0
# void health_thingy(): Handles the healthbar.
# void _physics_process(): updates the physics and bullets every frame

var player : CharacterBody2D

@export var Bullet : PackedScene = preload("res://scenes/Other Things/bullet.tscn")

@onready var healthbar : ProgressBar = $healthbar

@export var maxsped : float = 200
@export var bulletscale : float = 0.65
@export var stoppingdist : float = 200.0
@export var shotsps : int = 4

@onready var raycasts : Node2D = get_node("../EnemySoul/RayCasts")

var playerlastpos : Vector2
var firing : bool = false
var moment_firing : float = 0
var framecount : int = 0
var health : float = 100
var scle : float = 0.2
var in_goo : bool = false
var speed = maxsped
var redirect : bool = false
var target : Node2D

var tempvar : Vector2

# Function void _ready()
# Does nothing but resets already declared variables. May change in the future.
func _ready():
	tempvar = $gunner.global_position

func readyy():
	firing = true
	moment_firing = 0

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

# Function Vector2 polar_rad_to_deg(Vector2 rads)
# Returns Vector2 with same polar coords and converted phi rads into degrees
func polar_rad_to_deg(rads: Vector2):
	return Vector2(rads.x, rads.y*(180/PI))

# Function float dist(float x, float y)
# Returns the pythagorean distance between two points, e.g. square root of
# x squared plus y squared.
func dist(x : float, y : float):
	return sqrt(pow(x, 2)+pow(y, 2))

# Function Vector2 accel_thingy()
# Returns the final velocity vector for the enemy. Calculates the distance between the enemy and Durdan
# and then the vector pointing from the enemy to Durdan at the magnitude speed. If the distance is between
# 200 and 195, the enemy has no velocity (aka stops), and if the distance is less than 195, the direction
# is negated (i.e. backwards). This direction is then returned.
func accel_thingy():
	var distance = dist(self.global_position.x-target.global_position.x, self.global_position.y-target.global_position.y)
	var dir = (target.global_position - self.global_position).normalized()*speed
#	var dir = (target.global_position - self.global_position).normalized()*speed if target == player else (target.global_position - self.global_position).normalized()*speed*2
#	if distance <= stoppingdist and distance >= stoppingdist-5 and target == player:
#		return Vector2(0,0)
#	elif distance < stoppingdist-5 and target == player:
#		return -dir
#	else:
#		return dir
		
# Function void gunner_thingy(float delta)
# Functions nearly the same as the player gunner_thingy script. Shoots to where the gun is pointing, i.e. Durdan.
# Fires bullets at a rate of shotps times per second. fps variable is the frames per second, derived from delta. 
# If the shot frame interval frame modulos of the current framecount and the moment_firing are equal, then 
# instantiate one bullet and add it to the root node in the main class. Also set the transform plane to be equal
# to enemy's (gun's) transform plane at that moment, then gives a scale to the bullet to make it look like Durdan's.
func gunner_thingy(delta):
	var fps = int(1/delta)
	if firing and (framecount % (fps/shotsps))-(int(moment_firing) % (fps/shotsps)) == 0:
		var b = Bullet.instantiate()
		get_tree().get_root().get_node("Game").add_child(b)
		# "global_transform" fixed infamous out of place bug
		b.global_transform = $gunner.global_transform
		b.scale = Vector2(bulletscale, bulletscale)
# Function void damage_thingy(float damage)
# Called by bullets. Decreases the health of the enemy and unalives it once health reaches zero.
func damage_thingy(damage : float):
	health -= damage
	if health <= 0:
		get_parent().queue_free()
		queue_free()

# Function void health_thingy()
# Handles the health bar appearing near enemies. The value of the health bar is set to the health. The health bar
# is hidden when the enemy is at full health and shown in all other cases.
func health_thingy():
	healthbar.value = health
	if health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func hazard_thingy():
	if in_goo:
		speed = maxsped*0.5



func go_around():
	pass

# Function void _physics_process(float delta)
# Called every frame. Sets the velocity to accel_thingy() and moves the object at that velocity. The enemy then shoots
# at the player, updates the health bar, moves and slides, and then sets playerlastposition to the current position 
# of the player for the next frame.
func _physics_process(delta):
	framecount += 1
	look_at(target.global_position)
	the_important_stuff(delta)
	
	
func the_important_stuff(delta):
	hazard_thingy()
	velocity = accel_thingy()
	gunner_thingy(delta)
	health_thingy()
	move_and_slide()
	playerlastpos = player.position
