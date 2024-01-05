extends Node2D

@export var player : CharacterBody2D
@export var EnemyHandles : Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() > 0:
		for i in get_children():
			i.player = player
			i.get_node("EnemyBody").target = player
			i.enemyhandles = EnemyHandles
			i.readyy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
