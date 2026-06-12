extends CanvasLayer

# Heads Up Display Script
#
# Object: To serve the game's heads-up display (HUD) with health and inventory information.
#
# Node Structure:
# hud 
# |_ playerHealthBar: ProgressBar that represents the health of the player.
# |_ playerInventory: Control of labels that represent the inventory of the player.
#    |_ keys: Label that describes the amount of keys the player has.
#    |_ coins: Label that describes the amount of coins the player has.
#
# GLOBAL VARIABLES
#
# @export Player player: Pointer to the player.
@export var player : Player

# @export GameManager game_manager: Pointer to the gameManager root node.
var game_manager : GameManager
@onready var ztargeticon = $hudRoot/ZTarget
@onready var special_progress_map : Dictionary = {
	"special_q" : $hudRoot/playerAbilities/q/cooldown,
	"special_e" : $hudRoot/playerAbilities/e/cooldown,
	"special_2" : $hudRoot/playerAbilities/s2/cooldown,
	"special_3" : $hudRoot/playerAbilities/s3/cooldown,
}

# Called on startup. Prints the players inventory for debugging purposes.
func _ready() -> void:
	game_manager = get_tree().get_root().get_node("gameManager")
	$hudRoot/ZTarget.hide()
	$hudRoot/playerHealthBar.value = 100.0

func _process(_delta : float) -> void:
	$hudRoot/playerInventory/keys.text = "Keys: x"+str(int(Aeon.player_inventory['keys']))
	$hudRoot/playerInventory/coins.text = "Coins: "+str(int(Aeon.player_inventory['coins']))
	$hudRoot/playerAbilities/q.text = "Q: "+Aeon.player_abilities_map[Aeon.equipped_abilities["special_q"]]
	$hudRoot/playerAbilities/e.text = "E: "+Aeon.player_abilities_map[Aeon.equipped_abilities["special_e"]]
	$hudRoot/playerAbilities/s2.text = "2: "+Aeon.player_abilities_map[Aeon.equipped_abilities["special_2"]]
	$hudRoot/playerAbilities/s3.text = "3: "+Aeon.player_abilities_map[Aeon.equipped_abilities["special_3"]]
