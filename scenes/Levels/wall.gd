extends TileMapLayer
class_name Wall

@export var cam : Camera2D
var room : Array[Vector2i] = []

signal sig_this_room(room_coords : Array[Vector2i], coords : Vector2i)

func is_on_border_of_screen(tile_coords : Vector2i, current_cell : Vector2i, cell_screen_size : Vector2i = Vector2i(32,18)) -> bool:
	var is_x : bool = tile_coords.x % cell_screen_size.x == 0 or tile_coords.x % cell_screen_size.x == cell_screen_size.x-1 or tile_coords.x % cell_screen_size.x == -1
	var is_y : bool = tile_coords.y % cell_screen_size.y == 0 or tile_coords.y % cell_screen_size.y == cell_screen_size.y-1 or tile_coords.y % cell_screen_size.y == -1
	var correct_cell: bool = Vector2i((Vector2(tile_coords)/Vector2(cell_screen_size)).floor()) == current_cell
	#prints(tile_coords, tile_coords.x%cell_screen_size.x, is_x)
	return (is_x or is_y) and correct_cell

func which_side(tile_coords : Vector2i, current_cell : Vector2i, cell_screen_size : Vector2i = Vector2i(32,18)) -> Side:
	if tile_coords.x % cell_screen_size.x == 0:
		return SIDE_LEFT
	elif tile_coords.x % cell_screen_size.x == cell_screen_size.x-1 or tile_coords.x % cell_screen_size.x == -1:
		return SIDE_RIGHT
	elif tile_coords.y % cell_screen_size.y == 0:
		return SIDE_TOP
	elif tile_coords.y % cell_screen_size.y == cell_screen_size.y-1 or tile_coords.y % cell_screen_size.y == -1:
		return SIDE_BOTTOM
	else:
		return 9

func _ready() -> void:
	cam.sig_change_rooms.connect(_on_player_change_rooms)

func _on_player_change_rooms(coords : Vector2i):
	room = []
	load_section(coords, coords)
	sig_this_room.emit(room, coords)
			#print(edge)
			#cam.set_limit(which_side(i, coords), )

func load_section(this_load : Vector2i, last_load : Vector2i):
	#prints("uwu", this_load, last_load)
	var top : int = 0
	var butt : int = 0
	var left : int = 0
	var right : int = 0
	for i in get_used_cells():
		var edge : float
		if (is_on_border_of_screen(i, this_load)):
			match which_side(i, this_load):
				SIDE_TOP: top+=1
				SIDE_BOTTOM: butt+=1
				SIDE_LEFT: left+=1
				SIDE_RIGHT: right+=1
	room.append(this_load)
	if top < 25 and this_load != Vector2i(last_load.x, last_load.y+1) and not Vector2i(last_load.x, last_load.y-1) in room:
		load_section(Vector2i(this_load.x, this_load.y-1), this_load)
	if butt < 25 and this_load != Vector2i(last_load.x, last_load.y-1) and not Vector2i(last_load.x, last_load.y+1) in room:
		load_section(Vector2i(this_load.x, this_load.y+1), this_load)
	if left < 13 and this_load != Vector2i(last_load.x+1, last_load.y) and not Vector2i(last_load.x-1, last_load.y) in room:
		load_section(Vector2i(this_load.x-1, this_load.y), this_load)
	if right < 13 and this_load != Vector2i(last_load.x-1, last_load.y) and not Vector2i(last_load.x+1, last_load.y) in room:
		load_section(Vector2i(this_load.x+1, this_load.y), this_load)
