extends Control
signal skillcheckComplete

@export var noteIntervalRange : Vector2 = Vector2(0.35, 2)
var intervalTimerL : float = 1.0
var intervalTimerR : float = 1.35
@export var noteHitEscape : int = 25
var currentHits : int = 0

@onready var noteInstance = preload("res://Scenes/Objects/skillcheckPulseNote.tscn")
@onready var progressHealth : TextureProgressBar = $playerHealth
@onready var progressRecover : TextureProgressBar = $recoverProgress
@onready var sideL: Area2D = $HEART/sideL
@onready var sideR: Area2D = $HEART/sideR
@onready var earlyL: Area2D = $HEART/sideL/Early
@onready var earlyR: Area2D = $HEART/sideR/Early

var skeletron : CharacterBody2D
var recoverTween : Tween
var healthTween : Tween
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var readyNotes : Array[bool] = [false, false]

func _ready() -> void:
	skeletron = get_parent().get_parent().get_parent()
	
	progressRecover.max_value = noteHitEscape
	progressRecover.value = currentHits
	progressHealth.value = skeletron.target.health
	$animMaster.play("add_child")

func _input(event: InputEvent) -> void:
	#if Input.is_key_pressed(KEY_ENTER):
		#var instantiate = noteInstance.instantiate()
		#add_child(instantiate)
	
	if Input.is_action_just_pressed("left"):
		if readyNotes[0]:
			for note in sideL.get_overlapping_areas():
				note.get_parent().noteHit()
				note_check()
			return
		if earlyL.has_overlapping_areas():
			var notes = earlyL.get_overlapping_areas()
			notes[0].get_parent().noteHit()
			note_check(false)
	elif Input.is_action_just_pressed("right"):
		if readyNotes[1]:
			for note in sideR.get_overlapping_areas():
				note.get_parent().noteHit()
				note_check()
			return
		if earlyR.has_overlapping_areas():
			var notes = earlyR.get_overlapping_areas()
			notes[0].get_parent().noteHit()
			note_check(false)

func _process(delta: float) -> void:
	intervalTimerL -= delta
	intervalTimerR -= delta
	if intervalTimerL <= 0:
		intervalTimerL = randf_range(noteIntervalRange.x, noteIntervalRange.y)
		spawn_note(-1)
	if intervalTimerR <= 0:
		intervalTimerR = randf_range(noteIntervalRange.x, noteIntervalRange.y)
		spawn_note(1)

func spawn_note(dir : int) -> void:
	var instantiate = noteInstance.instantiate()
	
	if dir == -1:
		instantiate.moveDirection = -1
		instantiate.startingPos.x = 1294
	else:
		instantiate.moveDirection = 1
	instantiate.completeMiss.connect(note_check.bind(false))
	
	add_child(instantiate)

func note_check(hit : bool = true) -> void:
	if hit:
		currentHits += 1
		if currentHits >= noteHitEscape:
			skillcheckComplete.emit()
	else:
		currentHits -= 2
		if currentHits <= 0:
			currentHits = 0
		skeletron.target.health -= 8
		skeletron.target.guiScene.update_health()
		apply_health_tween()
	apply_recovery_tween()

func apply_recovery_tween() -> void:
	if recoverTween:
		recoverTween.kill()
	recoverTween = get_tree().create_tween()
	
	recoverTween.set_ease(Tween.EASE_OUT)
	recoverTween.set_trans(Tween.TRANS_CIRC)
	recoverTween.tween_property(progressRecover, "value", currentHits, 0.25)

func apply_health_tween() -> void:
	if healthTween:
		healthTween.kill()
	healthTween = get_tree().create_tween()
	
	healthTween.set_ease(Tween.EASE_OUT)
	healthTween.set_trans(Tween.TRANS_CIRC)
	healthTween.tween_property(progressHealth, "value", skeletron.target.health, 0.25)

func _sideL_detection(area: Area2D) -> void:
	readyNotes[0] = true

func _sideL_release(area: Area2D) -> void:
	readyNotes[0] = false

func _sideR_detection(area: Area2D) -> void:
	readyNotes[1] = true

func _sideR_release(area: Area2D) -> void:
	readyNotes[1] = false
