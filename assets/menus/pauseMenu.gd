extends Control
signal resumed

var menuSettings = preload("res://Scenes/Menus/Main/settingsMenu.tscn")
var existingMenu : Control

@onready var backdrop = $menuBackdrop
@onready var overlay = $bgOverlay
@onready var menuOptions = $MENU
@onready var timerLabel = $MENU/timer

var baseTween : Tween
var modulateTween : Tween

func _ready() -> void:
	get_tree().paused = true
	baseTween = get_tree().create_tween()
	baseTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	backdrop.scale.x = 0.01
	
	baseTween.set_ease(Tween.EASE_OUT)
	baseTween.set_trans(Tween.TRANS_EXPO)
	baseTween.tween_property(backdrop, "scale", Vector2(1, 1), 0.5)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):\
		_resume_game()

func _process(_delta: float) -> void:
	if existingMenu:
		for button in menuOptions.get_children():
			if button is Button:
				button.mouse_filter = 2
	else:
		for button in menuOptions.get_children():
			if button is Button:
				button.mouse_filter = 0
	
	if DataStore.timer > 0:
		var minutes = int(DataStore.timer / 60)
		var seconds = DataStore.timer - minutes * 60
		timerLabel.text = '%01d:%02d' % [minutes, seconds]
	else:
		timerLabel.text = "OVER"

func _resume_game() -> void:
	get_viewport().gui_release_focus()
	resumed.emit()
	
	if baseTween:
		baseTween.kill()
	baseTween = get_tree().create_tween()
	modulateTween = get_tree().create_tween()
	modulateTween.set_parallel(true)
	baseTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	modulateTween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	baseTween.set_ease(Tween.EASE_OUT)
	baseTween.set_trans(Tween.TRANS_EXPO)
	baseTween.tween_property(backdrop, "scale", Vector2(0, 1), 0.3)
	baseTween.finished.connect(kill_menu)
	
	modulateTween.set_ease(Tween.EASE_OUT)
	modulateTween.set_trans(Tween.TRANS_EXPO)
	modulateTween.tween_property(menuOptions, "modulate", Color("ffffff00"), 0.25)
	modulateTween.tween_property(overlay, "modulate", Color("ffffff00"), 0.25)
	
	get_tree().paused = false

func kill_menu() -> void:
	queue_free()

func _quit_run() -> void:
	get_tree().paused = false
	var loadingPath = load("res://Scenes/Menus/loadingScreen.tscn")
	Global.loadfinishPath = "res://Scenes/Menus/Main/MainMenu.tscn"
	get_tree().change_scene_to_packed(loadingPath)

func _open_settings() -> void:
	var sceneRun = menuSettings.instantiate()
	menuOptions.add_child(sceneRun)
	existingMenu = sceneRun
