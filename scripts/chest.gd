extends StaticBody2D

class_name Interactable

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
# @export Area2D interaction_area: Pointer to $chestInteractionArea
@export var interaction_area : Area2D

# @export String contents: The contents of the chest in an easy-to-parse string.
@export var contents : String

# Dictionary parsed: A helper variable that parses the contents string of the chest.
var parsed : Dictionary = {}

# @export int ID: The id number for the thing, based on how many things there are.
@export var ID : int

# interactionID: The id of the thing, based on the name of the thing plus ID.
var interactionID : String

# bool is_opened: Whether or not the chest is opened.
var is_opened : bool = false

# Called when the node is instantiated. Adds a comma to the contents string to make things easier,
# then creates the interactionID and calls for the contents to be parsed.
func _ready() -> void:
	#contents += ','
	interactionID = "chest" + str(ID)
	parsed = JSON.parse_string(contents)
	print(parsed)

## Called on ready to parse the easy to type in string contents into easy-to-read parsed content. I
## got lazy, and so the parser reads the first letter, identifies what the item is, and then skips to
## the nearest colon, skips it, and reads the number of that item, then reads a comma, and goes to 
## next item.
#func parse_contents() -> void:
	#var skip : bool = false
	#var key : String = ""
	#var number : String = ""
	#var index : int = 0
	#for i in contents:
		#print(i)
		#if not skip:
			#if i == 'k':
				#key = 'keys'
				#skip = true
			#elif i == 'c':
				#key = 'coins'
				#skip = true
			#elif i == ':':
				#pass
			#elif i in "1234567890":
				#number += i
			#elif i == ",":
				#parsed[key] = int(number)
				#skip = false
				#key = ''
				#number = ''
		#elif skip:
			#if i in "abcdefghijklmnopqrstuvwxyz":
				#if contents[index+1] == ':':
					#skip = false
		#index += 1

# Called every frame. Detects if the chest is opened or not. If so, it promptly deletes itself.
func _process(delta) -> void:
	if is_opened:
		queue_free()
