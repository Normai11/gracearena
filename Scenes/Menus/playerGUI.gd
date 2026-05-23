extends CanvasLayer

@export var interactTimerMax : float = 0.4

var showInteraction : bool = false
var interactTimer : float = 0.0
var playerNode : Player

@onready var healthBar : TextureProgressBar = $Base/healthBar
@onready var strikeBar : TextureProgressBar = $Base/strikeBar
@onready var interactPrompt : TextureRect = $Base/interactPrompt
@onready var promptName : Label = $Base/interactPrompt/promptName
@onready var perkContainer : GridContainer = $Base/perkContainer
@onready var perkCard : Panel = $Base/perkCard
@onready var cardText : RichTextLabel = $Base/perkCard/Text
@onready var pauseMenu = preload("res://Scenes/Menus/pauseMenu.tscn")

func _ready() -> void:
	trigger_perkCard()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		add_child(pauseMenu.instantiate())

func _process(delta: float) -> void:
	if showInteraction:
		interactTimer -= delta
		#print(interactTimer)
		if interactTimer <= 0.0:
			interactTimer = interactTimerMax
			if interactPrompt.texture.region == Rect2(0.0, 0.0, 250.0, 250.0):
				interactPrompt.texture.region = Rect2(250.0, 0.0, 250.0, 250.0)
			else:
				interactPrompt.texture.region = Rect2(0.0, 0.0, 250.0, 250.0)
	
	if DataStore.saveData["runModifiers"].has("lyte"):
		strikeBar.visible = true
	else:
		strikeBar.visible = false
	
	healthBar.max_value = playerNode.maxHealth
	healthBar.value = lerp(healthBar.value, playerNode.health, 0.4)
	
	perkCard.position = get_viewport().get_mouse_position()

func set_interactPrompt(showPrompt : bool, promptDisp : String = "") -> void:
	promptName.text = promptDisp
	showInteraction = showPrompt
	if showPrompt:
		interactTimer = interactTimerMax
		interactPrompt.texture.region = Rect2(0.0, 0.0, 250.0, 250.0)
		interactPrompt.visible = true
	else:
		interactPrompt.visible = false

func trigger_perkCard(showCard : bool = false, text : String = "") -> void:
	cardText.text = text
	perkCard.visible = showCard
