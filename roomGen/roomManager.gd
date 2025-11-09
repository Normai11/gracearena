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
	print("roll " + str(roll))
	return roll

func generate_rooms() -> void:
	#start/setup
	var loadPath = load(DataStore.roomPaths[roomGen])
	var room = loadPath.instantiate()
	
	setup_room(room, !roomDir)
	
	injectNode.add_child.call_deferred(room)
	for roomLeft in maxRooms - 1:
		var num = rollRoom()
		loadPath = load(DataStore.roomPaths[num])
		room = loadPath.instantiate()
		var check = check_bounds(room, num)
		if check != num:
			room.queue_free()
			loadPath = load(DataStore.roomPaths[check])
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

func check_bounds(checking, original) -> int:
	var newRoom : int
	
	$boundCheck/radius.shape.size = checking.roomSize
	if !roomDir:
		$boundCheck.position.x = -(checking.roomOffset.x + -roomOffset.x)
		$boundCheck.position.y = (checking.roomOffset.y + roomOffset.y)
	else:
		$boundCheck.position.x = (checking.roomOffset.x + roomOffset.x)
		$boundCheck.position.y = (checking.roomOffset.y + roomOffset.y)
	print($boundCheck.get_overlapping_areas())
	print($boundCheck.get_overlapping_bodies())
	if $boundCheck.has_overlapping_areas():
		newRoom = rollRoom()
		print("pre " + str(newRoom))
		var path = load(DataStore.abilityPaths[newRoom])
		var newCheck = path.instantiate()
		
		for attempts in 256:
			$boundCheck/radius.shape.size = newCheck.roomSize
			if !roomDir:
				$boundCheck.position.x = -(newCheck.roomOffset.x + -roomOffset.x)
				$boundCheck.position.y = (newCheck.roomOffset.y + roomOffset.y)
			else:
				$boundCheck.position.x = (newCheck.roomOffset.x + roomOffset.x)
				$boundCheck.position.y = (newCheck.roomOffset.y + roomOffset.y)
			if $boundCheck.has_overlapping_areas():
				continue
			else:
				print(newRoom)
				return newRoom
				break
	else:
		print("Passed " + str($boundCheck.get_overlapping_areas()))
		return original
	return original
