extends Timer
class_name HBossMover

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var hboss : Sprite2D
@export var left : Sprite2D
@export var right : Sprite2D

enum MoveStates {
	NOT,
	LEFT,
	RIGHT
}

var move_state : MoveStates = MoveStates.NOT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeout.connect(_on_timeout)
	wait_time = rng.randf_range(1.6, 2.4)
	start()
	hboss.position = left.position

func _on_timeout():
	if hboss.position == left.position:
		hboss.position = right.position
	else:
		hboss.position = left.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
