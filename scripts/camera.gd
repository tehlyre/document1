extends Camera2D

@onready var size : Vector2 = get_viewport_rect().size*2
@export var player : Player
@export var wall : Wall
@export var enemy_spawn : EnemySpawn
var current_cell : Vector2i
var last_cell : Vector2i
var is_locked : bool = true
var current_room : Array[Vector2i]

signal sig_change_rooms(cell : Vector2i)

func _ready() -> void:
	wall.sig_this_room.connect(_on_room_callback)
	wall._on_player_change_rooms((player.global_position / size).floor())
	last_cell = (player.global_position/size).floor()

func update_position() -> void:
	current_cell = (player.global_position / size).floor()
	if last_cell != current_cell and not current_cell in current_room:
		print("oh skibidi I love you")
		sig_change_rooms.emit(current_cell)
		last_cell = current_cell
		global_position = Vector2(current_cell) * size
	else:
		var tweenx = get_tree().create_tween()
		var tweeny = get_tree().create_tween()
		if global_position.x+1280-player.global_position.x < -400 and player.velocity.x > 0:
			tweenx.tween_property(self, "global_position:x", global_position.x+player.velocity.x/40, 0.033)
		elif global_position.x+1280-player.global_position.x > 400 and player.velocity.x < 0:
			tweenx.tween_property(self, "global_position:x", global_position.x+player.velocity.x/40, 0.033)
		if global_position.y+720-player.global_position.y < -200 and player.velocity.y > 0:
			tweeny.tween_property(self, "global_position:y", global_position.y+player.velocity.y/40, 0.033)
		elif global_position.y+720-player.global_position.y > 200 and player.velocity.y < 0:
			tweeny.tween_property(self, "global_position:y", global_position.y+player.velocity.y/40, 0.033)
		else:
			tweenx.kill()
			tweeny.kill()
			global_position = global_position
	if global_position.y > limit_bottom-1440: global_position.y = limit_bottom-1440
	elif global_position.y < limit_top: global_position.y = limit_top
	if global_position.x > limit_right-2560: global_position.x = limit_right-2560
	elif global_position.x < limit_left: global_position.x = limit_left
#
func _process(delta: float) -> void:
	update_position()
	

func _on_room_callback(rooms : Array[Vector2i], coords : Vector2i) -> void:
	print(rooms)
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
