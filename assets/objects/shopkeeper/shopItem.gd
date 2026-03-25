class_name shopItem
extends Control
signal _purchase

enum sellTypes {
	ITEM,
	ABILITY
}

@onready var texture : TextureRect = $Display
@onready var button : Button = $itemBuy

@export var sellType := sellTypes.ITEM
@export var sellID : int = 0

var sizeTween : Tween
var bought : bool = false

func set_frame(id : int) -> void:
	var atlas = texture.texture
	
	if sellType == sellTypes.ABILITY:
		var x = 250 * (id if id < 100 else id - 100)
		var y = (0 if id < 100 else 250)
		atlas.region = Rect2(x, y, 250, 250)

func _ready() -> void:
	if sellID == -1:
		_offsale()
		return
	if sellType == sellTypes.ABILITY:
		var atlasTexture = AtlasTexture.new()
		var atlasPath = "res://assets/abilities/abilityAtlas.png"
		atlasTexture.atlas = load(atlasPath)
		texture.texture = atlasTexture
	set_frame(sellID)

func _itemBuy_hovered() -> void:
	if sizeTween:
		sizeTween.kill()
	sizeTween = get_tree().create_tween()
	sizeTween.set_trans(Tween.TRANS_EXPO)
	sizeTween.set_ease(Tween.EASE_OUT)
	sizeTween.tween_property(texture, "scale", Vector2(1.1, 1.1), 0.15)
	mouse_entered.emit()

func _itemBuy_lose_hover() -> void:
	if sizeTween:
		sizeTween.kill()
	sizeTween = get_tree().create_tween()
	sizeTween.set_trans(Tween.TRANS_EXPO)
	sizeTween.set_ease(Tween.EASE_OUT)
	sizeTween.tween_property(texture, "scale", Vector2(1.0, 1.0), 0.15)
	mouse_exited.emit()

func get_item_name() -> String:
	return "placeholder"

func get_description() -> String:
	return ("placeholder" if !bought else "")

func _item_purchase() -> void:
	_purchase.emit()

func _offsale() -> void:
	$itemBuy.disabled = true
	bought = true
	set_frame(-1)
	#queue_free()
