extends AnimatableBody2D

# Called when the node enters the scene tree for the first time.
var bracket_visual_state : BracketVisualStates = BracketVisualStates.PRISTINE
var host
var hits_until_broken : int = 10

enum BracketVisualStates {
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
	hits_until_broken -= 1
	set_visual_state()
	switch_sprite()

func set_visual_state():
	if hits_until_broken == 10:
		bracket_visual_state = BracketVisualStates.PRISTINE
	elif hits_until_broken >= 5 and hits_until_broken < 10:
		bracket_visual_state = BracketVisualStates.CRACKED
	elif hits_until_broken > 0 and hits_until_broken < 5:
		bracket_visual_state = BracketVisualStates.BREAKING
	elif hits_until_broken == 0:
		bracket_visual_state = BracketVisualStates.SHATTERED

func shatter():
	bracket_visual_state = BracketVisualStates.SHATTERED

func switch_sprite():
	match bracket_visual_state:
		BracketVisualStates.PRISTINE:
			get_child(0).texture = preload("res://assets/textures/bracket.png")
		BracketVisualStates.CRACKED:
			get_child(0).texture = preload("res://assets/textures/bracket_1.png")
		BracketVisualStates.BREAKING:
			get_child(0).texture = preload("res://assets/textures/bracket_3.png")
		BracketVisualStates.SHATTERED:
			queue_free()
