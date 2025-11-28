extends Timer
class_name HBossFire


@export var mover : HBossMover
@export var hboss : CharacterBody2D
@export var top_right_gun : Gun
@export var top_left_gun : Gun
@export var butt_right_gun : Gun
@export var butt_left_gun : Gun

@export var gun_root : Node2D

var current_action = "none"

func _ready() -> void:
	timeout.connect(_on_timeout)
	mover.did_move.connect(_on_did_move)
	wait_time = 2.0
	start()

func _on_timeout():
	stop()
	await cw_sprinkler()
	await mover.cue_movement()
	start()



# Behavior cw_sprinkler: Fires 8 bullets in a clockwise manner in a sprinkler fashion.
func cw_sprinkler() -> void:
	current_action = "cw_sprinkler"
	mover.starting_rotation = hboss.get_rotation()
	for i in range(0,4):
		top_right_gun.fire()
		top_left_gun.fire()
		await mover.rotate_to(PI/4, 0.5)
		butt_left_gun.fire()
		butt_right_gun.fire()
		await mover.rotate_to(PI/4, 0.5)

# Behavior cw_sprinkler: Fires 8 bullets in a clockwise manner in a sprinkler fashion.
func ccw_sprinkler() -> void:
	current_action = "ccw_sprinkler"
	mover.starting_rotation = hboss.get_rotation()
	for i in range(0,4):
		top_right_gun.fire()
		top_left_gun.fire()
		await mover.rotate_to(-PI/4, 0.5)
		butt_left_gun.fire()
		butt_right_gun.fire()
		await mover.rotate_to(-PI/4, 0.5)

func homing() -> void:
	current_action = "homing"
	await mover.lerp_gun_adjust()

func _on_did_move(_number):
	for i in gun_root.get_children():
		print("q")
		i.fire()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
