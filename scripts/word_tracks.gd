extends Node2D
class_name WordTracks

@export var train : WordTrain
@export var correct_room : Vector2i
@onready var origin_marker = $origin_marker
var is_train : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TrainTimer.wait_time = 5
	$TrainTimer.start()
	$TrainTimer.timeout.connect(train_across_tracks)


func train_across_tracks():
	$TrainTimer.stop()
	is_train = true

func restart_loop():
	is_train = false
	
	train.global_position = $origin_marker.global_position
	$TrainTimer.start()

func _process(_delta):
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
