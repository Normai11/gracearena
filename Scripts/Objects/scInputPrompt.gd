extends Control
signal correct
signal incorrect

var evilParent

var disabled : bool = true
var missed : bool = false
var prompt : Vector2 = Vector2(1, 0)
var childID : int = 0
var endlagTimer : float = -0.05

var activeTweens : Array[bool] = [false, false]
var movementTween : Tween
var colorTween : Tween

func kill_tweens() -> void:
	if movementTween:
		movementTween.kill()
	if colorTween:
		colorTween.kill()

func reset_activeTweens_value(slot : int) -> void:
	activeTweens[slot] = false

func apply_miss() -> void:
	if missed:
		color_shift(false)

func _ready() -> void:
	if !disabled:
		enable()
	# this bug with tweens is really annoying and i dont know how to fix it
	# the bug occurs whenever skeletron grabs the player and releases them for the input skillcheck
	# i wanna rip my hair out :((((
	#movementTween = get_tree().create_tween()
	#movementTween.kill()
	#colorTween = get_tree().create_tween()
	#colorTween.kill()
	
	$AnimationPlayer.play("add_child")
	
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
	activeTweens[0] = true
	if movementTween:
		movementTween.kill()
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	movementTween = get_tree().create_tween()
	movementTween.set_ease(Tween.EASE_OUT)
	movementTween.set_trans(Tween.TRANS_EXPO)
	movementTween.tween_property($image, "scale", Vector2(0.6, 0.6), 1.5)
	movementTween.connect("finished", reset_activeTweens_value.bind(0))
	color_shift(true)

func prompt_triggered() -> void:
	disabled = true
	evilParent.next_prompt()
	$AnimationPlayer.play("queue_free")

func color_shift(value : bool) -> void:
	activeTweens[1] = true
	if colorTween:
		colorTween.kill()
	
	if value:
		colorTween = get_tree().create_tween()
		colorTween.set_ease(Tween.EASE_OUT)
		colorTween.set_trans(Tween.TRANS_CUBIC)
		colorTween.tween_property($image, "modulate", Color("3ee4ff"), 0.3)
		colorTween.connect("finished", reset_activeTweens_value.bind(1))
	else:
		colorTween = get_tree().create_tween()
		colorTween.set_ease(Tween.EASE_OUT)
		colorTween.set_trans(Tween.TRANS_CUBIC)
		colorTween.tween_property($image, "modulate", Color("b70505"), 0.2)
		colorTween.connect("finished", reset_activeTweens_value.bind(1))

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
			missed = true
		prompt_triggered()
	elif Input.is_action_just_pressed("right") && !disabled:
		if prompt.x == 1:
			correct.emit()
		else:
			incorrect.emit()
			missed = true
		prompt_triggered()
	elif Input.is_action_just_pressed("jump") && !disabled:
		if prompt.y == 1:
			correct.emit()
		else:
			incorrect.emit()
			missed = true
		prompt_triggered()
	elif Input.is_action_just_pressed("down") && !disabled:
		if prompt.y == -1:
			correct.emit()
		else:
			incorrect.emit()
			missed = true
		prompt_triggered()
