extends CanvasLayer

@export var player : Player

@onready var hudPath = $HUDparent/Abilities
@onready var perkPath = $HUDparent/Perks
@onready var healthBar = $HUDparent/Healthbar
@onready var perkLoad = preload("res://Scenes/Menus/Main/inputButton.tscn")
@onready var abilityInfo = $HUDparent/abilityInfo
@onready var infoText = $HUDparent/abilityInfo/textDisplay

var tween : Tween

func datastore_settings_refresh() -> void:
	if DataStore.settings["toggleHint"] == false:
		hide_description()

func _ready() -> void:
	hide_description()
	infoText.size = abilityInfo.custom_minimum_size
	abilityInfo.size = abilityInfo.custom_minimum_size
	healthBar.max_value = player.max_health

func _process(_delta: float) -> void:
	var mousePos : Vector2 = get_viewport().get_mouse_position()
	var farEdge : Vector2 = get_window().size
	abilityInfo.position = mousePos
	if abilityInfo.position.x >= (farEdge.x - abilityInfo.custom_minimum_size.x):
		abilityInfo.position.x = (farEdge.x - abilityInfo.custom_minimum_size.x)
	if abilityInfo.position.y >= (farEdge.y - abilityInfo.size.y):
		abilityInfo.position.y = (farEdge.y - abilityInfo.size.y)
	$HUDparent.modulate.a = DataStore.settings["guiTrans"]
	#TIMER
	if player.get_parent().specialStage:
		$HUDparent/timerplaceholder.visible = false
	else:
		$HUDparent/timerplaceholder.visible = true
	var minutes = int(DataStore.timer / 60)
	var seconds = DataStore.timer - minutes * 60
	$HUDparent/timerplaceholder/display.text = '%02d:%02d' % [minutes, seconds]

func update_health() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(healthBar, "value", player.health, 0.2)
	healthBar.get_child(0).text = str(int(player.health))

func shield_anim(form : bool = true) -> void:
	if form:
		$HUDparent/Healthbar/Display/AnimationPlayer.play("armorForm")
	else:
		$HUDparent/Healthbar/Display/AnimationPlayer.play("armorBreak")

func show_prompt(active : bool = true):
	if active:
		$HUDparent/prompt.visible = true
		$HUDparent/prompt/loop.play("loop")
	else:
		$HUDparent/prompt.visible = false
		$HUDparent/prompt/loop.stop()

func show_description(object) -> void:
	var title = object.inputName
	var text = object.get_description()
	infoText.text = "[center]" + title + "[/center]" + "\n\n" + text
	infoText.size = abilityInfo.custom_minimum_size
	abilityInfo.size = abilityInfo.custom_minimum_size
	if DataStore.settings["toggleHint"] == true:
		abilityInfo.visible = true

func hide_description() -> void:
	abilityInfo.visible = false

#func _refresh_perks():
	#for item in DataStore.playerData["Passives"]:
		#var subject = perkLoad.instantiate()
		#var texturePath = "res://Sprites/Abilities/ab" + str(int(item)) + ".png"
		##player.passives.append(int(item))
		#
		#subject.isAbility = false
		#subject.inGame = true
		#subject.inputID = item
		#subject.texturePath = texturePath
		#
		#perkPath.add_child(subject)
