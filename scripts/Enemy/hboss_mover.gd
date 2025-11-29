extends Timer
class_name HBossMover

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var hboss : CharacterBody2D
@export var left : Sprite2D
@export var right : Sprite2D
@export var fire : HBossFire
@export var player : Player
enum MoveStates {
	NOT,
	LEFT,
	RIGHT
}

var move_state : MoveStates = MoveStates.NOT:
	set(new_state):
		move_state = new_state
		if move_state == MoveStates.LEFT:
			hboss.global_position = left.global_position
		elif move_state == MoveStates.RIGHT:
			hboss.global_position = right.global_position
	get:
		return move_state
signal did_move(state : MoveStates)
var starting_rotation : float
var is_rotating : bool
var angle_to_rotate : float
var time_to_rotate : float
var rotate_lerp_weight : float
var is_rotating_to_player : bool = false
var is_facing_player : bool = false
var is_lerping_gun : bool = false

signal sig_done_rotating()
signal sig_facing_player()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#timeout.connect(_on_timeout)
	wait_time = 1.0
	start()
	hboss.position = left.position
	move_state = MoveStates.LEFT

func _on_timeout():
	stop()
	start()

func flip():
	hboss.rotation = hboss.rotation + PI/2

func rotate_cw():
	hboss.rotation = hboss.rotation + PI/4

func rotate_ccw():
	hboss.rotation = hboss.rotation - PI/4

func cue_movement():
	start()
	await timeout
	stop()
	if move_state == MoveStates.LEFT: move_state = MoveStates.RIGHT
	elif move_state == MoveStates.RIGHT: move_state = MoveStates.LEFT

func lerp_gun_adjust():
	pass

# ROTATION


# Initiates a rotation, taking in the angle and the time the rotation should take and setting their
#		respective parameters.
func rotate_to(angle : float, time : float) -> void:
	starting_rotation = hboss.get_rotation()
	is_rotating = true
	angle_to_rotate = angle
	time_to_rotate = time
	await sig_done_rotating

# Called when the enemy is rotating for any reason.
# If the enemy is rotating for a firing behavior: calculate the amount of weight to change per frame.
#		Then change that weight and set the rotation to a lerping between the starting rotation and
#		the new rotation. If the lerp is over, reset all the variables and stop rotating.
# Else if the enemy is rotating towards the player: lerp based on delta itself and lerp the enemy
#		rotation thataway. If the lerp is over, reset all the variables and stop rotating.
func thingy_rotate(delta : float) -> void:
	if is_rotating_to_player:
		rotate_lerp_weight += delta*2
		hboss.rotation = lerp_angle(fmod(starting_rotation,2*PI), (player.global_position-hboss.global_position).angle(), rotate_lerp_weight)
	else:
		var weightperframe : float = delta*(angle_to_rotate/time_to_rotate)/angle_to_rotate
		rotate_lerp_weight += weightperframe
		hboss.rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation+angle_to_rotate,2*PI), rotate_lerp_weight)
		if rotate_lerp_weight > 1.0 or is_equal_approx(rotate_lerp_weight, 1.0):
			rotate_lerp_weight = 0.0
			is_rotating = false
			angle_to_rotate = 0
			time_to_rotate = 0
			if is_rotating_to_player:
				sig_facing_player.emit()
				return
			sig_done_rotating.emit()

# Rotates the enemy back to the player. Uses the same process as rotate_to but uses specific
#		signals and flags.
func back_to_player() -> void:
	is_rotating_to_player = true
	is_rotating = true
	time_to_rotate = 0.5
	starting_rotation = hboss.get_rotation()
	await sig_facing_player
	is_facing_player = true
	is_rotating_to_player = false

# This function is called by the enemy every frame. It first sets the state of the function, then
#		checks if the enemy needs to wander or return to the player. Then, it faces the player, rotates
#		the enemy, calls the current_action and sets the velocity, and/or stops the enemy for firing if
#		applicable.
func tick(delta : float) -> void:
	#thingy_set_state()
	#if move_state == MoveStates.WANDER:
		#if is_in_wandering_process == false: 
			#wander()
	#elif move_state == MoveStates.ENDWANDER: back_to_player()
	if is_facing_player:
		hboss.look_at(player.position)
	if is_rotating:
		thingy_rotate(delta)
	#if current_action:
		#enemy.velocity = Callable(self, current_action).call()
	#if is_stoppedf:
		#enemy.velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
