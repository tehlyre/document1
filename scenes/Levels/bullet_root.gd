extends Node2D
class_name BulletRoot

@export var enemy_root : EnemyRoot
signal done_deleting_bullets()

func _ready() -> void:
	enemy_root.do_not_resuscitate.connect(_on_miniboss_death)

func _on_miniboss_death(coords, miniboss):
	if miniboss != null:
		for i in get_children():
			if i.firee == miniboss:
				i.queue_free()
		done_deleting_bullets.emit()
