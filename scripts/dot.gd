extends Node2D
class_name Dot

# Script for Aura Dots
#
# Purpose: To assist enemies in peeking by "making a trail" that the enemy can follow. It does not
# make a trail of breadcrumbs, but rather a small aura around the player that points to where the
# player is.
#
# Node Structure:
# auraDot
# |_ toPlayer: Raycast2D that always points to the player to detect if the player is in eyeshot.
# |_ dotSprite: Sprite2D that holds the debugging sprite for the dot.
# |_ dotArea: Area2D that handles collisions with enemy raycasts.
#    |_ dotCollider: CollisionShape2D that is the collider for dotArea.
#
# GLOBAL VARIABLES


# @export Player player: A pointer to the player/root node, set in the editor. Used to detect if
# it is in eyeshot of the player.
@export var player : Player

# bool is_adequate_target: Whether or not the dot is in eyeshot of the player. This is used by the
# enemy to calculate where to go during a peek state.
var is_adequate_target : bool

# Sprite2D active_texture, inactive_texture: Debugging sprites that demonstrate which aura dots are
# active and which are inactive.
var active_texture = preload("res://assets/textures/dot2.png")
var inactive_texture = preload("res://assets/textures/dot.png")




# PROCESS



# Called every frame. Points $toPlayer towards the player, then detects if the collider is actually
# the player. If yes, the collision layer is set to 6 (the one for active aura dots), the dot
# becomes an active one, and the texture is swapped to the active one. If not, the collision layer
# is set to 8 (the one for inactive aura dots), the dot becomes inactive, and the texture is
# swapped to the inactive one.
func _process(delta):
	$toPlayer.target_position = -position
	if $toPlayer.get_collider() == player:
		$dotArea.collision_layer = 64
		is_adequate_target = true
		$dotSprite.texture = active_texture
	else:
		is_adequate_target = false
		$dotSprite.texture = inactive_texture
		$dotArea.collision_layer = 256
