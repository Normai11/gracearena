@tool
extends Resource
class_name roomConfiguration

enum Types {
	SAFEROOM,
	TIMED,
	EXIT
}

@export_custom(PROPERTY_HINT_FILE, "") var roomScenePath : String
@export_range(0.0, 1.0, 0.000001) var appearChance : float = 0.5
@export var flipDirection : bool = false
@export var roomType : Types = Types.TIMED
@export var roomBounds : Vector2
@export var roomOffset : Vector2
@export var genContinuePosition : Vector2

func get_bounds() -> Vector2:
	return roomBounds

func get_offset() -> Vector2:
	return roomOffset

func get_continue_point() -> Vector2:
	return genContinuePosition
