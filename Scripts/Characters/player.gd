class_name Player
extends CharacterBody2D

var abButtonRef = preload("res://Scenes/Menus/Main/inputButton.tscn")

@export var loadGuiScene : PackedScene
var guiScene

@export_category("Movement")
@export var move_speed : float = 350.0
@export var jump_force : float = 725.0
@export var drop_force : float = 425.0
@export var gravity_cap : float = 1500.0

@export_category("Attributes")
@export var max_health : float = 100.0
@export var health : float = 100.0
@export var abilities : Array[int] = []
@export var passives : Array[int] = []
@export var moveType : int = 0
@export var iFrameMax : int = 30 ## IN FRAMES!!!!!
var iFrames : int = 0
@export var onLag : bool = false

@onready var animations = $animations
@onready var moveNode = $moveAddons/movementComponent
@onready var addons = $moveAddons
@onready var lagTimer = $endlag

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : int

func _ready() -> void:
	var loadObject = loadGuiScene.instantiate()
	loadObject.player = self
	guiScene = loadObject
	add_child(loadObject)
	add_abilities()
	guiScene.update_health()

func add_abilities() -> void:
	var injectHUD = guiScene.hudPath
	
	for i in addons.get_children():
		if i != moveNode:
			addons.remove_child(i)
	
	for item in DataStore.playerData["Actives"]:
		var child = abButtonRef.instantiate()
		var abFuncRef = load(DataStore.abilityPaths[str(int(item))])
		var vessel = abFuncRef.instantiate()
		abilities.append(int(item))
		
		#region UI
		child.inputID = int(item)
		child.promptID = int(abilities.size()) - 1
		child.inGame = true
		child.abFunc = vessel
		child.inputName = vessel.abName
		child._selected.connect(trigger_ability)
		injectHUD.add_child(child)
		#endregion
		
		#region Function
		vessel.name = str(int(item))
		vessel.abDisplay = child
		vessel.player = self
		addons.add_child(vessel)
		#endregion
	
	guiScene._refresh_perks()

func trigger_ability(id):
	var target = addons.find_child(str(id), false, false)
	if !target._check_cooldown():
		target._ability_activate()

func _start_endlag(duration):
	lagTimer.start(duration)
	onLag = true

func _end_lag() -> void:
	onLag = false

func _input(_event: InputEvent) -> void:
	if !onLag:
		if Input.is_action_just_pressed("primary"):
			trigger_ability(abilities[0])
		if Input.is_action_just_pressed("secondary"):
			if abilities.size() >= 2:
				trigger_ability(abilities[1])
		if Input.is_action_just_pressed("tertiary"):
			if abilities.size() >= 3:
				trigger_ability(abilities[2])
		if Input.is_action_just_pressed("quarternary"):
			if abilities.size() >= 4:
				trigger_ability(abilities[3])

func _physics_process(delta: float) -> void:
	var speed : float = move_speed
	if moveNode.get_sprint():
		speed = move_speed * 1.55
	
	var movement = moveNode.get_movement_input() * speed
	if moveType != 2 && moveType != 1:
		if moveNode.get_movement_input() != 0:
			direction = moveNode.get_movement_input()
	
	# jump input
	if moveNode.get_jump() && is_on_floor():
		velocity.y = -jump_force
	if (!moveNode.get_jump() && !is_on_floor()) or velocity.y >= 0:
		velocity.y = lerp(velocity.y, gravity, 0.02)
	
	velocity.y += gravity * delta
	if velocity.y >= gravity_cap:
		velocity.y = gravity_cap
	velocity.x = movement
	if moveType == 1:
		velocity.x = 0
		velocity.y = 0
	move_and_slide()

func _process(_delta: float) -> void:
	if iFrames != 0:
		iFrames -= 1
		set_collision_layer_value(2, false)
		modulate.a = 0.5
	else:
		set_collision_layer_value(2, true)
		modulate.a = 1
	
	if health > max_health:
		health = max_health

func damage_by(amt, _dir):
	health -= amt
	iFrames = iFrameMax
	guiScene.update_health()
	velocity.y = -500
