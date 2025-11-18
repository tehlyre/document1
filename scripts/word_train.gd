extends Node2D


var is_train : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TrainTimer.wait_time = 1
	$TrainTimer.start()
	$TrainTimer.timeout.connect(train_across_tracks)


func train_across_tracks():
	is_train = true

func _process(delta):
	if is_train:
		$CharacterBody2D.velocity.x = -1000
	else:
		$CharacterBody2D.velocity.x = 0
	$CharacterBody2D.move_and_slide()
	if $CharacterBody2D.position.x < -375:
		is_train = false
