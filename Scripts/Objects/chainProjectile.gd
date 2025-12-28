extends CharacterBody2D

var startingPos : Vector2 = Vector2.ZERO

@export var maxHit : int = 2
var hits : int = 0
@export var speed : float = 1000.0
@export var direction : int = 1
@export var dmg : float = 50.0

func _ready() -> void:
	position = startingPos

func _physics_process(delta: float) -> void:
	velocity.x = speed * direction
	move_and_slide()
	if is_on_wall():
		queue_free()

func _killzone_detect(body: Node) -> void:
	if body is Enemy:
		body.damage_by(dmg, direction)
		hits += 1
		if hits == maxHit:
			queue_free()
