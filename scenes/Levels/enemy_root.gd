extends Node2D
class_name EnemyRoot

signal do_not_resuscitate(coords, miniboss)
signal relay()
var enemies_on_screen : Array = []
@export var bullet_root : BulletRoot
@export var cam : Camera2D
var is_there_enemies

signal no_more_enemies()

func _ready():
	bullet_root.done_deleting_bullets.connect(_on_ddb)
	if len(get_children()) > 0:
		is_there_enemies = true

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


var enemy_on_screen : Array = [false, null]:
	set(screen_enemy):
		enemy_on_screen = screen_enemy
		if enemy_on_screen[0]:
			enemies_on_screen.append(enemy_on_screen[1])
		elif !enemy_on_screen[0]:
			enemies_on_screen.erase(enemy_on_screen[1])
	get:
		return enemy_on_screen

func _process(_delta):
	if len(get_children()) > 0:
		is_there_enemies = true
	elif len(get_children()) == 0:
		is_there_enemies = false
		no_more_enemies.emit()
