extends Timer
class_name EnemyMover

# Basic Enemy Firing Script: Part of SinEStR 3.1
#
# Object
# Basic enemy movement based on the paper "Steering Behaviors for Autonomous Characters" by Craig 
# Reynolds, presented at GDC 1999. Implements a non-deterministic steering behavior that is roughly
# based on how far the enemy is away from the player, while wandering when the player breaks line
# of sight.
#

# IMPORTS

var player : Player
var enemy : Enemy
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# CONSTANTS

var MAX_SPEED : float



# FLAGS

# is_rotating_to_player: true when the enemy is rotating back to the player
# is_facing_player: true when the enemy is facing the player
# is_stopped: true when the enemy must stop
# is_rotating: true when the enemy is rotating and not facing the player.
# is_in_wandering_process: true when the enemy is wandering or endwandering.
# is_strictly_wandering: true when the enemy is wandering, used to break the wandering loop.

var is_rotating_to_player : bool = false
var is_facing_player : bool = true
var is_stopped : bool = false
var is_rotating : bool = false
var is_in_wandering_process : bool = false
var is_strictly_wandering : bool = false


# STATUS VARIABLES

# Vector2 velocity: Internal velocity variable that is not connected to the enemy.velocity. Pretty
#		much the same though.
var velocity : Vector2

# These four variables are used by rotate_to() to set the parameters for the next rotation.
# starting_rotation is the rotation the enemy is at when the rotation begins.
# angle_to_rotate is the angle (in radians) for the enemy to rotate.
# time_to_rotate is the time (in secondes) it should take for the enemy to complete it.
# rotate_lerp_weight is the weight on the lerp between the starting rotation and ending one.
var starting_rotation : float
var angle_to_rotate : float
var time_to_rotate : float
var rotate_lerp_weight : float

# String current_action: This is the current movement behavior of the enemy in string form, used to
# call the cooresponding function.
var current_action : String

# MoveStates move_state: The current behavior state of the enemy. Currently either SEEK, STOP, FLEE,
# or PEEK. SEEK moves the enemy towards the player, STOP stops the enemy, and FLEE moves the enemy
# away from the player.
var move_state : MoveStates = 0





# SIGNALS

# sig_done_rotating(): Emitted when the set rotation is done.
# sig_facing_player(): Emitted when the face player rotation is done.
# sig_movement_override(): Emitted when the movement needs to be reconsidered, like a close encounter.
signal sig_done_rotating()
signal sig_facing_player()
signal sig_movement_override()

# enum MoveStates: The states that govern the behavior of the enemy. They do not dictate the
#		behavior but merely create bounds for suggestions, except wander which tells the enemy to
#		wander and endwander which returns him back to the player.
enum MoveStates {
	SEEK,
	APPROACH,
	STOP,
	FLEE,
	STRAFE,
	WANDER,
	ENDWANDER
}


# INITIALIZATION


# Nothing special, just initializes the parameters
# player is needed for seeking and fleeing
# enemy is needed to adjust the enemy's velocity
# MAX_SPEED is needed to actually move the thing.
func _init(e_ : Enemy, p_ : Player, s_ : float) -> void:
	player = p_
	enemy = e_
	MAX_SPEED = s_

# Just onreadying the function, connecting signals and initially starting the timer.
func _ready() -> void:
	timeout.connect(_on_timeout)
	wait_time = rng.randf_range(1.6, 2.4)
	start()


# SIGNAL CALLBACKS

# signal timeout(): The main driving force. This function sets the current_action based on the
#		move_state and random chance, then restarts the timer.
func _on_timeout() -> void:
	stop()
	wait_time = rng.randf_range(1.0, 2.0)
	var random : int = 0
	match move_state:
		MoveStates.APPROACH:
			random = rng.randi_range(1,2)
			if random == 1: current_action = "strafe_left"
			elif random == 2: current_action = "strafe_right"
		MoveStates.STOP:
			current_action = "cease"
		MoveStates.FLEE:
			current_action = "away_from_player"
	start()
	


# BEHAVIORS


# Behavior to_player: Move towards the player in a seeking way.
func to_player() -> Vector2:
	var desired_velocity = (player.position-enemy.position).normalized() * MAX_SPEED
	velocity += (desired_velocity-velocity)
	return velocity

# Behavior away_from_player: Move away from the player in a fleeing way.
func away_from_player() -> Vector2:
	var desired_velocity = -(player.position-enemy.position).normalized() * MAX_SPEED
	velocity += (desired_velocity-velocity)
	return velocity


# Behavior strafe_right: Move towards the player at a 45 degree angle right.
func strafe_right() -> Vector2:
	velocity = (player.position-enemy.position).rotated(PI/4).normalized()*MAX_SPEED
	return velocity

# Behavior strafe_left: Move towards the player at a 45 degree angle left.
func strafe_left() -> Vector2:
	velocity = (player.position-enemy.position).rotated(-PI/4).normalized()*MAX_SPEED
	return velocity

# Behavior cease: Stop. Called cease because stop is taken by Timer.
func cease() -> Vector2:
	velocity = Vector2.ZERO
	return velocity




# wander: Not entirely a behavior, but called when the enemy is out of LoS from the player. Chooses
#		a random angle and goes that direction for 9-11 seconds, then chooses a different angle and 
#		repeats.
# HOW THE WANDER PROCESS WORKS:
# is_in_wandering_process encompasses both wandering and endwandering, used to define when the
#		function is endwandering and how to keep that process.
# is_strictly_wandering is only true if this function is running, i.e., MoveStates.WANDER, and is
#		used for the loop
# The function is protected by the is_in_wandering flag to only run once and does what the description
#		says.
# ENDWANDER is triggered immediately after wander when the player enters line of sight, which skips
#		the WANDER return in set_state() and 
func wander() -> void:
	is_in_wandering_process = true
	is_strictly_wandering = true
	is_facing_player = false
	while is_strictly_wandering:
		var angle = rng.randf_range(1, 2*PI)
		await rotate_to(angle, 0.5)
		velocity = Vector2.RIGHT.rotated(enemy.get_rotation())*MAX_SPEED/4
		enemy.velocity = velocity
		await get_tree().create_timer(rng.randf_range(9,11)).timeout


# ROTATION


# Initiates a rotation, taking in the angle and the time the rotation should take and setting their
#		respective parameters.
func rotate_to(angle : float, time : float) -> void:
	starting_rotation = enemy.get_rotation()
	is_rotating = true
	angle_to_rotate = angle
	time_to_rotate = time
	await sig_done_rotating


# Rotates the enemy back to the player. Uses the same process as rotate_to but uses specific
#		signals and flags.
func back_to_player() -> void:
	enemy.velocity = Vector2.ZERO
	is_rotating_to_player = true
	is_rotating = true
	time_to_rotate = 0.5
	starting_rotation = enemy.get_rotation()
	await sig_facing_player
	is_facing_player = true
	is_rotating_to_player = false
	is_in_wandering_process = false
	if move_state == MoveStates.ENDWANDER: move_state = MoveStates.SEEK

# Called when the enemy is rotating for any reason.
# If the enemy is rotating for a firing behavior: calculate the amount of weight to change per frame.
#		Then change that weight and set the rotation to a lerping between the starting rotation and
#		the new rotation. If the lerp is over, reset all the variables and stop rotating.
# Else if the enemy is rotating towards the player: lerp based on delta itself and lerp the enemy
#		rotation thataway. If the lerp is over, reset all the variables and stop rotating.
func thingy_rotate(delta : float) -> void:
	if is_rotating_to_player:
		rotate_lerp_weight += delta*2
		enemy.rotation = lerp_angle(fmod(starting_rotation,2*PI), (player.global_position-enemy.global_position).angle(), rotate_lerp_weight)
	else:
		var weightperframe : float = delta*(angle_to_rotate/time_to_rotate)/angle_to_rotate
		rotate_lerp_weight += weightperframe
		enemy.rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation+angle_to_rotate,2*PI), rotate_lerp_weight)
	if rotate_lerp_weight > 1.0 or is_equal_approx(rotate_lerp_weight, 1.0):
		rotate_lerp_weight = 0.0
		is_rotating = false
		angle_to_rotate = 0
		time_to_rotate = 0
		if is_rotating_to_player:
			sig_facing_player.emit()
			return
		sig_done_rotating.emit()



# MAGIC


# Sets the appropriate state for the enemy based on perceived conditions.
# If the player is farther than 800 units away, switch state to seek. If the player is between 800
# and 500, switch to approach. If the player is between 500 and 200, switch to stop. If the player
# is not in LoS, wander instead, and if the player has just met line of sight, end the wander.
func thingy_set_state() -> void:
	var distance : float = (player.position-enemy.position).length()
	if enemy.player_raycast.get_collider() != player and enemy.player_raycast.get_collider():
		print(enemy.player_raycast.get_collider())
		move_state = MoveStates.WANDER
		return
	elif (player.position-enemy.position).length() > 800:
		move_state = MoveStates.SEEK
	elif (distance < 800) and (distance > 500):
		move_state = MoveStates.APPROACH
	elif (distance < 500) and (distance > 200):
		move_state = MoveStates.STOP
		if current_action == "away_from_player": sig_movement_override.emit()
	elif distance < 195:
		move_state = MoveStates.FLEE
		sig_movement_override.emit()
	if is_in_wandering_process == true:
		move_state = MoveStates.ENDWANDER
	is_strictly_wandering = false





# This function is called by the enemy every frame. It first sets the state of the function, then
#		checks if the enemy needs to wander or return to the player. Then, it faces the player, rotates
#		the enemy, calls the current_action and sets the velocity, and/or stops the enemy for firing if
#		applicable.
func tick(delta : float) -> void:
	thingy_set_state()
	if move_state == MoveStates.WANDER:
		if is_in_wandering_process == false: 
			wander()
	elif move_state == MoveStates.ENDWANDER: back_to_player()
	if is_facing_player:
		enemy.look_at(player.position)
	if is_rotating:
		thingy_rotate(delta)
	if current_action:
		enemy.velocity = Callable(self, current_action).call()
	if is_stopped:
		enemy.velocity = Vector2.ZERO
	


# AUXILLIARY FUNCTIONS

# Helper function to debug the move_state
func get_move_state() -> String:
	return MoveStates.keys()[move_state]

# Determines whether or not the player is moving counterclockwise around the enemy. Uses the cross
# product to do it.
func is_player_ccw() -> bool:
	var vel = player.velocity
	var ptr = player.global_position-enemy.global_position
	return true if vel.cross(ptr) > 0 else false
