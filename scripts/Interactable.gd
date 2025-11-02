extends StaticBody2D
class_name Interactable

# @export Area2D interaction_area: Pointer to $chestInteractionArea
@export var interaction_area : Area2D

# @export int ID: The id number for the thing, based on how many things there are.
@export var ID : int

# interactionID: The id of the thing, based on the name of the thing plus ID.
var interactionID : String

var interactable_type = ""

var send_to

func init(type : String):
	interactionID = type + str(ID)
	interactable_type = type
