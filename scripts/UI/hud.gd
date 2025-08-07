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

# Called on startup. Prints the players inventory for debugging purposes.
func _ready() -> void:
	game_manager = get_tree().get_root().get_node("gameManager")
	$playerHealthBar.value = 100.0
