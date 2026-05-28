extends CharacterBody2D
class_name Enemy

# Base Enemy Running Script (3.1): Sinful Enemy Stablizing and Running Script Premium (SinEStRP)
#
# Object:

# Node Structure:
# CharacterBody2D enemy
# |_ enemyCollider: CollisionShape2D for the enemy.
# |_ enemyHealthBar: Mini health ProgressBar for the enemy.
# |_ enemySprite: Sprite2D for the enemy.
# |_ enemyNeutralSpecialSprite: Sprite2D for the enemy's gun.
#    |_ gunner: Marker2D to mark where bullets should be instantiated.
#    |_ noGunZone: Area2D that prohibits firing if the gun is inside a wall.
#       |_ noGunZoneCollider
# |_ toPlayer: RayCast2D pointing at player to detect whether or not the enemy is in eyeshot.
#
# IMPORTS
#
# CharacterBody2D player: Pointer to the player.
# PackedScene Bullet: The packaged scene for the bullet that is to be fired.
# RandomNumberGenerator rng: A random number generator to make this thing more deterministic.
@export var player : CharacterBody2D
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@onready var gun : Gun = $neutralSpecial
@onready var player_raycast = $toPlayer
var mover : EnemyMover
var fire : EnemyFire
var is_being_forced : bool = false
@onready var collider = $enemyCollider
var target_position

# CONSTANTS

# float MAX_SPEED: The maximum speed of the enemy under normal conditions
# float SCLE: Used by the Bullet Class
var MAX_SPEED : float = 200
var DAMAGE_SCALE : float = 5
var THETA : float = 0.8

# FLAGS


# is_in_goo: Whether or not the enemy is stuck in goo, slowing it down.
var is_in_goo : bool = false

# STATUS VARIABLES

# float current_max_speed: The current maximum speed of the enemy under present conditions,
# based on the maximum speed under normal conditions.
var current_max_speed : float = MAX_SPEED

# float health: The current health of the enemy, in percent.
var health : float = 100.0


# Creates and adds the mover and the fire managers.
func _ready() -> void:
	mover = EnemyMover.new(self, player, MAX_SPEED)
	add_child(mover)
	fire = EnemyFire.new(self, gun, mover)
	add_child(fire)
	$VisibleOnScreenNotifier2D.screen_entered.connect(_on_enemy_enter_screen)
	target_position = global_position
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_enemy_exit_screen)
	#print(get_parent())

func _on_enemy_enter_screen():
	get_parent().enemy_on_screen = [true, self]

func _on_enemy_exit_screen():
	get_parent().enemy_on_screen = [false, self]



# Halves maximum speed if the enemy is in goo.
func thingy_hazard() -> void:
	if is_in_goo:
		current_max_speed = mover.MAX_SPEED*0.5
	elif !is_in_goo:
		current_max_speed = mover.MAX_SPEED

# Damages the enemy when hit with a bullet. Called by bullet.gd
func thingy_damage(damage : int) -> void:
	health -= damage









# PROCESS



# Called every frame.. First sets the behavior state, then sets the maximum speed with thingy_hazard(). Afterwards, the appropriate function
# is called based on the behavior state. The player's movement is initiated, and the enemy's rotation is locked on to the player's. The health bar is updated and the enemy is
# deleted if its health is zero.
func _physics_process(delta : float) -> void:
	target_position = global_position
	if !is_being_forced:
		$toPlayer.target_position = to_local(player.position)
		thingy_hazard()
		mover.tick(delta)
		gun.adjust(player.global_position)
		move_and_slide()
		$enemyHealthBar.value = health
		if is_zero_approx(health) or health < 0:
			queue_free()
