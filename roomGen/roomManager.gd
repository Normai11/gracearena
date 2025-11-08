extends Node

enum RoomNum {
	RANDOM = -1,
	ROOM_0 = 0,
	ROOM_1 = 1
}

var roomRng : RandomNumberGenerator = RandomNumberGenerator.new()
var roomGen : int = 0
var roomDir : bool = true ##FALSE is LEFT, TRUE is RIGHT

@export var startingRoom = RoomNum.RANDOM
@export var injectNode : Node2D
@export var maxRooms : int = 25
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
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)
	for roomLeft in maxRooms - 1:
		loadPath = load(DataStore.roomPaths[rollRoom()])
		room = loadPath.instantiate()
		
		setup_room(room, !roomDir)
		
		injectNode.add_child.call_deferred(room)
	loadPath = load(DataStore.abilityPaths["END"])
	room = loadPath.instantiate()
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)

func setup_room(child, flip : bool) -> void:
	child.roomFlipped = flip
	
	if child.startFlipping:
		roomDir = !roomDir
	
	if flip:
		child.position.x += -(child.roomOffset.x + -roomOffset.x)
		child.position.y += (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = -(child.roomContObj.position.x - child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)
	else:
		child.position.x += (child.roomOffset.x + roomOffset.x)
		child.position.y += (child.roomOffset.y + roomOffset.y)
		if !child.endGen:
			roomOffset.x = (child.roomContObj.position.x + child.position.x)
			roomOffset.y = (child.roomContObj.position.y + child.position.y)
