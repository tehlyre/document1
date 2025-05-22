extends CharacterBody2D
class_name Enemy

# Base Enemy Running Script (2.0)
# Sinful Enemy Stablizing and Running Script (SinEStR)
#
# Basic enemy movement shell with infinite range. Based on the paper "Steering Behaviors for Autonomous Characters" by Craig Reynolds, presented at GDC 1999. Implements a seeking
# steering behavior at distances larger than 200 units, stopping when reaching ~200 units, and fleeing when closer than 200 units.
#
# TODO: implement range, wandering and peeking.
#
# Global Variables

# CharacterBody2D player: Pointer to the player in the level
@export var player : CharacterBody2D

@export var Bullet : PackedScene

var rng = RandomNumberGenerator.new()

# float max_sped: The maximum speed (currently only speed) of the enemy in normal circumstances.
# float max_speed: The current maximum speed after hazards are accounted for.
var max_sped : float = 200
var max_speed : float = max_sped

# MoveStates movestate: The current behavior state of the enemy. Currently either SEEK, STOP, or FLEE.
var movestate : MoveStates
var firestate : FireStates

# bool in_goo: Whether or not the enemy is stuck in goo, slowing it down.
var in_goo : bool = false

# float health: The current health of the enemy, in percent.
var health : float = 100.0

# float scle: The damage scaling constant, used to calculate how much damage is dealt to the enemy. AKA how many hits does it take to kill using normal bullets.
var scle : float = 3

var minus_suggestion
var plus_suggestion
var minus = true
var plus = true
var peek_init = false
var lock_on
var DO_NOT_COME

var previous_state = [MoveStates.STOP, FireStates.CONSERVE]

var framecount = 0
var deltatime = 0
var moment_firing

# enum States: The states that govern the behavior of the enemy. Currently, only seek (move towards player), stop, and flee (move away from player) have been implemented.
enum MoveStates {
	SEEK,
	STOP,
	FLEE,
	PEEK,
	WANDER
}

enum FireStates {
	FIRE,
	CONSERVE
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in $sieker.get_children():
		i.collide_with_areas = true
	
# void seek(void): Steers the enemy towards the player. First calculates the desired direct velocity limited with respect to the maximum speed, then subtracts velocity from it to
# produce the desired change in velocity.
func seek():
	var desired_velocity = (player.position-position).normalized() * max_speed
	velocity += (desired_velocity-velocity)

# void stop(void): Stops the enemy.
func stop():
	velocity = Vector2.ZERO
	

# void flee(void): Steers the enemy away from the player. First calculates the desired direct velocity limited with respect to the maximum speed pointing directly away from the
# player, then subtracts velocity from it to produce the desired change in velocity.
func flee():
	var desired_velocity = -(player.position-position).normalized() * (max_speed/2)
	velocity += (desired_velocity-velocity)

func peek():
	if peek_init:
		peek_init = false
	if ($beta_minus.target_position - to_local(player.position)).length() < 0.01:
		peek_init = true
		lock_on = to_local(player.position)
		$beta_minus.target_position = lock_on
		$beta_plus.target_position = lock_on
	if minus:
		$beta_minus.target_position = $beta_minus.target_position.rotated(0.1)
	if plus:
		$beta_plus.target_position = $beta_plus.target_position.rotated(-0.1)
	if $beta_minus.get_collider() == null or $beta_minus.get_collider() != $alpha_particle.get_collider():
		minus_suggestion = $beta_minus.target_position
		minus = false
	if $beta_plus.get_collider() == null or $beta_plus.get_collider() != $alpha_particle.get_collider():
		plus_suggestion = $beta_plus.target_position
		plus = false
	if !minus and !plus:
		if (lock_on-$beta_plus.target_position).length() < (lock_on-$beta_minus.target_position).length():
			velocity = ($beta_plus.target_position.normalized()*max_speed)
		elif (lock_on-$beta_minus.target_position).length() < (lock_on-$beta_plus.target_position).length():
			velocity = ($beta_minus.target_position.normalized()*max_speed)

func fire(delta : float):
	look_at(player.position)
	if previous_state[1] != FireStates.FIRE or moment_firing == null:
		moment_firing = deltatime
	print(moment_firing)
	var fps = int(1/delta)
	if (framecount % (fps/1))-(int(moment_firing) % (fps/4))+int(10*rng.randf()-5) == 0:
		var b = Bullet.instantiate()
		owner.add_child(b)
		b.transform = $gunner.global_transform
		b.player_origin = false

func conserve():
	pass

# void set_state(void): Sets the appropriate state for the enemy based on preconceived conditions. If the player is farther than 200 units away, switch state to seek. If the
# player is around 200 units away, switch state to stop, and if the player is under 200 units away, switch state to flee.
func set_state():
	previous_state[0] = movestate
	previous_state[1] = firestate
	if DO_NOT_COME:
		movestate = MoveStates.STOP
		firestate = FireStates.CONSERVE
	elif $alpha_particle.get_collider() != null and $alpha_particle.get_collider() != player:
		movestate = MoveStates.PEEK
		firestate = FireStates.CONSERVE
	elif (player.position-position).length() > 200:
		movestate = MoveStates.SEEK
		firestate = FireStates.FIRE
	elif ((player.position-position).length() < 200 and (player.position-position).length() > 195):
		movestate = MoveStates.STOP
		firestate = FireStates.FIRE
	elif (player.position-position).length() < 195:
		movestate = MoveStates.FLEE
		firestate = FireStates.FIRE
				

# void hazard_thingy(void): Halves maximum speed if the enemy is in goo.
func hazard_thingy():
	if in_goo:
		max_speed = max_sped*0.5
	elif !in_goo:
		max_speed = max_sped

# void damage_thingy(int damage): Damages the enemy when hit with a bullet. Called by bullet.gd
func damage_thingy(damage : int):
	health -= damage

# void _physics_process(float delta): Primary loop function. First sets the behavior state, then sets the maximum speed with hazard_thingy(). Afterwards, the appropriate function
# is called based on the behavior state. The player's movement is initiated, and the enemy's rotation is locked on to the player's. The health bar is updated and the enemy is
# deleted if its health is zero.
func _physics_process(delta):
	pass
#	$alpha_particle.target_position = to_local(player.position)
#	#$RayCast2D.target_position = velocity
#	if movestate != MoveStates.PEEK:
#		$beta_minus.target_position = to_local(player.position)
#		$beta_plus.target_position = to_local(player.position)
#		plus = true
#		minus = true
#	set_state()
#	hazard_thingy()
#	framecount += 1
#	deltatime += delta
#
#	match movestate:
#		MoveStates.SEEK:
#			seek()
#		MoveStates.STOP:
#			stop()
#		MoveStates.FLEE:
#			flee()
#		MoveStates.PEEK:
#			peek()
#
#	match firestate:
#		FireStates.FIRE:
#			fire(delta)
#		FireStates.CONSERVE:
#			conserve()
#
#	#look_at(player.position)
#	move_and_slide()
#	$healthbar.value = health
#	if health <= 1:
#		queue_free()
