extends CharacterBody2D


var vel : Vector2
var player
var target
var redirect
var speed =200
var in_goo
var new_position
var scle = 10
var stopping = 200
var max_force = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	vel = Vector2(cos(global_rotation), sin(global_rotation))*speed
	#print(global_rotation)
	
func readyy():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var accel : Vector2 = Vector2.ZERO
	var desired_vel_seek = (target.global_position-global_position).normalized()*speed
	var desired_vel_flee = (global_position-target.global_position).normalized()*speed
	var steer_seek = desired_vel_seek-vel
	var steer_flee = desired_vel_flee-vel
	if steer_seek.length() > 4:
		steer_seek = steer_seek.normalized()*4
	if steer_flee.length() > 4:
		steer_flee = steer_flee.normalized()*4
	accel += steer_seek
	vel += accel
	
	look_at(global_position+vel)
	if (target.global_position-global_position).length() >=195.0 and (target.global_position-global_position).length() <= 205.0:
		velocity = Vector2.ZERO
	elif (target.global_position-global_position).length() < 195.0:
		accel += steer_flee
		velocity += accel
	else:
		velocity = vel
	move_and_slide()
