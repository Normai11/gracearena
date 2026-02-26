extends CanvasLayer

@onready var itemInfo = $GUI/itemInfo

var shopParent : Node
var purchasing : bool = false
var selectedItem : shopItem

func _ready() -> void:
	shopParent = get_parent()
	
	for item in $GUI.get_children():
		if item is shopItem:
			item.connect("mouse_entered", set_info_text.bind(item))
			item.connect("mouse_exited", hide_itemInfo)
			item.connect("_purchase", open_purchase_prompt.bind(item))

func _process(_delta: float) -> void:
	$GUI/itemInfo/textContainer.position = Vector2(0,0)
	var mousePos : Vector2 = get_viewport().get_mouse_position()
	var farEdge : Vector2 = get_window().size
	if !purchasing:
		itemInfo.position = mousePos
	if itemInfo.position.x >= (farEdge.x - itemInfo.size.x):
		itemInfo.position.x = (farEdge.x - itemInfo.size.x)
	if itemInfo.position.y >= (farEdge.y - itemInfo.size.y):
		itemInfo.position.y = (farEdge.y - itemInfo.size.y)

func set_info_text(object, isItem : bool = false) -> void:
	if purchasing:
		return
	if !isItem:
		var title = object.get_item_name()
		var text = object.get_description()
		$GUI/itemInfo/textContainer/textDisplay.text = "[center]" + title + "[/center]" + "\n\n" + text
		$GUI/itemInfo/textContainer.size = Vector2(264, itemInfo.custom_minimum_size.y)
		itemInfo.size = Vector2(264, itemInfo.custom_minimum_size.y)
	else:
		$GUI/itemInfo/textContainer/textDisplay.text = ""
		$GUI/itemInfo/textContainer.size = Vector2(itemInfo.custom_minimum_size.x, 64)
		itemInfo.size = Vector2(itemInfo.custom_minimum_size.x, 64)
	itemInfo.visible = true

func open_purchase_prompt(object : shopItem) -> void:
	if purchasing:
		return
	object.button.visible = false
	selectedItem = object
	set_info_text(object, true)
	purchasing = true
	$GUI/itemInfo/buy.visible = true
	$GUI/itemInfo/cancel.visible = true
	itemInfo.position = (Vector2(object.custom_minimum_size.x, object.custom_minimum_size.y / 4)) + object.position

func hide_itemInfo() -> void:
	if purchasing:
		return
	$GUI/itemInfo.visible = false

func _on_exit_pressed() -> void:
	shopParent.close_shop()

func _cancel_purchase() -> void:
	purchasing = false
	selectedItem.button.visible = true
	$GUI/itemInfo/buy.visible = false
	$GUI/itemInfo/cancel.visible = false
	selectedItem = null
	hide_itemInfo()

func _purchase_item() -> void:
	if selectedItem && !check_item_purchaseable():
		selectedItem._offsale()
		if selectedItem.sellID >= 100:
			DataStore.playerData["Actives"].append(selectedItem.sellID)
		else:
			DataStore.playerData["Passives"].append(selectedItem.sellID)
	shopParent.player.refresh_abilities()
	_cancel_purchase()

func check_item_purchaseable() -> bool:
	if selectedItem.sellID >= 100:
		if shopParent.player.abilities.has(selectedItem.sellID) or ((shopParent.player.abilities.size()) >= shopParent.player.maxAbilities):
			return true
	else:
		if shopParent.player.passives.size() >= 4:
			return true
	return false
