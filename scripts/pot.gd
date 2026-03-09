extends StaticBody2D

var pot_state : PotStates = PotStates.PRISTINE

enum PotStates {
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
	pot_state += 1
	switch_sprite()

func shatter():
	pot_state = PotStates.SHATTERED

func switch_sprite():
	match pot_state:
		PotStates.PRISTINE:
			$potSprite.texture = preload("res://assets/textures/pot_pristine.png")
		PotStates.CRACKED:
			$potSprite.texture = preload("res://assets/textures/pot_cracked.png")
		PotStates.BREAKING:
			$potSprite.texture = preload("res://assets/textures/pot_breaking.png")
		PotStates.SHATTERED:
			queue_free()
