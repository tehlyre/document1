extends Node2D

@onready var mover : HBossMover = $HBossMover
@onready var fire : HBossFire = $HBossFire
@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mover.player = player
	fire.player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mover.tick(delta)
