extends Area2D
class_name WordTrain

@onready var caboose : Marker2D = $caboose
var velocity : Vector2 = Vector2.ZERO
@onready var charbody : StaticBody2D = $TrainCharacterBody
var benign : bool:
	get:
		return benign
	set(ib):
		if ib:
			charbody.collision_layer -= 32
			charbody.collision_mask -= 4
		elif !ib:
			charbody.collision_layer += 32
			charbody.collision_mask += 4

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : PhysicsBody2D):
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


func _process(_delta: float) -> void:
	print(charbody.collision_layer)
	position += velocity
