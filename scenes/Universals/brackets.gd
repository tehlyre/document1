extends AnimatableBody2D

# Called when the node enters the scene tree for the first time.
var bracket_state : BracketStates = BracketStates.PRISTINE
var host

enum BracketStates {
	PRISTINE,
	CRACKED,
	BREAKING,
	SHATTERED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_host.call_deferred()

func set_host():
	host = get_parent().host

func smash():
	@warning_ignore("int_as_enum_without_cast")
	bracket_state += 1
	print(bracket_state)
	switch_sprite()

func shatter():
	bracket_state = BracketStates.SHATTERED

func switch_sprite():
	match bracket_state:
		BracketStates.PRISTINE:
			get_child(0).texture = preload("res://assets/textures/bracket.png")
		BracketStates.CRACKED:
			get_child(0).texture = preload("res://assets/textures/bracket_1.png")
		BracketStates.BREAKING:
			get_child(0).texture = preload("res://assets/textures/bracket_3.png")
		BracketStates.SHATTERED:
			queue_free()
