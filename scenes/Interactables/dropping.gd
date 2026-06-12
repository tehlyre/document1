extends Area2D
class_name PowerUp

var power_up_type : Aeon.PowerUpTypes = Aeon.PowerUpTypes.HEAL
@onready var sprite

var put_sprite_dictionary : Dictionary = {
	Aeon.PowerUpTypes.DMG_UP: preload("res://assets/textures/power_ups/atk_up.png"),
	Aeon.PowerUpTypes.DEF_UP: preload("res://assets/textures/power_ups/def_up.png"),
	Aeon.PowerUpTypes.HEAL: preload("res://assets/textures/power_ups/heal.png"),
}


	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(power_up_type, "qi-jpaijpijfpoiqj")
	print(get_children())
	set_sprite()
	body_entered.connect(_on_body_entered)


func set_sprite():
	sprite = Sprite2D.new()
	sprite.scale = Vector2(0.5, 0.5)
	var c_ = CollisionShape2D.new()
	add_child(sprite)
	add_child(c_)
	
	sprite.texture = put_sprite_dictionary[power_up_type]
	

func _on_body_entered(body):
	print("iejfe")
	if body is Player:
		body.pick_up(self)
