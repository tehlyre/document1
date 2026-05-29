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
	PARENTHESES,
	BRACKETS,
	BRACES
}
enum AlignmentTypes {
	NONE,
	LEFT,
	CENTER,
	RIGHT,
}

enum PowerUpTypes {
	DMG_UP,
	DEF_UP,
	HEAL,
	COOLDOWN_CANCEL,
	BLANK,
	SPD_UP,
	DPS_UP,
	MULTISHOT
}

var player_inventory : Dictionary = {'keys':1, 'coins':0}
var equipped_abilities : Dictionary = {'q': PlayerAbilities.ALIGNMENT, "e" : PlayerAbilities.BRACKETS, "2" : PlayerAbilities.BRACES, "3" : PlayerAbilities.PARENTHESES}

var player_abilities_map : Dictionary = {
	PlayerAbilities.NONE : "None",
	PlayerAbilities.ALIGNMENT : "Alignment",
	PlayerAbilities.FONT_SIZE : "Font Size",
	PlayerAbilities.PARENTHESES : "Parentheses",
	PlayerAbilities.BRACKETS : "Brackets",
	PlayerAbilities.BRACES : "Curly Braces"
}

var name_map = {Aeon.Characters.DURDAN: "Durdan", Aeon.Characters.CELIA: "Celia", Aeon.Characters.JOSEPHUS: "Josephus"}
var room : Array

var STANDARD_BULLET_SIZE = Vector2(1.25, 1.25)

func bounded_by_rectangle(arg_ : Vector2, tleft : Vector2, bright : Vector2) -> bool:
	return arg_.x > tleft.x and arg_.y > tleft.y and arg_.x < bright.x and arg_.y < bright.y

func is_it_in_my_room(global_coords : Vector2):
	var roomies = Aeon.room
	roomies.sort_custom(func(a, b):
		if a.x == b.x:
			return a.y < b.y
		return a.x < b.x
	)
	return bounded_by_rectangle(global_coords, Vector2(roomies[0].x*2560, roomies[0].y*1440), Vector2(roomies[-1].x*2560+2560, roomies[-1].y*1440+1440))

func calculate_damage(raw_damage : float, def : int):
	var defense_adjusted_damage = raw_damage*500/(500+def)
	return defense_adjusted_damage
