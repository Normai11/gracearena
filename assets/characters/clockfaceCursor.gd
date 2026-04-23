extends Control

@export var maxLifetime : float = 0.65

var mainTweener : Tween
var curLifetime : float = 0

func _ready() -> void:
	scale = Vector2(5, 5)
	mainTweener = get_tree().create_tween()
	mainTweener.set_ease(Tween.EASE_OUT)
	mainTweener.set_trans(Tween.TRANS_ELASTIC)
	mainTweener.tween_property(self, "scale", Vector2.ONE, 0.3)
	mainTweener.set_parallel()
	mainTweener.tween_property(self, "rotation_degrees", 359, 0.4)
	mainTweener.set_ease(Tween.EASE_IN)
	mainTweener.set_trans(Tween.TRANS_EXPO)
	mainTweener.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.6)

func _process(delta: float) -> void:
	curLifetime += delta
	if curLifetime >= maxLifetime:
		queue_free()
