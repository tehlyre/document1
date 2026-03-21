extends Node2D
class_name Melee

var starting_rotation
@onready var rotate_marker = $el_marcador
@onready var damage_area = $el_marcador/Area2D
var is_attacking : bool = false
signal attack_done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	damage_area.body_entered.connect(_on_body_entered)
	attack_done.emit()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.thingy_damage(100/body.DAMAGE_SCALE)

func attack():
	if !is_attacking:
		is_attacking = true
		show()
		starting_rotation = $el_marcador.rotation
		var tweenr = get_tree().create_tween()
		tweenr.tween_property($el_marcador, "rotation", starting_rotation+5*PI/4, 0.1)
		await tweenr.finished
		await get_tree().create_timer(0.05).timeout
		hide()
		$el_marcador.rotation = starting_rotation
		is_attacking = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
