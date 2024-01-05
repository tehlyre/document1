extends Node2D

var player : CharacterBody2D
var enemyhandles : Node2D
var body : CharacterBody2D
@onready var raycasts : Node2D = $RayCasts
@onready var primaryraycast : RayCast2D = $RayCasts/PrimaryRayCast
@onready var playerraycast : RayCast2D = $RayCasts/PlayerRayCast
var handles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func readyy():
	handles = enemyhandles.get_children()
	playerraycast.player = player
	primaryraycast.body = body
	primaryraycast.connect("wall_in_front", wall_in_front)
	primaryraycast.connect("wall_not_in_front", wall_not_in_front)
	playerraycast.connect("player_clear", player_clear)
	

func wall_in_front():
	body.redirect = true
	body.target = handles[0]

func sort_closest_Marker2D(a : Marker2D,b : Marker2D):
	return position.distance_squared_to(a.position) < position.distance_squared_to(b.position)

func wall_not_in_front():
	if !body.redirect:
		body.redirect = false
		body.target = player

func player_clear():
	body.redirect = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = body.global_position
	handles = enemyhandles.get_children()
	handles.sort_custom(sort_closest_Marker2D)
	if abs(position.x-body.target.position.x) < 4 and abs(position.y-body.target.position.y) < 4:
		body.target = handles[1]
