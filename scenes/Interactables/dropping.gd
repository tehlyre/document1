extends Area2D
class_name PowerUp

var power_up_type : Aeon.PowerUpTypes = Aeon.PowerUpTypes.HEAL
@onready var sprite = $Sprite2D

var put_sprite_dictionary : Dictionary = {
	Aeon.PowerUpTypes.DMG_UP: preload("res://assets/textures/power_ups/atk_up.png"),
	Aeon.PowerUpTypes.DEF_UP: preload("res://assets/textures/power_ups/def_up.png"),
	Aeon.PowerUpTypes.HEAL: preload("res://assets/textures/power_ups/heal.png"),
}

func _init():
	print(put_sprite_dictionary[power_up_type], "qi-jpaijpijfpoiqj")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_sprite()
	body_entered.connect(_on_body_entered)


func set_sprite():
	sprite.texture = put_sprite_dictionary[power_up_type]
	

func _on_body_entered(body):
	print("iejfe")
	if body is Player:
		body.pick_up(self)
