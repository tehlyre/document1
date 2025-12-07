extends Node2D
class_name EnemyRoot

signal do_not_resuscitate(coords, miniboss)
signal relay()
@export var bullet_root : BulletRoot

func _ready():
	bullet_root.done_deleting_bullets.connect(_on_ddb)

func _on_ddb():
	relay.emit()

var miniboss_dead : Array = [false, Vector2i(0,0), null]:
	set(new_death):
		miniboss_dead = new_death
		if miniboss_dead[0]:
			do_not_resuscitate.emit(miniboss_dead[1], miniboss_dead[2])
		elif !miniboss_dead[0]:
			do_not_resuscitate.emit(0)
	get:
		return miniboss_dead
