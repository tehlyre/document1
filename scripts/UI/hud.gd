extends Control

# Object: Deals with all HUDlum things like the healthbar. Currently only deals with the healthbar.
#
# Variables:
# CharacterBody2D player: Pointer to the player node.
#
# Functions:
# void _process(float _delta): Called every frame. Updates healthbar.

@export var player : CharacterBody2D

# Function void _process(float _delta)
# Called every frame give or take. Updates the healthbar's value to whatever the player's health is so long as the
# player exists.
func _process(_delta : float):
	if is_instance_valid(player):
		$playerhealth.value = player.health
