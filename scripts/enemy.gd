extends Node2D


@onready var body : CharacterBody2D = $EnemyBody
@onready var soul : Node2D = $EnemySoul
var player : CharacterBody2D
var enemyhandles : Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func readyy():
	body.player = player
	soul.enemyhandles = enemyhandles
	soul.body = body
	soul.player = player
	soul.readyy()
	body.readyy()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
