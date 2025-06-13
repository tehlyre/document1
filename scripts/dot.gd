extends Node2D
class_name Dot

@export var player_position : Vector2
@export var enemy_position : Vector2
var adequate_target : bool
@export var player : Player
@export var enemy : Enemy
var active_texture = preload("res://assets/textures/dot2.png")
var inactive_texture = preload("res://assets/textures/dot.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$toPlayer.target_position = -position
	if $toPlayer.get_collider() == player:
		$Area2D.collision_layer = 64
		adequate_target = true
		$Dot.texture = active_texture
	else:
		adequate_target = false
		$Dot.texture = inactive_texture
		$Area2D.collision_layer = 256
