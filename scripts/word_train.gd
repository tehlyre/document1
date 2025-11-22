extends Area2D
class_name WordTrain

@onready var caboose : Marker2D = $caboose
var velocity : Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : PhysicsBody2D):
	if body.is_in_group("player"):
		#body.thingy_damage(50)
		print((body.global_position-global_position).rotated(-rotation))
		if (body.global_position-global_position).rotated(-rotation).y > 0:
			body.move_a_little_over(rotation, false)
		else:
			body.move_a_little_over(rotation, true)
	elif body.is_in_group("enemy"):
		body.thingy_damage(100/body.DAMAGE_SCALE)


func _process(_delta: float) -> void:
	position += velocity
