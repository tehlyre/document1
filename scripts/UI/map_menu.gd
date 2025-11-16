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
var original_pos : Vector2 = Vector2(652, 390)
var is_button_pressed_once = false
var is_open = false

func _ready() -> void:
	#print($Panel/map.get_rect().position, " aosidjpfgaoihjsdpfj")
	hide()
	game.sig_open_map.connect(_on_open_map)
	markers.selection.connect(_on_marker_select)
	markers.teleportation.connect(_on_teleportation)
	initial_map_position = mapSprite.position

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion and game.menu_state == game.MenuStates.MENU_MAP: 
		mapSprite.position -= event.screen_relative/2 if !is_first else Vector2.ZERO
		is_first = false

func _on_open_map(is_opening : bool, player_position : Vector2) -> void:
	if is_opening: 
		is_open = true
		show()
		mapSprite.position = initial_map_position
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		var m_ = marker.instantiate()
		get_node("Panel/map/markers").add_child(m_)
		m_.position = Vector2((player_position.x-xmin)*2,(player_position.y-ymin)*2)
		m_.cursor = get_node("Panel/cursor")
		m_.marker_type = Aeon.MapMarkerTypes.PLAYER
		$Panel/map/markers.youarehere = m_.get_index()
		m_.switch_sprite()
		translate_map_to_marker(m_.position)
	else:
		hide()
		is_open = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if $Panel/map/markers.get_child($Panel/map/markers.youarehere) != null:
			$Panel/map/markers.get_child($Panel/map/markers.youarehere).queue_free()
		
	

func _process(delta):
	pass
	#print($Panel/map.position)
	

func _on_marker_select(selection) -> void:
	match selection.marker_type if selection is Marker else 0:
		0: auxtext.text = ""
		1: auxtext.text = "Locked Door"
		2: auxtext.text = "Basic Chest"
		3: auxtext.text = "You Are Here"
		4: auxtext.text = "Stamp"
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_open:
		if !is_button_pressed_once:
			print(selection.marker_type)
			selection.on_click()
			is_button_pressed_once = true
	else:
		is_button_pressed_once = false
	#mapSprite.global_position += cursor.global_position-marker.global_position+Vector2(40,40) if is_selected else Vector2.ZERO
	
func _on_teleportation(pos) -> void:
	if pos is Vector2:
		player.position = pos
	
func translate_map_to_marker(marker_coords : Vector2):
	$Panel/map.position = original_pos - Vector2(marker_coords.x*7, marker_coords.y*7)
