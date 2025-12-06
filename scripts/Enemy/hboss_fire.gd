extends Timer
class_name HBossFire


@export var mover : HBossMover
var hboss : CharacterBody2D
@export var top_right_gun : Gun
@export var top_left_gun : Gun
@export var butt_right_gun : Gun
@export var butt_left_gun : Gun
var player : Player

@export var gun_root : Node2D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var current_action = "none"

func _init(h_ : HBossChar, p_ : Player, trg : Gun, tlg : Gun, brg : Gun, blg : Gun, m_ : HBossMover) -> void:
	hboss = h_
	player = p_
	top_left_gun = tlg
	top_right_gun = trg
	butt_left_gun = blg
	butt_right_gun = brg
	mover = m_

func _ready() -> void:
	timeout.connect(_on_timeout)
	wait_time = 2.0
	start()

func _on_timeout():
	stop()
	match rng.randi_range(0,3):
		0: await cw_sprinkler()
		1: await ccw_sprinkler()
		2: await homing()
		3: await homing()
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
	hboss.rotation = 0
	await get_tree().create_timer(3).timeout

# Behavior cw_sprinkler: Fires 8 bullets in a clockwise manner in a sprinkler fashion.
func ccw_sprinkler() -> void:
	current_action = "ccw_sprinkler"
	mover.starting_rotation = hboss.get_rotation()
	for i in range(0,4):
		await mover.rotate_to(-PI/4, 0.5)
		top_right_gun.fire()
		top_left_gun.fire()
		await mover.rotate_to(-PI/4, 0.5)
		butt_left_gun.fire()
		butt_right_gun.fire()
	hboss.rotation = 0
	await get_tree().create_timer(3).timeout
	
	

func homing() -> void:
	current_action = "homing"
	await mover.back_to_player()
	var guns_to_fire = []
	if mover.front_side == mover.FrontSides.TOP:
		mover.gorp_to_player(top_right_gun)
		mover.gorp_to_player(top_left_gun)
		await mover.sig_done_gorping
		await mover.sig_done_gorping
		guns_to_fire.append(top_left_gun)
		guns_to_fire.append(top_right_gun)
	elif mover.front_side == mover.FrontSides.BUTT:
		print("sigma")
		mover.gorp_to_player(butt_right_gun)
		mover.gorp_to_player(butt_left_gun)
		await mover.sig_done_gorping
		await mover.sig_done_gorping
		guns_to_fire.append(butt_left_gun)
		guns_to_fire.append(butt_right_gun)
	for i in range(0,6):
		for j in guns_to_fire:
			j.fire()
		await get_tree().create_timer(0.5).timeout
	

func _on_did_move(_number):
	for i in gun_root.get_children():
		print("q")
		i.fire()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
