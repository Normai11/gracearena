extends Node2D

@export var appearChance : float = 0.1
@export var hijackDuration : float = 1.5
@export var hijackDamage : float = 34

var open : bool = false
var hijacking : bool = false
var hijackTimer : float = 100.0
var playerReference : Player

@onready var roomDetect : Area2D = $roomDetect
@onready var roomDetectSize : CollisionShape2D = $roomDetect/size
@onready var playerDetect : Area2D = $playerDetect
@onready var playerDetectSize : CollisionShape2D = $playerDetect/size

func spawn() -> void:
	$Enabler.queue_free()
	print(get_parent() is Room)
	var determineChance : float = randf_range(0, 1)
	if not (determineChance <= appearChance):
		print("Spawn chance failed!")
		queue_free()
		return
	
	var check = get_parent()
	
	if check is Room:
		roomDetect.global_position = get_room_global_position(check)
		playerDetect.global_position = get_room_global_position(check)
		roomDetectSize.shape.size = get_room_size(check)
		playerDetectSize.shape.size = Vector2(get_room_size(check).x / 2, get_room_size(check).y)
	else:
		printerr("Could not find Room; Freeing Hijack")
		queue_free()

func _process(delta: float) -> void:
	hijackTimer -= delta
	if hijacking && hijackTimer <= 0:
		hijacking = false
		playerReference.damage_player(hijackDamage, 0)
		queue_free()

func get_room_size(room : Room) -> Vector2:
	return room.roomSize

func get_room_global_position(room : Room) -> Vector2:
	return room.global_position

func _player_detected(body: Node2D) -> void:
	if body is Player && !hijacking:
		$Appearance/Anims.play("open")
		hijackTimer = hijackDuration + 0.15
		playerReference = body
		await $Appearance/Anims.animation_finished
		hijacking = true

func _player_left_room(body: Node2D) -> void:
	if body is Player:
		await get_tree().process_frame
		if roomDetect.get_overlapping_bodies().has(body):
			return
		if hijacking:
			hijacking = false
			queue_free()
