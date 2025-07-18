extends CharacterBody2D
class_name Enemy

# Base Enemy Running Script (3.0): Sinful Enemy Stablizing and Running Script Plus Peek (SinEStR+P)
#
# Object:
# Basic enemy movement based on the paper "Steering Behaviors for Autonomous Characters" by Craig 
# Reynolds, presented at GDC 1999. Implements a seeking steering behavior at distances larger than 
# 200 units, stopping when reaching ~200 units, and fleeing when closer than 200 units. Also
# implements an admittedly robotic peeking behavior based on a "breadcrumb system."
#
# TODO: implement firing and wandering.
#
# Node Structure:
# CharacterBody2D enemy
# |_ enemyCollider: CollisionShape2D for the enemy.
# |_ enemyHealthBar: Mini health ProgressBar for the enemy.
# |_ enemySprite: Sprite2D for the enemy.
# |_ enemyNeutralSpecialSprite: Sprite2D for the enemy's gun.
#    |_ gunner: Marker2D to mark where bullets should be instantiated.
# |_ enemyAuraDetection: Node2D that uses RayCast2Ds to detect player aura.
#    |_ RayCast2D x16
# |_ toPlayer: RayCast2D pointing at player to detect whether or not the enemy is in eyeshot.
#
# GLOBAL VARIABLES
#
# CharacterBody2D player: Pointer to the player.
@export var player : CharacterBody2D

# PackedScene Bullet: The packaged scene for the bullet that is to be fired.
@export var Bullet : PackedScene = preload("res://scenes/Other Things/bullet.tscn")

# RandomNumberGenerator rng: A random number generator to make this thing more deterministic. 
# Currently unused.
var rng = RandomNumberGenerator.new()

# float max_speed: The maximum speed of the enemy under normal conditions
var max_speed : float = 200

# float current_max_speed: The current maximum speed of the enemy under present conditions,
# based on the maximum speed under normal conditions.
var current_max_speed : float = max_speed

# MoveStates move_state: The current behavior state of the enemy. Currently either SEEK, STOP, FLEE,
# or PEEK. SEEK moves the enemy towards the player, STOP stops the enemy, and FLEE moves the enemy
# away from the player.
var move_state : MoveStates = 0

# bool in_goo: Whether or not the enemy is stuck in goo, slowing it down.
var in_goo : bool = false

# float health: The current health of the enemy, in percent.
var health : float = 100.0

# bool[16] el_megalist: Array of whether or not each RayCast2D in $enemyAuraDetection is colliding
# with an active auraDot.
var el_megalist = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]

# Script GOAT: Used to determine whether or not the collider of a RayCast2D in $enemyAuraDetection
# is actually an auraDot. Probably a better way to do it ngl.
var GOAT = preload("res://scripts/dot.gd")

var neighbor_enemies = []

var framecounter : int = 0
var fac_player = false

var scle = 5
var toime = 0

var face_player = true
var target_location = Vector2.ZERO
var wander_fp = false
var stopped = false
var current_action

# ENUMERATIONS


signal fire_tick()
signal facing_player()
signal wander_tick()
signal override()

# enum States: The states that govern the behavior of the enemy. Currently, only seek (move towards
# player), stop (don't move), flee (move away from player), and peek (look for player if he is 
# close), have been implemented.
enum MoveStates {
	SEEK,
	APPROACH,
	STOP,
	FLEE,
	STRAFE,
	WANDER,
	ENDWANDER
}

var angel
var tyme
var gun_elapsed = 0.0

var starting_rotation
var rotating = false
var illinois = false
var wandering = false
var movebool = false
var currently = false
var overrided = false


# SIGNAL FUNCTIONS




# Called when the node enters the scene tree for the first time.
func _ready():
	#$enemyNeighborhood.connect("area_entered", _on_enemyNeighborhood_body_entered)
	#$enemyNeighborhood.connect("area_exited", _on_enemyNeighborhood_body_exited)
	$enemyStateTimer.connect("timeout", _on_enemyStateTimer_timeout)
	$enemyStateTimer.wait_time = rng.randf_range(1,3)
	$enemyStateTimer.start()
	$enemyGunTimer.connect("timeout", _on_enemyGunTimer_timeout)
	$enemyGunTimer.wait_time = rng.randf_range(1.6, 2.4)
	$enemyGunTimer.start()
	$enemyMoveTimer.connect("timeout", _on_enemyMoveTimer_timeout)
	$enemyMoveTimer.wait_time = rng.randf_range(1.6, 2.4)
	$enemyMoveTimer.start()
	$enemyNeutralSpecialSprite/noGunZone.body_entered.connect(_on_noGunZone_body_entered)
	$enemyNeutralSpecialSprite/noGunZone.body_exited.connect(_on_noGunZone_body_exited)
	$enemyNeighborhood.body_entered.connect(_on_wall_close)
	$enemyNeighborhood.body_entered.connect(_on_wall_far)
	override.connect(_on_enemyMoveTimer_timeout)

func _on_wall_close(body):
	stopped = true
	print('oaije[rpqf]')

func _on_wall_far(body):
	stopped = false

func _on_noGunZone_body_entered(body):
	illinois = true

func _on_noGunZone_body_exited(body):
	illinois = false



# STATE FUNCTIONS


# STEERING BEHAVIORS


# Steers the enemy towards the player. First calculates the desired direct velocity limited with
# respect to the maximum speed, then subtracts velocity from it to produce the desired change in
# velocity. Called while in SEEK state.
func seek():
	var desired_velocity = (player.position-position).normalized() * max_speed
	velocity += (desired_velocity-velocity)

# Stops the enemy. Called while in STOP state.
func stop():
	velocity = Vector2.ZERO

func strafe():
	velocity = (player.position-position).rotated(PI/2).normalized()*max_speed/2

# void flee(void): Steers the enemy away from the player. First calculates the desired direct
# velocity limited with respect to the maximum speed pointing directly away from the player, then
# subtracts velocity from it to produce the desired change in velocity. Called while in FLEE state.
func flee():
	var desired_velocity = -(player.position-position).normalized() * (max_speed/2)
	velocity += (desired_velocity-velocity)

func wander():
	wandering = true
	currently = true
	face_player = false
	while currently:
		var angle = rng.randi_range(1, 360)
		await rotate_to(angle, 0.5)
		velocity = Vector2.RIGHT.rotated(get_rotation())*max_speed/4
		await get_tree().create_timer(rng.randf_range(9,11)).timeout

# Approaches the enemy
func approach():
	var desired_velocity = (player.position-position).normalized() * max_speed
	velocity += (desired_velocity-velocity)




# FIRING BEHAVIORS

func box_in():
	face_player = false
	await rotate_to(0.5, 0.125)
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await rotate_to(-1.0, 0.125)
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await rotate_to(0.5, 0.125)
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await get_tree().create_timer(0.1).timeout
	thingy_fire()
	await back_to_player()

func cw_sprinkler():
	stopped = true
	face_player = false
	starting_rotation = get_rotation()
	await rotate_to(-0.25, 0.25)
	for i in range(0,8):
		thingy_fire()
		await rotate_to(0.5, 0.125)
	await back_to_player()
	stopped = false

func ccw_sprinkler():
	stopped = true
	face_player = false
	var i = 0
	starting_rotation = get_rotation()
	await rotate_to(0.25, 0.25)
	while i < 8:
		thingy_fire()
		await rotate_to(-0.5, 0.125)
		i += 1
	await back_to_player()
	stopped = false

func back_to_player():
	fac_player = true
	rotating = true
	tyme = 0.5
	starting_rotation = get_rotation()
	await facing_player
	face_player = true
	fac_player = false
	wandering = false
	if move_state == MoveStates.ENDWANDER: move_state = MoveStates.SEEK

func rotate_to(angle, time):
	starting_rotation = get_rotation()
	rotating = true
	angel = angle
	tyme = time
	await fire_tick

func thingy_rotate(delta):
	if fac_player:
		gun_elapsed += delta*2
		rotation = lerp_angle(fmod(starting_rotation,2*PI), (player.global_position-global_position).angle(), gun_elapsed)
	else:
		var angleperframe = delta*(angel/tyme)
		var weightperframe = angleperframe/angel
		gun_elapsed += weightperframe
		rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation+angel,2*PI), gun_elapsed)
	if gun_elapsed > 1.0 or is_equal_approx(gun_elapsed, 1.0):
		gun_elapsed = 0.0
		rotating = false
		angel = 0
		tyme = 0
		if fac_player:
			facing_player.emit()
			return
		fire_tick.emit()

func is_player_ccw():
	var vel = player.velocity
	var ptr = player.global_position-global_position
	return true if vel.cross(ptr) > 0 else false

func doubles():
	stopped = true
	for i in range(0,7):
		face_player = false
		thingy_fire()
		await get_tree().create_timer(0.1).timeout
		thingy_fire()
		await get_tree().create_timer(0.5).timeout
		back_to_player()
	stopped = false

func singles():
	for i in range(0,10):
		thingy_fire()
		await get_tree().create_timer(0.6).timeout


# DO SOMETHING FUNCTIONS (that aren't state-based)


func _on_enemyStateTimer_timeout():
	pass
#	$enemyStateTimer.stop()
#	$enemyStateTimer.wait_time = rng.randf_range(1, 3)
#	$enemyStateTimer.start()


func _on_enemyGunTimer_timeout():
	$enemyGunTimer.stop()
	if move_state == MoveStates.APPROACH:
		match is_player_ccw():
			true: await ccw_sprinkler()
			false: await cw_sprinkler()
	elif move_state == MoveStates.STOP:
		match rng.randi_range(0,2):
			0: await doubles()
			1: await singles()
			2: await box_in()
	$enemyGunTimer.wait_time = rng.randf_range(1.0, 2.0)
	$enemyGunTimer.start()

func _on_enemyMoveTimer_timeout():
	$enemyMoveTimer.stop()
	$enemyMoveTimer.wait_time = rng.randf_range(1.0, 2.0)
	var roll = 0
	match move_state:
		MoveStates.APPROACH:
			roll = rng.randi_range(1,2)
			if roll == 1: current_action = "strafeleft"
			elif roll == 2: current_action = "straferight"
		MoveStates.STOP:
			current_action = "stop"
		MoveStates.FLEE:
			current_action = "awayfromplayer"
		
	$enemyMoveTimer.start()





func toplayer():
	var desired_velocity = (player.position-position).normalized() * max_speed
	velocity += (desired_velocity-velocity)

func awayfromplayer():
	var desired_velocity = -(player.position-position).normalized() * max_speed
	velocity += (desired_velocity-velocity)

func straferight():
	velocity = (player.position-position).rotated(PI/4).normalized()*max_speed
func strafeleft():
	velocity = (player.position-position).rotated(-PI/4).normalized()*max_speed



# Sets the appropriate state for the enemy based on preconceived conditions.
# If the player is farther than 200 units away, switch state to seek. If the player is around 200 
# units away, switch state to stop, and if the player is under 200 units away, switch state to flee.
# These are all while the player maintains line of sight. If not, switch state to peek.
func set_state():
	if move_state == MoveStates.ENDWANDER:
		move_state = MoveStates.ENDWANDER
	elif $toPlayer.get_collider() != player:
		move_state = MoveStates.WANDER
		return
	elif (player.position-position).length() > 800:
		move_state = MoveStates.SEEK
	elif ((player.position-position).length() < 800 and (player.position-position).length() > 500):
		move_state = MoveStates.APPROACH
	elif ((player.position-position).length() < 500 and (player.position-position).length() > 200):
		move_state = MoveStates.STOP
		if current_action == "awayfromplayer": override.emit()
	elif (player.position-position).length() < 195:
		move_state = MoveStates.FLEE
		override.emit()
	if wandering == true:
		move_state = MoveStates.ENDWANDER
	currently = false

# Halves maximum speed if the enemy is in goo.
func thingy_hazard():
	if in_goo:
		current_max_speed = max_speed*0.5
	elif !in_goo:
		current_max_speed = max_speed

# Damages the enemy when hit with a bullet. Called by bullet.gd
func thingy_damage(damage : int):
	health -= damage

func thingy_fire():
	if !illinois:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = $enemyNeutralSpecialSprite/gunner.global_transform
		b.is_fired_by_player = false



func getmovestate():
	return MoveStates.keys()[move_state]

# PROCESS



# Called every frame.. First sets the behavior state, then sets the maximum speed with thingy_hazard(). Afterwards, the appropriate function
# is called based on the behavior state. The player's movement is initiated, and the enemy's rotation is locked on to the player's. The health bar is updated and the enemy is
# deleted if its health is zero.
func _physics_process(delta):
	framecounter += 1/delta
	$toPlayer.target_position = to_local(player.position)
	thingy_hazard()
	toime += delta
	set_state()

	#match move_state:
		#MoveStates.SEEK: seek()
		#MoveStates.STOP: stop()
		#MoveStates.FLEE: flee()
		#MoveStates.WANDER: if wandering == false: wander()
		#MoveStates.ENDWANDER: back_to_player()
		#MoveStates.APPROACH: approach()
	if face_player:
		look_at(player.position)
	if rotating:
		thingy_rotate(delta)
	if current_action:
		Callable(self, current_action).call()
	if stopped:
		velocity = Vector2.ZERO
	move_and_slide()
	$enemyHealthBar.value = health
	if is_zero_approx(health):
		queue_free()
