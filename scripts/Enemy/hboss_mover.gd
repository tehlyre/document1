extends Timer
class_name HBossMover

var rng : RandomNumberGenerator = RandomNumberGenerator.new()
@export var hboss : CharacterBody2D
@export var left : Sprite2D
@export var right : Sprite2D
@export var fire : HBossFire
enum MoveStates {
	NOT,
	LEFT,
	RIGHT
}

var move_state : MoveStates = MoveStates.NOT
signal did_move(state : MoveStates)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timeout.connect(_on_timeout)
	wait_time = 2.0
	start()
	hboss.position = left.position
	move_state = MoveStates.LEFT

func _on_timeout():
	stop()
	if hboss.position == left.position:
		hboss.position = right.position
		move_state = MoveStates.RIGHT
	else:
		hboss.position = left.position
		move_state = MoveStates.LEFT
	did_move.emit(move_state)
	print("aqpierhfpio")
	start()

func flip():
	hboss.rotation = hboss.rotation + PI/2

func rotate_cw():
	hboss.rotation = hboss.rotation + PI/4

func rotate_ccw():
	hboss.rotation = hboss.rotation - PI/4

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
