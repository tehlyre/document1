extends Area2D
class_name WordTrain

@onready var caboose : Marker2D = $caboose
var velocity : Vector2 = Vector2.ZERO
var benign : bool

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : PhysicsBody2D):
	print("tioinoinoinoin")
	if !benign:
		if body.is_in_group("player"):
			#body.thingy_damage(50)
			print((body.global_position-global_position).rotated(-rotation))
			if (body.global_position-global_position).rotated(-rotation).y > 0:
				body.thingy_large_push(rotation, false)
			else:
				body.thingy_large_push(rotation, true)
		elif body.is_in_group("enemy"):
			body.thingy_damage(100/body.DAMAGE_SCALE)
		elif body.is_in_group("bullet"):
			body.queue_free()


func _process(_delta: float) -> void:
	position += velocity
