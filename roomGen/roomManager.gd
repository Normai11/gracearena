extends Node

enum RoomNum {
	RANDOM = -1,
	ROOM_0 = 0,
	ROOM_1 = 1
}

var roomRng : RandomNumberGenerator = RandomNumberGenerator.new()
var roomGen : int = 0

@export var injectNode : Node2D
@export var maxRooms : int = 25
@export var startingRoom = RoomNum.RANDOM
@export var roomOffset : Vector2 = Vector2(0, 0)

func _ready() -> void:
	roomGen = startingRoom
	if startingRoom == -1:
		roomGen = rollRoom()
	generate_rooms()

func rollRoom() -> int:
	var roll = roomRng.randi_range(0, DataStore.roomPaths.size() - 1)
	return roll

func generate_rooms() -> void:
	#start/setup
	var loadPath = load(DataStore.roomPaths[roomGen])
	var room = loadPath.instantiate()
	
	room.position += (room.roomOffset + roomOffset)
	roomOffset = (room.roomContObj.position + room.position)
	
	injectNode.add_child.call_deferred(room)
	for roomLeft in maxRooms - 1:
		loadPath = load(DataStore.roomPaths[rollRoom()])
		room = loadPath.instantiate()
		
		room.position += (room.roomOffset + roomOffset)
		roomOffset = (room.roomContObj.position + room.position)
		
		injectNode.add_child.call_deferred(room)
	loadPath = load(DataStore.abilityPaths["END"])
	room = loadPath.instantiate()
	
	room.position += (room.roomOffset + roomOffset)
	
	injectNode.add_child.call_deferred(room)
