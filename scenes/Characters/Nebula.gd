extends Node2D

@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_children():
		i.player = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
