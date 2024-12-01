extends CharacterBody2D

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

# float max_sped: The maximum speed (currently only speed) of the enemy in normal circumstances.
# float max_speed: The current maximum speed after hazards are accounted for.
var max_sped : float = 200
var max_speed : float = max_sped

# States state: The current behavior state of the enemy. Currently either SEEK, STOP, or FLEE.
var state : States

# bool in_goo: Whether or not the enemy is stuck in goo, slowing it down.
var in_goo : bool = false

# float health: The current health of the enemy, in percent.
var health : float = 100.0

# float scle: The damage scaling constant, used to calculate how much damage is dealt to the enemy. AKA how many hits does it take to kill using normal bullets.
var scle : float = 3

# enum States: The states that govern the behavior of the enemy. Currently, only seek (move towards player), stop, and flee (move away from player) have been implemented.
enum States {
	SEEK,
	STOP,
	FLEE,
	PEEK,
	WANDER
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
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

# void set_state(void): Sets the appropriate state for the enemy based on preconceived conditions. If the player is farther than 200 units away, switch state to seek. If the
# player is around 200 units away, switch state to stop, and if the player is under 200 units away, switch state to flee.
func set_state():
		if (player.position-position).length() > 200:
			state = States.SEEK
		elif (player.position-position).length() < 200 and (player.position-position).length() > 195:
			state = States.STOP
		elif (player.position-position).length() < 195:
			state = States.FLEE
				

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
	set_state()
	hazard_thingy()
	
	match state:
		States.SEEK:
			seek()
		States.STOP:
			stop()
		States.FLEE:
			flee()
	
	look_at(player.position)
	move_and_slide()
	$healthbar.value = health
	if health <= 1:
		queue_free()
