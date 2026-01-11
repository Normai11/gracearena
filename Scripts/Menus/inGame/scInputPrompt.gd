extends Control
signal correct
signal incorrect

var evilParent

var disabled : bool = true
var prompt : Vector2 = Vector2(1, 0)
var childID : int = 0
var endlagTimer : float = -0.05

var movementTween : Tween
var colorTween : Tween

func _ready() -> void:
	$AnimationPlayer.play("add_child")
	if !disabled:
		enable()
	
	if prompt.x == 1:
		$image.frame = 1
	if prompt.x == -1:
		$image.frame = 0
	if prompt.y == 1:
		$image.frame = 3
	if prompt.y == -1:
		$image.frame = 2

func enable() -> void:
	disabled = false
	color_shift(true)
	movementTween = get_tree().create_tween()
	movementTween.set_ease(Tween.EASE_OUT)
	movementTween.set_trans(Tween.TRANS_EXPO)
	movementTween.tween_property($image, "scale", Vector2(0.75, 0.75), 1.5)

func prompt_triggered() -> void:
	disabled = true
	evilParent.next_prompt()
	$AnimationPlayer.play("queue_free")

func kill_tweens() -> void:
	if movementTween:
		movementTween.kill()

func color_shift(value : bool) -> void:
	if colorTween:
		colorTween.kill()
	colorTween = get_tree().create_tween()
	colorTween.set_ease(Tween.EASE_OUT)
	colorTween.set_trans(Tween.TRANS_CUBIC)
	
	if value:
		colorTween.tween_property($image, "modulate", Color("fff17b"), 0.3)
	else:
		colorTween.tween_property($image, "modulate", Color("b70505"), 0.2)

func _process(delta: float) -> void:
	size = custom_minimum_size
	
	if disabled == false:
		endlagTimer += delta
		if endlagTimer <= 0:
			return
	
	if Input.is_action_just_pressed("left") && !disabled:
		if prompt.x == -1:
			correct.emit()
		else:
			incorrect.emit()
			color_shift(false)
		prompt_triggered()
	elif Input.is_action_just_pressed("right") && !disabled:
		if prompt.x == 1:
			correct.emit()
		else:
			incorrect.emit()
			color_shift(false)
		prompt_triggered()
	elif Input.is_action_just_pressed("jump") && !disabled:
		if prompt.y == 1:
			correct.emit()
		else:
			incorrect.emit()
			color_shift(false)
		prompt_triggered()
	elif Input.is_action_just_pressed("down") && !disabled:
		if prompt.y == -1:
			correct.emit()
		else:
			incorrect.emit()
			color_shift(false)
		prompt_triggered()
