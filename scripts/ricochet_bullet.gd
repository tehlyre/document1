extends CharacterBody2D
class_name RicochetBullet

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

var is_ricocheting : bool = false
var ricochet_counter : int = 0

# FLAGS

# bool is_fired_by_player: Stores whether or not 
var firee : Node2D
var collision : KinematicCollision2D


# Called when bullet is fired/node is instantiated. Connects the body_entered signal to on_body_entered().
func _ready() -> void:
	if firee is Player: collision_mask -= 1
	else: collision_mask -= 2


# Connected to self.body_entered. Can damage enemies and players differently, and unalives itself afterwords.
func on_body_entered(body : Node2D, normal : Vector2) -> void:
	if(body.is_in_group("enemies")):
		body.thingy_damage(100/body.DAMAGE_SCALE)
	elif(body.is_in_group("player")):
		body.thingy_damage(10)
	elif(body.is_in_group("walls")):
		if !is_ricocheting:
			ricochet_counter += 1
			if ricochet_counter > 2:
				queue_free()
				return
			ricochet(normal)
			is_ricocheting = true
		else:
			is_ricocheting = false
		return
	elif(body.is_in_group("breakables")):
		body.smash()
	queue_free()


# PROCESS

func ricochet(normal : Vector2):
	if rotation-atan2(normal.y, normal.x)<PI/2 and rotation-atan2(normal.y, normal.x)>0:
		velocity = normal.rotated(-PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(-PI/4).y, normal.rotated(-PI/4).x)
	elif abs(rotation-atan2(normal.y, normal.x))<PI/2 and rotation+atan2(normal.y, normal.x)>0:
		velocity = normal.rotated(PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(-PI/4).y, normal.rotated(PI/4).x)
	elif rotation-atan2(normal.y, normal.x)>PI/2 and rotation-atan2(normal.y, normal.x)<PI:
		velocity = normal.rotated(PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(PI/4).y, normal.rotated(PI/4).x)
	elif rotation-atan2(normal.y, normal.x)<-PI/2 and rotation-atan2(normal.y, normal.x)>-PI:
		velocity = normal.rotated(-PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(-PI/4).y, normal.rotated(-PI/4).x)
	elif rotation-atan2(normal.y, normal.x)>PI:
		velocity = normal.rotated(-PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(-PI/4).y, normal.rotated(-PI/4).x)
	elif rotation-atan2(normal.y, normal.x)<-PI:
		velocity = normal.rotated(PI/4)*SPEED_WHEN_PLAYER
		rotation = atan2(normal.rotated(PI/4).y, normal.rotated(PI/4).x)

# Changes the position of the bullet by the speed of the bullet, thereby moving the bullet. This is done
# by referencing the bullet's transform.x, or the basis vector in the x-direction. Basically the direction
# the bullet is facing, and then going in that direction by the appropriate speed.
func _physics_process(_delta : float) -> void:
	if firee is Player:
		velocity = transform.x*SPEED_WHEN_PLAYER
	else:
		velocity = transform.x * SPEED_WHEN_ENEMY
	collision = move_and_collide(velocity)
	if collision != null:
		on_body_entered(collision.get_collider(), collision.get_normal())
