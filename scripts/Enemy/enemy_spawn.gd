extends TileMapLayer
class_name EnemySpawn

@export var cam : Camera2D
var CAMERA_TO_TILE : Vector2i = Vector2i(32, 18)
var enemy : PackedScene = preload("res://scenes/Characters/enemigo.tscn")
var dummy : PackedScene = preload("res://scenes/Characters/dummy.tscn")
var hboss : PackedScene = preload("res://scenes/Characters/h_boss.tscn")
@export var enemy_root : EnemyRoot
@export var player : Player
@export var walls : Wall
var dnr : Array[Vector2i] = []


func _ready() -> void:
	enemy_root.do_not_resuscitate.connect(_on_miniboss_death)
	walls.sig_this_room.connect(_on_player_change_rooms)
	_on_player_change_rooms([Vector2i.ZERO], Vector2i.ZERO)
	for i in get_used_cells():
		get_cell_tile_data(i).modulate.a = 0

func bounded_by_rectanglei(arg_ : Vector2i, tleft : Vector2i, bright : Vector2i) -> bool:
	return arg_.x > tleft.x and arg_.y > tleft.y and arg_.x < bright.x and arg_.y < bright.y

func bounded_by_rectangle(arg_ : Vector2, tleft : Vector2, bright : Vector2) -> bool:
	return arg_.x > tleft.x and arg_.y > tleft.y and arg_.x < bright.x and arg_.y < bright.y

func _on_miniboss_death(coords, _miniboss):
	if coords is Vector2i:
		dnr.append(coords)

func _on_player_change_rooms(rooms : Array[Vector2i], _coords : Vector2i):
	var cool_arrayx : Array[int] = []
	var cool_arrayy : Array[int] = []
	for i in rooms: 
		cool_arrayx.append(i.x)
		cool_arrayy.append(i.y)
	var tleft_bound : Vector2i = Vector2i(cool_arrayx.min(), cool_arrayy.min())*CAMERA_TO_TILE
	var bright_bound : Vector2i = (Vector2i(cool_arrayx.max(), cool_arrayy.max())+Vector2i.ONE)*CAMERA_TO_TILE
	for child in enemy_root.get_children():
		child.queue_free()
	for i in get_used_cells_by_id(0):
		if bounded_by_rectangle(i, tleft_bound, bright_bound):
			var e_ = enemy.instantiate()
			e_.player = player
			e_.position = map_to_local(i)
			enemy_root.add_child(e_)
	for i in get_used_cells_by_id(1):
		print(dnr, "uwu")
		if bounded_by_rectangle(i, tleft_bound, bright_bound) and i not in dnr:
			var e_ : HBoss = hboss.instantiate()
			e_.player = player
			e_.spawn_coords = i
			e_.position = map_to_local(i)
			enemy_root.add_child(e_)
	print(get_used_cells_by_id(2))
	for i in get_used_cells_by_id(2):
		if bounded_by_rectangle(i, tleft_bound, bright_bound):
			var e_ : Dummy = dummy.instantiate()
			e_.player = player
			e_.position = map_to_local(i)
			enemy_root.add_child(e_)
			print("67")
