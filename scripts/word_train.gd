extends Area2D
class_name WordTrain

@onready var caboose : Marker2D = $caboose
var velocity : Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : PhysicsBody2D):
	if body.is_in_group("player"):
		body.thingy_damage(50)
		body.move_a_little_over(rotation)

func _process(_delta: float) -> void:
	position += velocity
