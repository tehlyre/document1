extends Camera2D

@onready var size : Vector2 = get_viewport_rect().size*2
@export var player : Player
@export var wall : Wall
@export var enemy_spawn : EnemySpawn
var current_cell : Vector2i
var last_cell : Vector2i
var is_locked : bool = true
var current_room : Array[Vector2i]
var tweenx
var tweeny

signal sig_change_rooms(cell : Vector2i)

# TODO: Make it so that this manual global position change dynamically occurs based on the characters position.
func _ready() -> void:
	global_position = Vector2(14,0) #<-----
	wall.sig_this_room.connect(_on_room_callback)
	wall._on_player_change_rooms.call_deferred((player.global_position / size).floor())
	last_cell = (player.global_position/size).floor()
	print(global_position, " ready")

func update_position() -> void:
	current_cell = (player.global_position / size).floor()
	if last_cell != current_cell:
		print("xijfiwoejfoijwoiejfoij")
		if not current_cell in current_room:
			sig_change_rooms.emit(current_cell)
		last_cell = current_cell
		#global_position = Vector2(current_cell) * size
	else:
		if global_position.x+1280-player.global_position.x < -400 and player.velocity.x > 0:
			if global_position.x < limit_right-2560:
				tweenx = get_tree().create_tween()
				tweenx.tween_property(self, "global_position:x", global_position.x+player.velocity.x/40, 0.033)
		elif global_position.x+1280-player.global_position.x > 400 and player.velocity.x < 0:
			if global_position.x > limit_left:
				tweenx = get_tree().create_tween()
				tweenx.tween_property(self, "global_position:x", global_position.x+player.velocity.x/40, 0.033)
		else:
			if tweenx != null:
				tweenx.kill()
			global_position = global_position
		if global_position.y+720-player.global_position.y < -200 and player.velocity.y > 0:
			if global_position.y < limit_bottom-1440:
				tweeny = get_tree().create_tween()
				tweeny.tween_property(self, "global_position:y", global_position.y+player.velocity.y/40, 0.033)
		elif global_position.y+720-player.global_position.y > 200 and player.velocity.y < 0:
			if global_position.y > limit_top:
				tweeny = get_tree().create_tween()
				tweeny.tween_property(self, "global_position:y", global_position.y+player.velocity.y/40, 0.033)
		else:
			if tweeny != null:
				tweeny.kill()
			global_position = global_position
	#position = Vector2(clamp(global_position.x,limit_left,limit_right-get_viewport_rect().size.x),clamp(global_position.y,limit_top,limit_bottom-get_viewport_rect().size.y))
	if global_position.y > limit_bottom-1440:
		global_position.y = limit_bottom-1440
	elif global_position.y < limit_top: global_position.y = limit_top
	if global_position.x > limit_right-2560: global_position.x = limit_right-2560
	elif global_position.x < limit_left: global_position.x = limit_left
#
func _process(_delta: float) -> void:
	#prints(limit_left, limit_right, limit_top, limit_bottom)
	update_position()
	print(global_position)
	


		

func _on_room_callback(rooms : Array[Vector2i], _coords : Vector2i) -> void:
	#print(rooms)
	current_room = rooms
	var cool_arrayx : Array[int] = []
	var cool_arrayy : Array[int] = []
	for i in rooms: 
		cool_arrayx.append(i.x)
		cool_arrayy.append(i.y)
	var left : int = cool_arrayx.min()
	var right : int = cool_arrayx.max()
	var top : int = cool_arrayy.min()
	var butt : int = cool_arrayy.max()
	set_limit(SIDE_LEFT, left*2560)
	set_limit(SIDE_TOP, top*1440)
	set_limit(SIDE_RIGHT, (right+1)*2560)
	set_limit(SIDE_BOTTOM, (butt+1)*1440)
