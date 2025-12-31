class_name Player
extends CharacterBody2D

@onready var interactArea = $interactionArea
var abButtonRef = preload("res://Scenes/Menus/Main/inputButton.tscn")

@export var loadGuiScene : PackedScene
var guiScene

@export_category("Movement")
@export var stunned : bool = false
var stunDir : int = -1
var stunDist : float = 0.0
@export var move_speed : float = 350.0
@export var sprintAdditive : float = 200.0
@export var jump_force : float = 725.0
@export var drop_force : float = 425.0
@export var gravity_cap : float = 1500.0
@export var coyoteFrames : int = 6
var coyoteframe : int

@export_category("Attributes")
@export var maxJumps : int = 1
var curJumps : int
var extraJumps : int
@export var accel : float = 90.0
@export var friction : float = 20.0
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
var direction : int = 1

func _ready() -> void:
	var loadObject = loadGuiScene.instantiate()
	loadObject.player = self
	guiScene = loadObject
	add_child(loadObject)
	add_abilities()
	guiScene.update_health()
	guiScene.show_prompt(false)
	
	for child in addons.get_children():
		if child.name != "movementComponent":
			if child.abilityID == 4:
				child._ability_activate()

func add_abilities() -> void:
	var injectHUD = guiScene.hudPath
	
	for i in addons.get_children():
		if i != moveNode:
			addons.remove_child(i)
	
	for item in DataStore.playerData["Actives"]:
		var child = abButtonRef.instantiate()
		var abFuncRef = load(DataStore.abilityPaths[int(item)])
		var vessel = abFuncRef.instantiate()
		abilities.append(int(item))
		
		#region UI
		child.inputID = int(item)
		child.promptID = int(abilities.size()) - 1
		child.hold = vessel.holdAbility
		child.inGame = true
		child.abFunc = vessel
		child.inputName = vessel.abName
		child.mouse_entered.connect(guiScene.show_description.bind(child))
		child.mouse_exited.connect(guiScene.hide_description)
		child._selected.connect(trigger_ability)
		injectHUD.add_child(child)
		#endregion
		
		#region Function
		vessel.name = str(int(item))
		vessel.abDisplay = child
		vessel.player = self
		vessel.abilitySlot = abilities.find(int(item))
		addons.add_child(vessel)
		#endregion
	
	for item in DataStore.playerData["Passives"]:
		var abFuncRef = load(DataStore.abilityPaths[int(item)])
		var vessel = abFuncRef.instantiate()
		var child = abButtonRef.instantiate()
		passives.append(int(item))
		
		child.isAbility = false
		child.inputID = int(item)
		child.inGame = true
		child.abFunc = vessel
		child.inputName = vessel.abName
		child.mouse_entered.connect(guiScene.show_description.bind(child))
		child.mouse_exited.connect(guiScene.hide_description)
		guiScene.perkPath.add_child(child)
		
		vessel.name = str(int(item))
		vessel.player = self
		vessel.abDisplay = child
		addons.add_child(vessel)
		if item == 3:
			vessel.formShield()
		
	#guiScene._refresh_perks()

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
	if !onLag && !stunned:
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
	var movement = moveNode.get_movement_input()
	var speed : float = move_speed
	if moveNode.get_sprint():
		speed = move_speed + sprintAdditive
	if moveType != 2 && moveType != 1 && moveType != 5:
		if !movement == 0:
			direction = movement
	if direction == 1:
		interactArea.rotation_degrees = 0
	else:
		interactArea.rotation_degrees = 180
	
	if moveType == 5:
		movement = 0
	
	var velocityWeight : float = delta * (accel if movement else friction)
	
	# jump input
	if is_on_floor():
		stunned = false
		coyoteframe = 0
		curJumps = 0
	else:
		coyoteframe += 1
		if curJumps == 0 && coyoteframe >= coyoteFrames:
			curJumps += 1
	if moveNode.get_jump(true) && !stunned:
		if not curJumps >= (maxJumps + extraJumps):
			velocity.y = -jump_force
			curJumps += 1
	if (!moveNode.get_jump() && !is_on_floor()) or velocity.y >= 0:
		velocity.y = lerp(velocity.y, gravity, 0.02)
	
	velocity.y += gravity * delta
	if velocity.y >= gravity_cap:
		velocity.y = gravity_cap
	
	if !stunned:
		velocity.x = lerp(velocity.x, movement * speed, velocityWeight)
	else:
		velocity.x = lerp(velocity.x, stunDir * stunDist, velocityWeight)
	
	if moveType == 1:
		velocity = Vector2.ZERO
	move_and_slide()
	
	check_interaction()

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

func damage_by(amt, _dir, dealKnockback : bool = true, penetrate : bool = false):
	if passives.has(3) && !penetrate:
		var target = addons.find_child(str(3), false, false)
		if !target._check_cooldown():
			trigger_ability(3)
			return
	if passives.has(5):
		trigger_ability(5)
	iFrames = iFrameMax
	health -= amt
	guiScene.update_health()
	if dealKnockback:
		velocity.y = -500

func stun(dir, dist):
	stunned = true
	stunDir = dir
	stunDist = dist

func check_interaction() -> void:
	if interactArea.is_colliding():
		var target = interactArea.get_collider()
		if target.monitorable:
			guiScene.show_prompt()
			if Input.is_action_just_pressed("interact"):
				target.get_parent()._interacted()
		else:
			guiScene.show_prompt(false)
	else:
		guiScene.show_prompt(false)
