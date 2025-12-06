extends Timer
class_name HBossMover

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var hboss : CharacterBody2D
@export var left : Sprite2D
@export var right : Sprite2D
@export var fire : HBossFire
@export var player : Player
@export var top_right_gun : Gun
@export var top_left_gun : Gun
@export var butt_right_gun : Gun
@export var butt_left_gun : Gun
enum MoveStates {
	NOT,
	LEFT,
	RIGHT
}
enum FrontSides {
	TOP,
	BUTT
}
var front_side : FrontSides = FrontSides.TOP
var up_vector : Vector2
var move_state : MoveStates = MoveStates.NOT:
	set(new_state):
		move_state = new_state
		if move_state == MoveStates.LEFT:
			hboss.global_position = left.global_position
		elif move_state == MoveStates.RIGHT:
			hboss.global_position = right.global_position
	get:
		return move_state
var starting_rotation : float
var is_rotating : bool
var angle_to_rotate : float
var time_to_rotate : float
var time_to_gun : float
var value_to_gun : float
var starting_gun : float
var rotate_lerp_weight : float
var is_rotating_to_player : bool = false
var is_facing_player : bool = false
var is_lerping_gun : bool = false
var is_returning_backwards : bool = false
var gun_lerp_weight : float = 0
var is_gun_to_player : bool = false
var gorpees = []
var adjustees = []


signal sig_done_rotating()
signal sig_facing_player()
signal sig_done_gorping()

func _init(h_ : HBossChar, p_ : Player, trg : Gun, tlg : Gun, brg : Gun, blg : Gun, ln : Sprite2D, rn : Sprite2D) -> void:
	hboss = h_
	player = p_
	top_left_gun = tlg
	top_right_gun = trg
	butt_left_gun = blg
	butt_right_gun = brg
	left = ln
	right = rn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#timeout.connect(_on_timeout)
	wait_time = 1.0
	start()
	hboss.position = left.position
	move_state = MoveStates.LEFT

func _on_timeout():
	stop()
	start()

func flip():
	hboss.rotation = hboss.rotation + PI/2

func rotate_cw():
	hboss.rotation = hboss.rotation + PI/4

func rotate_ccw():
	hboss.rotation = hboss.rotation - PI/4

func cue_movement():
	start()
	await timeout
	stop()
	if move_state == MoveStates.LEFT: move_state = MoveStates.RIGHT
	elif move_state == MoveStates.RIGHT: move_state = MoveStates.LEFT
	top_left_gun.reset_adjustment()
	top_right_gun.reset_adjustment()
	butt_right_gun.reset_adjustment()
	butt_left_gun.reset_adjustment()
	is_facing_player = false
	adjustees.clear()

func gorp_to_player(gun : Gun):
	starting_gun = gun.get_rotation()
	value_to_gun = gun.get_proper_adjustment(player.position)
	gorpees.append({"gun":gun, "gorp_weight":0.0, "starting_gorp":starting_gun, "ending_gorp":value_to_gun, "time_to_gorp":0.5})
	time_to_gun = 0.5
	await sig_done_gorping

func thingy_gorp(gun : Dictionary, delta : float):
	var weightperframe : float = delta*(gun["ending_gorp"]/gun["time_to_gorp"])/gun["ending_gorp"]
	gorpees.erase(gun)
	gun["gorp_weight"] += weightperframe
	#print(gun_lerp_weight)
	#print(gun)
	gun["gun"].rotation = lerp_angle(fmod(gun["starting_gorp"],2*PI), fmod(gun["starting_gorp"]+gun["ending_gorp"],2*PI), gun["gorp_weight"])
	#print(gun.rotation)
	gorpees.append(gun)
	if gun["gorp_weight"] > 1.0 or is_equal_approx(gun["gorp_weight"], 1.0) or is_nan(gun["gorp_weight"]):
		gun_lerp_weight = 0.0
		gorpees.erase(gun)
		value_to_gun = 0
		time_to_gun = 0
		sig_done_gorping.emit()
		is_gun_to_player = true
		adjustees.append(gun["gun"])
		
	

# ROTATION


# Initiates a rotation, taking in the angle and the time the rotation should take and setting their
#		respective parameters.
func rotate_to(angle : float, time : float) -> void:
	starting_rotation = hboss.get_rotation()
	is_rotating = true
	angle_to_rotate = angle
	time_to_rotate = time
	await sig_done_rotating

# Called when the enemy is rotating for any reason.
# If the enemy is rotating for a firing behavior: calculate the amount of weight to change per frame.
#		Then change that weight and set the rotation to a lerping between the starting rotation and
#		the new rotation. If the lerp is over, reset all the variables and stop rotating.
# Else if the enemy is rotating towards the player: lerp based on delta itself and lerp the enemy
#		rotation thataway. If the lerp is over, reset all the variables and stop rotating.
func thingy_rotate(delta : float) -> void:
	if is_rotating_to_player:
		rotate_lerp_weight += delta*2
		if front_side == FrontSides.TOP:
			hboss.rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation,2*PI)+(up_vector).angle_to(hboss.global_position-player.global_position), rotate_lerp_weight)
		elif front_side == FrontSides.BUTT:
			hboss.rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation, 2*PI)+(up_vector).angle_to(hboss.global_position-player.global_position), rotate_lerp_weight)
	else:
		var weightperframe : float = delta*(angle_to_rotate/time_to_rotate)/angle_to_rotate
		rotate_lerp_weight += weightperframe
		hboss.rotation = lerp_angle(fmod(starting_rotation,2*PI), fmod(starting_rotation+angle_to_rotate,2*PI), rotate_lerp_weight)
	if rotate_lerp_weight > 1.0 or is_equal_approx(rotate_lerp_weight, 1.0):
		rotate_lerp_weight = 0.0
		is_rotating = false
		angle_to_rotate = 0
		time_to_rotate = 0
		if is_rotating_to_player:
			sig_facing_player.emit()
			return
		sig_done_rotating.emit()

# Rotates the enemy back to the player. Uses the same process as rotate_to but uses specific
#		signals and flags.
func back_to_player() -> void:
	is_rotating_to_player = true
	is_rotating = true
	time_to_rotate = 5
	if top_right_gun.global_position.distance_squared_to(player.global_position) < butt_right_gun.global_position.distance_squared_to(player.position):
		front_side = FrontSides.TOP
		up_vector = hboss.global_position-hboss.get_node("forward").global_position
	elif top_right_gun.position.distance_squared_to(player.global_position) > butt_right_gun.global_position.distance_squared_to(player.position):
		front_side = FrontSides.BUTT
		up_vector = hboss.global_position-hboss.get_node("backward").global_position
	starting_rotation = hboss.get_rotation()
	await sig_facing_player
	is_facing_player = true
	is_rotating_to_player = false

# This function is called by the enemy every frame. It first sets the state of the function, then
#		checks if the enemy needs to wander or return to the player. Then, it faces the player, rotates
#		the enemy, calls the current_action and sets the velocity, and/or stops the enemy for firing if
#		applicable.
func tick(delta : float) -> void:
	#thingy_set_state()
	#if move_state == MoveStates.WANDER:
		#if is_in_wandering_process == false: 
			#wander()
	#elif move_state == MoveStates.ENDWANDER: back_to_player()
	if is_facing_player:
		hboss.look_at(player.position)
		hboss.rotation += PI/2
		if front_side == FrontSides.BUTT:
			hboss.rotation += PI
	if is_rotating:
		thingy_rotate(delta)
	for i in gorpees:
		thingy_gorp(i, delta)
	for i in adjustees:
		i.adjust(player.position)
		#thingy_gun_adjust(gun)
	#if current_action:
		#enemy.velocity = Callable(self, current_action).call()
	#if is_stoppedf:
		#enemy.velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
