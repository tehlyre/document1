extends Node2D
class_name EnemyRoot

signal do_not_resuscitate(coords)

var miniboss_dead : Array = [false, Vector2i(0,0)]:
	set(new_death):
		miniboss_dead = new_death
		if miniboss_dead[0]:
			do_not_resuscitate.emit(miniboss_dead[1])
		elif !miniboss_dead[0]:
			do_not_resuscitate.emit(0)
	get:
		return miniboss_dead
