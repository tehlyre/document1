extends Interactable

class_name Chest

# Handler for Chest Contents
#
# Object:
# To make it easier to add contents to chests and to streamline the process probably.
#
# Node Structure:
# StaticBody2D chest
# |_ chestSprite: Sprite2D for the chest.
# |_ chestInteractionArea: Area2D in which the player can interact with the chest.
# |_ chestCollider: CollisionShape2D for the chest.
#
# GLOBAL VARIABLES
#



# @export String contents: The contents of the chest in an easy-to-parse string.
@export var contents : String

# Dictionary parsed: A helper variable that parses the contents string of the chest.
var parsed : Dictionary = {}



# bool is_opened: Whether or not the chest is opened.
var is_opened : bool = false

# Called when the node is instantiated. Adds a comma to the contents string to make things easier,
# then creates the interactionID and calls for the contents to be parsed.
func _ready() -> void:
	init("chest")
	parsed = JSON.parse_string(contents) if contents else {"keys": 0, "coins": 0}
	#print(parsed)

# Called every frame. Detects if the chest is opened or not. If so, it promptly deletes itself.
func _process(_delta : float) -> void:
	if is_opened:
		queue_free()
