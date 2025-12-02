extends CharacterBody2D
class_name HBossChar

var DAMAGE_SCALE = 5

func thingy_damage(damage : int) -> void:
	get_parent().thingy_damage(damage)
	print("oooo")
