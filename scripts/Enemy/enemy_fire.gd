extends Timer
class_name EnemyFire

# Basic Enemy Firing Script: Part of SinEStR 3.1
#
# Object:
# Implements a deterministic firing behavior based on the state of the enemy while also making it 
# easy to add more behaviors if desired.


# IMPORTS

var enemy : Enemy
var gun : Gun
var mover : EnemyMover
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# STATUS VARIABLES

var current_action : String = "none"

# INITIALIZATION

# Nothing special, just initializes the parameters
# enemy is needed to get the starting_rotation
# gun is needed to fire
# mover is needed for rotations and stopping
func _init(e_ : Enemy, g_ : Gun, m_ : EnemyMover) -> void:
	enemy = e_
	gun = g_
	mover = m_

# Just onreadying the function, connecting signals and initially starting the timer.
func _ready() -> void:
	timeout.connect(_on_timeout)
	wait_time = rng.randf_range(1.6, 2.4)
	start()


# SIGNAL FUNCTIONS

# signal timeout(): The main driving force. This function sets the current_action based on the
#		move_state and random chance, then restarts the timer.
func _on_timeout() -> void:
	stop()
	if mover.move_state == mover.MoveStates.APPROACH:
		match mover.is_player_ccw():
			true: await ccw_sprinkler()
			false: await cw_sprinkler()
	elif mover.move_state == mover.MoveStates.STOP:
		match rng.randi_range(0,2):
			0: await doubles()
			1: await singles()
			2: await box_in()
	elif mover.move_state == mover.MoveStates.SEEK:
		await ccw_sprinkler()
	current_action = "none"
	wait_time = rng.randf_range(1.0, 2.0)
	start()


# FIRING BEHAVIORS

# Behavior box_in(): sends three bullets on one side, three bullets on the other, and three bullets
#		at the player.
func box_in() -> void:
	current_action = "box_in"
	mover.is_facing_player = false
	await mover.rotate_to(0.5, 0.125)
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await mover.rotate_to(-1.0, 0.125)
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await mover.rotate_to(0.5, 0.125)
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await get_tree().create_timer(0.1).timeout
	gun.fire()
	await mover.back_to_player()


# Behavior cw_sprinkler: Fires 8 bullets in a clockwise manner in a sprinkler fashion.
func cw_sprinkler() -> void:
	current_action = "cw_sprinkler"
	mover.is_stoppedf = true
	mover.is_facing_player = false
	mover.starting_rotation = enemy.get_rotation()
	await mover.rotate_to(-0.25, 0.25)
	for i in range(0,8):
		gun.fire()
		await mover.rotate_to(0.5, 0.125)
	await mover.back_to_player()
	mover.is_stoppedf = false

# Behavior ccw_sprinkler: Fires 8 bullets in a counterclockwise manner in a sprinkler fashion.
func ccw_sprinkler() -> void:
	current_action = "ccw_sprinkler"
	mover.is_stoppedf = true
	mover.is_facing_player = false
	var i = 0
	mover.starting_rotation = enemy.get_rotation()
	await mover.rotate_to(0.25, 0.25)
	while i < 8:
		gun.fire()
		await mover.rotate_to(-0.5, 0.125)
		i += 1
	await mover.back_to_player()
	mover.is_stoppedf = false



# Behavior doubles: Fires 7 sets of two bullets while facing the player.
func doubles() -> void:
	current_action = "doubles"
	mover.is_stoppedf = true
	for i in range(0,7):
		mover.is_facing_player = false
		gun.fire()
		await get_tree().create_timer(0.1).timeout
		gun.fire()
		await get_tree().create_timer(0.5).timeout
		mover.back_to_player()
	mover.is_stoppedf = false

# Behavior singles: Fires 10 bullets while facing the player.
func singles() -> void:
	current_action = "singles"
	for i in range(0,10):
		gun.fire()
		await get_tree().create_timer(0.6).timeout
