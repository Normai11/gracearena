@icon("res://Assets/Templates/RoomConfiguration.svg")
class_name RoomConfiguration
extends Resource

enum roomTypes {
	TIMER,
	SAFEROOM
}

@export_file("*.tscn") var roomScenePath : String
@export var roomType : roomTypes = roomTypes.TIMER
@export var roomBiome : int = -1
@export_range(0, 1, 0.1) var roomChance : float = 0.5
@export_group("Generation Identity")
@export var roomSize : Vector2
@export var roomOffset : Vector2
@export var roomContinuePosition : Vector2
@export var roomFlips : bool = false

func _get_offset() -> Vector2:
	return roomOffset
