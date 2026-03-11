extends Node2D


@onready var lparen : Area2D = $leftParen
@onready var rparen : Area2D = $rightParen
var rng : RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rot_rand = rng.randi_range(0,3)*PI/4
	rotate(rot_rand)
	lparen.body_entered.connect(_on_paren_body_connect)
	rparen.body_entered.connect(_on_paren_body_connect)
	#await get_tree().create_timer(0.5).timeout
	close_parentheses()

func close_parentheses():
	var ltween = create_tween()
	var rtween = create_tween()
	ltween.tween_property(lparen, "position:x", -20, 0.25)
	rtween.tween_property(rparen, "position:x", 20, 0.25)
	await ltween.finished
	await get_tree().create_timer(0.25).timeout
	queue_free()

func _on_paren_body_connect(body):
	if(body.is_in_group("enemies")):
		body.thingy_damage(100/body.DAMAGE_SCALE)
	elif(body.is_in_group("player")):
		body.thingy_damage(10)
	elif(body.is_in_group("walls")):
		pass
	elif(body.is_in_group("breakables")):
		body.shatter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
