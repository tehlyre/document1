extends CharacterBody2D
class_name Bullet

# Bullet Script
#
# Object: Moves the bullets and hits anything in its path.
#
# NODE STRUCTURE:
# bullet
# |_ bulletSprite: Sprite2D of the bullet.
# |_ bulletCollider: CollisionShape2D for the bullet.
#
# CONSTANTS

# @export float player_speed, enemy_speed: The speed the bullet has when used by the player or the enemy.
# These can be different for balancing purposes.
@export var SPEED_WHEN_PLAYER : float = 15
@export var SPEED_WHEN_ENEMY : float = 5

# FLAGS

# bool is_fired_by_player: Stores whether or not 
var firee : Node2D
var firee_type : String
var collision : KinematicCollision2D


# Called when bullet is fired/node is instantiated. Connects the body_entered signal to on_body_entered().
func _ready() -> void:
	if firee is Player: 
		collision_mask -= 1
		collision_mask -= 512
		collision_mask -= 128
		firee_type = "player"
	else:
		collision_mask -= 2
		firee_type = "enemy"
	global_scale = Aeon.STANDARD_BULLET_SIZE


# Connected to self.body_entered. Can damage enemies and players differently, and unalives itself afterwords.
func on_body_entered(body : Node2D) -> void:
	if(body.is_in_group("enemies")):
		body.thingy_damage(100/body.DAMAGE_SCALE)
	elif(body.is_in_group("player")):
		body.thingy_damage(10)
	elif(body.is_in_group("walls")):
		pass
	elif(body.is_in_group("breakables")) and body.host != firee:
		body.smash()
	queue_free()


# PROCESS

func thingy_damage(anything):
	queue_free()

# Changes the position of the bullet by the speed of the bullet, thereby moving the bullet. This is done
# by referencing the bullet's transform.x, or the basis vector in the x-direction. Basically the direction
# the bullet is facing, and then going in that direction by the appropriate speed.
func _physics_process(_delta : float) -> void:
	if firee_type == "player":
		velocity = transform.x*SPEED_WHEN_PLAYER
	else:
		velocity = transform.x * SPEED_WHEN_ENEMY
	collision = move_and_collide(velocity)
	if collision != null:
		on_body_entered(collision.get_collider())
