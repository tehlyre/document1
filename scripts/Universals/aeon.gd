extends Node

enum Characters {
	DURDAN,
	CELIA,
	JOSEPHUS
}

enum MapMarkerTypes {
	NONE,
	DOOR,
	CHEST,
	PLAYER,
	STAMP
}

enum BulletTypes {
	NONE,
	BASIC,
	RICOCHET
}

enum PlayerAbilities {
	NONE,
	ALIGNMENT,
	FONT_SIZE,
	PARENTHESES
}
enum AlignmentTypes {
	NONE,
	LEFT,
	CENTER,
	RIGHT,
}

var player_inventory : Dictionary = {'keys':1, 'coins':0}
var equipped_abilities : Dictionary = {'q': PlayerAbilities.ALIGNMENT, "e" : PlayerAbilities.PARENTHESES}

var player_abilities_map : Dictionary = {PlayerAbilities.NONE : "None", PlayerAbilities.ALIGNMENT : "Alignment", PlayerAbilities.FONT_SIZE : "Font Size", PlayerAbilities.PARENTHESES : "Parantheses"}

var name_map = {Aeon.Characters.DURDAN: "Durdan", Aeon.Characters.CELIA: "Celia", Aeon.Characters.JOSEPHUS: "Josephus"}
var room : Array

var STANDARD_BULLET_SIZE = Vector2(1.25, 1.25)

# Called when the node enters the scene tree for the first time.
