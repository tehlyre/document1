extends StaticBody2D

class_name h_Chest

@export var interaction_boundary : Area2D
@export var contents : String
var parsed = {}
var interactable : bool = false
@export var ID : int
var interactionID
var opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	contents += ','
	interactionID = "chest" + str(ID)
	parse_contents()

func parse_contents():
	var skip = false
	var key = ''
	var number = ""
	var index = 0
	for i in contents:
		print(i)
		if not skip:
			if i == 'k':
				key = 'keys'
				skip = true
			elif i == 'c':
				key = 'coins'
				skip = true
			elif i == ':':
				pass
			elif i in "1234567890":
				number += i
			elif i == ",":
				parsed[key] = int(number)
				skip = false
				key = ''
				number = ''
		elif skip:
			if i in "abcdefghijklmnopqrstuvwxyz":
				if contents[index+1] == ':':
					skip = false
		index += 1

func open():
	print("openous intentions")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if opened:
		queue_free()
	#print(interactionID)
