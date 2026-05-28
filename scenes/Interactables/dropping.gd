extends Area2D
class_name PowerUp

var power_up_type : Aeon.PowerUpTypes = Aeon.PowerUpTypes.DEF_UP
@onready var sprite = $Sprite2D

var put_sprite_dictionary : Dictionary = {
	Aeon.PowerUpTypes.DMG_UP: preload("res://assets/textures/power_ups/atk_up.png"),
	Aeon.PowerUpTypes.DEF_UP: preload("res://assets/textures/power_ups/def_up.png"),
	Aeon.PowerUpTypes.HEAL: preload("res://assets/textures/power_ups/heal.png"),
}

func _init():
	power_up_type = Aeon.PowerUpTypes.DEF_UP
	print(put_sprite_dictionary[power_up_type], "qi-jpaijpijfpoiqj")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(put_sprite_dictionary[power_up_type], "qi-jpaijpijfpoiqj")
	set_sprite()


func set_sprite():
	sprite.texture = put_sprite_dictionary[power_up_type]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
