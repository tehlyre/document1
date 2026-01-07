extends Sprite2D
class_name Gun

# IMPORTS
#
#
# PackedScene Bullet: The scene for the bullet that is fired off by the player
var bullet : PackedScene
@export var bullet_type : Aeon.BulletTypes
var original_rotation : float
#
#
# FLAGS
@export var is_on_player : bool
var is_in_illinois : bool = false

var bullet_sprite_map = {Aeon.BulletTypes.NONE: "", Aeon.BulletTypes.BASIC: preload("res://scenes/Universals/bullet.tscn"), Aeon.BulletTypes.RICOCHET: preload("res://scenes/Universals/ricochet_bullet.tscn")}

func _ready() -> void:
	bullet = bullet_sprite_map[bullet_type]
	$noGunZone.body_entered.connect(_on_noGunZone_body_entered)
	$noGunZone.body_exited.connect(_on_noGunZone_body_exited)
	original_rotation = rotation

func _on_noGunZone_body_entered(_body : Node2D) -> void:
	print("currently gooning")
	is_in_illinois = true

func _on_noGunZone_body_exited(_body : Node2D) -> void:
	is_in_illinois = false

# This function instantiates a bullet scene from the firing point every time the entity desires to 
# fire and directs it in the direction the marker is facing. It has no adjustment function
func fire() -> void:
	if !is_in_illinois:
		var b_ = bullet.instantiate()
		b_.firee = owner
		if is_on_player:
			owner.get_parent().find_child("Bullets").add_child(b_)
		else:
			owner.get_parent().owner.find_child("Bullets").add_child(b_)
		b_.transform = $gunner.global_transform
		b_.global_scale = Aeon.STANDARD_BULLET_SIZE


# Called every frame to adjust the (player's) gun so that when fired, the bullets pass through the
# cursor. The algorithm is mostly just magic, but it works. It stops attempting to adjust when the
# cursor gets within 112 pixels, which was tested to be a reasonable distance. This was literally
# made with a teensy bit of precalculus and a lot of trial and error.
func adjust(point : Vector2) -> void:
	var d = global_position.distance_to(point)
	if d > 112:
		look_at(point)
		#rotation = -(total_angle_on_gun-angle_on_gun)

func reset_adjustment() -> void:
	rotation = original_rotation

func get_proper_adjustment(point : Vector2) -> float:
	return get_angle_to(point)
