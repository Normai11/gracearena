extends Control
signal completeMiss

enum direction {
	LEFT = -1,
	RIGHT = 1
}

@export var moveDirection : direction = direction.RIGHT
@export var moveSpeed : float = 55.5
@export var startingPos : Vector2 = Vector2(-96, 237)

func _ready() -> void:
	position = startingPos
	if moveDirection == direction.LEFT:
		$Texture.flip_h = true

func _process(delta: float) -> void:
	position.x += (moveDirection * moveSpeed) * delta
	if moveDirection == direction.RIGHT:
		if position.x >= 600:
			completeMiss.emit()
			noteHit()
	else:
		if position.x <= 600:
			completeMiss.emit()
			noteHit()

func noteHit() -> void:
	queue_free()
