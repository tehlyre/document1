extends Node2D
class_name WordTracks

@export var train : WordTrain
@export var correct_room : Vector2i
@onready var origin_marker = $origin_marker
@onready var nonosquare = $NoNoSquare
@export var wall : Wall
var is_train : bool = false
var first_frame = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wall = get_parent().wall
	wall.sig_this_room.connect.call_deferred(_on_change_rooms)
	nonosquare.body_entered.connect(_on_nonosquare_enter)
	nonosquare.body_exited.connect(_on_nonosquare_exit)
	$TrainTimer.wait_time = 5
	$TrainTimer.start()
	$TrainTimer.timeout.connect(train_across_tracks)

func _on_change_rooms(room_coords, _coords):
	print(room_coords)
	if correct_room in room_coords:
		show()
		train.show()
		train.benign = false
		$TrainTimer.start()
	else:
		hide()
		train.hide()
		train.benign = true
		$TrainTimer.stop()

func _on_nonosquare_enter(body : Node2D):
	if body.is_in_group("player") or body.is_in_group("enemies"):
		body.collision_layer += 128
		body.collision_mask -= 32
		

func _on_nonosquare_exit(body : Node2D):
	if body.is_in_group("player") or body.is_in_group("enemies"):
		body.collision_mask += 32
		body.collision_layer -= 128

func train_across_tracks():
	$TrainTimer.stop()
	is_train = true

func restart_loop():
	is_train = false
	
	train.global_position = $origin_marker.global_position
	$TrainTimer.start()

func _process(_delta):
	if first_frame:
		_on_change_rooms(Aeon.room, "687")
		first_frame = false
	if is_train:
		train.velocity = Vector2(-30,0).rotated(rotation)
	else:
		train.velocity = Vector2.ZERO
	if (rotation > -PI/2 and rotation < PI/2) and train.caboose.global_position.x < $exotale_marker.global_position.x:
		restart_loop()
	elif is_equal_approx(rotation, PI/2) and train.caboose.global_position.y < $exotale_marker.global_position.y:
		#pass
		restart_loop()
	elif is_equal_approx(rotation, -PI/2) and train.caboose.global_position.y > $exotale_marker.global_position.y:
		#passk
		restart_loop()
	elif (rotation < -PI/2 or rotation > PI/2) and train.caboose.global_position.x > $exotale_marker.global_position.x:
		prints(train.caboose.global_position.x > $exotale_marker.global_position.x)
		restart_loop()
