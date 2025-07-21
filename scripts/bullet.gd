extends Area2D
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
var is_fired_by_player : bool


# Called when bullet is fired/node is instantiated. Connects the body_entered signal to on_body_entered().
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	if is_fired_by_player: collision_mask -= 1
	else: collision_mask -= 2


# Connected to self.body_entered. Can damage enemies and players differently, and unalives itself afterwords.
func _on_body_entered(body : Node2D) -> void:
	
	if(body.is_in_group("enemies")):
		body.thingy_damage(100/body.DAMAGE_SCALE)
	elif(body.is_in_group("player")):
		body.thingy_damage(10)
	elif(body.is_in_group("walls")):
		queue_free()
	queue_free()


# PROCESS



# Changes the position of the bullet by the speed of the bullet, thereby moving the bullet. This is done
# by referencing the bullet's transform.x, or the basis vector in the x-direction. Basically the direction
# the bullet is facing, and then going in that direction by the appropriate speed.
func _physics_process(_delta : float) -> void:
	if is_fired_by_player:
		position += transform.x * SPEED_WHEN_PLAYER
	else:
		position += transform.x * SPEED_WHEN_ENEMY
