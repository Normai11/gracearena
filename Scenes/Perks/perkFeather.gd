extends Perk

@onready var texture = $Display

func _ready() -> void:
	super._ready()
	playerParent.inputHandler.maxJumps += 1

#func _process(_delta: float) -> void:
	#texture.size = lerp(texture.size, Vector2(80, 80), 0.5)
