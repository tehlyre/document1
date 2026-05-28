extends Node2D

@export var enemy_root : EnemyRoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_root.no_more_enemies.connect(_on_no_more_enemies)

func _on_no_more_enemies():
	for chest in get_children():
		if Aeon.is_it_in_my_room(chest.global_position):
			chest.is_locked = false
