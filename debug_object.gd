extends Control

@export var parentRef : CanvasLayer
@export var startOpen : bool = false
@export var collisionsShow : bool = false
@export var enabled : bool = true

@onready var patrol = preload("res://Scenes/Characters/Enemies/basicPatroller.tscn")

func _ready() -> void:
	if !enabled:
		queue_free()
	visible = startOpen
	get_tree().set_debug_collisions_hint(collisionsShow)

func _process(_delta: float) -> void:
	$recover.text = "Heal " + str($recover/HScrollBar.value)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_V:
				spawn_patrol()
			elif event.keycode == KEY_H:
				visible = !visible

func spawn_patrol() -> void:
	var loadP = patrol.instantiate()
	var cam = get_viewport().get_camera_2d()
	loadP.position = cam.get_global_mouse_position()
	parentRef.get_parent().get_parent().add_child(loadP)

func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()

func heal() -> void:
	parentRef.player.health += $recover/HScrollBar.value
	parentRef.update_health()
