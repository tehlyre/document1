extends Node2D
class_name HBoss


@export var player : Player
var health : int = 100
var mover : HBossMover
var fire : HBossFire
@export var top_right_gun : Gun
@export var top_left_gun : Gun
@export var butt_right_gun : Gun
@export var butt_left_gun : Gun
@export var spawn_coords : Vector2i
var target_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mover = HBossMover.new($HBoss, player, top_right_gun, top_left_gun, butt_right_gun, butt_left_gun, $left, $right)
	add_child(mover)
	fire = HBossFire.new($HBoss, player, top_right_gun, top_left_gun, butt_right_gun, butt_left_gun, mover)
	target_position = $HBoss.global_position
	add_child(fire)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	target_position = $HBoss.global_position
	mover.tick(delta)
	$HBoss/HBossHealthBar.value = health
	if is_zero_approx(health):
		get_parent().miniboss_dead = [true, spawn_coords, self]
		await get_parent().relay
		queue_free()

# Damages the enemy when hit with a bullet. Called by bullet.gd
func thingy_damage(damage : int) -> void:
	health -= damage
	
