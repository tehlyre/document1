extends Timer
class_name HBossFire


@export var mover : HBossMover

@export var gun_root : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mover.did_move.connect(_on_did_move)

func _on_did_move(_number):
	for i in gun_root.get_children():
		print("q")
		i.fire()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
