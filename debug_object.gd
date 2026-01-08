extends Control

@export var parentRef : CanvasLayer
@export var startOpen : bool = false
@export var collisionsShow : bool = false
@export var enabled : bool = true

@onready var enemySpawn = preload("res://Scenes/Characters/Enemies/enemySpawner.tscn")

func _ready() -> void:
	if !enabled:
		queue_free()
	visible = startOpen
	get_tree().set_debug_collisions_hint(collisionsShow)

func _process(_delta: float) -> void:
	$recover.text = "Heal " + str($recover/HScrollBar.value)
	$Label0.text = "health = " + str($hp.value)
	$Label1.text = "speed = " + str($spd.value)
	$Label2.text = "damage = " + str($dmg.value)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_V:
				spawn_patrol()
			elif event.keycode == KEY_H:
				visible = !visible

func spawn_patrol() -> void:
	var loadP = enemySpawn.instantiate()
	var cam = get_viewport().get_camera_2d()
	
	loadP.position = cam.get_global_mouse_position()
	loadP.injectNode = parentRef.get_parent().get_parent()
	loadP.enemyType = $selection.get_item_id($selection.selected)
	loadP.overrideAttributes = $enable.button_pressed
	loadP.customHealth = $hp.value
	loadP.customSpeed = $spd.value
	loadP.customDamage = $dmg.value
	
	parentRef.get_parent().get_parent().add_child(loadP)

func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()

func heal() -> void:
	parentRef.player.health += $recover/HScrollBar.value
	parentRef.update_health()

func _on_settings_pressed() -> void:
	var scene = load("res://Scenes/Menus/Main/settingsMenu.tscn")
	var child = scene.instantiate()
	parentRef.add_child(child)

func _on_main_pressed() -> void:
	var loadingPath = load("res://Scenes/Menus/loadingScreen.tscn")
	Global.loadfinishPath = "res://Scenes/Menus/Main/MainMenu.tscn"
	get_tree().change_scene_to_packed(loadingPath)
