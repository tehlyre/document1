extends AnimatableBody2D


# Called when the node enters the scene tree for the first time.
var bracket_state : BracketStates = BracketStates.PRISTINE

enum BracketStates {
	PRISTINE,
	CRACKED,
	BREAKING,
	SHATTERED
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func smash():
	@warning_ignore("int_as_enum_without_cast")
	bracket_state += 1
	switch_sprite()

func shatter():
	bracket_state = BracketStates.SHATTERED

func switch_sprite():
	match bracket_state:
		#BracketStates.PRISTINE:
			#$potSprite.texture = preload("res://assets/textures/pot_pristine.png")
		#BracketStates.CRACKED:
			#$potSprite.texture = preload("res://assets/textures/pot_cracked.png")
		#BracketStates.BREAKING:
			#$potSprite.texture = preload("res://assets/textures/pot_breaking.png")
		BracketStates.SHATTERED:
			queue_free()
