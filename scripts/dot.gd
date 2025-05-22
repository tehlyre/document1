extends Node2D

@export var player_position : Vector2
@export var enemy_position : Vector2
var adequate_target : bool
@export var player : Player
@export var enemy : Enemy



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$toPlayer.target_position = -position
	if $toPlayer.get_collider() == player:
		adequate_target = true
	else:
		adequate_target = false
