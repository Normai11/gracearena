extends interactableObject

var shopOpened : bool = false
@export var loadTimeCap : float = 0.35
var curTime : float = 0.0

var pathInstantiated : bool = false
@onready var shopPath := preload("res://assets/shopkeeper/shopParent.tscn")
@onready var area = $interactionArea

func _ready() -> void:
	curTime = loadTimeCap

func _interacted():
	shopOpened = true
	if overhaulCamera:
		var camera = get_parent().find_child("advCamera")
		camera.change_targets(self, cameraFocusMode, cameraFocusDrag, cameraFocusZoom)
	area.monitorable = false

func _process(delta: float) -> void:
	if shopOpened:
		curTime -= delta
		if curTime <= 0:
			curTime = 0
			if !pathInstantiated:
				pathInstantiated = true
				open_shop()

func open_shop() -> void:
	var shop = shopPath.instantiate()
	var playerHUD = get_parent().find_child("Player")
	if playerHUD:
		playerHUD.moveType = 5
		playerHUD = playerHUD.guiScene
		playerHUD.shop_toggle(true)
	
	add_child(shop)
