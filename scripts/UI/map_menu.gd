extends Control
class_name MapMenu

@export var game : GameManager
@onready var mapSprite = $Panel/map
@onready var markers = $Panel/map/markers
var marker : PackedScene = preload("res://scenes/UI/map_marker.tscn")
var player : Player
@onready var auxtext = $Panel/cursor/quepasa
@onready var cursor = $Panel/cursor
var is_first : bool = true
var initial_map_position : Vector2
@export var xmin : int
@export var ymin : int

func _ready() -> void:
	#print($Panel/map.get_rect().position, " aosidjpfgaoihjsdpfj")
	hide()
	game.sig_open_map.connect(_on_open_map)
	markers.selection.connect(_on_marker_select)
	initial_map_position = mapSprite.position

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and game.menu_state == game.MenuStates.MENU_MAP: 
		mapSprite.position -= event.screen_relative if !is_first else Vector2.ZERO
		is_first = false

func _on_open_map(is_opening : bool, player_position : Vector2) -> void:
	if is_opening: 
		show()
		mapSprite.position = initial_map_position
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var m_ = marker.instantiate()
		get_node("Panel/map/markers").add_child(m_)
		m_.position = Vector2((player_position.x-xmin)*2,(player_position.y-ymin)*2)
		print(player_position, "skibidiah")
		m_.cursor = get_node("Panel/cursor")
		m_.marker_type = 3
		$Panel/map/markers.youarehere = m_.get_index()
		m_.switch_sprite()
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Panel/map/markers.get_child($Panel/map/markers.youarehere).queue_free()
		
	

#func _process(delta):
	#prints(mapSprite.global_position, initial_marker_position, marker.get_child(0).get_rect().size)
	

func _on_marker_select(selection : int) -> void:
	match selection:
		0: auxtext.text = ""
		1: auxtext.text = "Locked Door"
		2: auxtext.text = "Basic Chest"
		3: auxtext.text = "You Are Here"
	#mapSprite.global_position += cursor.global_position-marker.global_position+Vector2(40,40) if is_selected else Vector2.ZERO
