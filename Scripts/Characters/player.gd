extends CharacterBody2D

var abButtonRef = preload("res://Scenes/Menus/Main/abilityButton.tscn")

@export_category("Movement")
@export var move_speed : float = 350.0
@export var jump_force : float = 525.0
@export var drop_force : float = 425.0
@export var gravity_cap : float = 1500.0

@export_category("Ability")
@export var abilities : Array[int] = []
@export var moveType : int = 0
@export var onLag : bool = false

@onready var animations = $animations
@onready var moveNode = $moveAddons/movementComponent
@onready var addons = $moveAddons
@onready var lagTimer = $endlag

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : int

func _ready() -> void:
	add_abilities()

func add_abilities() -> void:
	var injectHUD = $GUI/HUDparent/Abilities
	
	for i in addons.get_children():
		if i != moveNode:
			addons.remove_child(i)
	for item in DataStore.playerData["Actives"]:
		var child = abButtonRef.instantiate()
		var abFuncRef = load(DataStore.abilityPaths[str(int(item))])
		var vessel = abFuncRef.instantiate()
		abilities.append(int(item))
		
		#region UI
		child.abilityID = int(item)
		child.promptID = int(abilities.size()) - 1
		child.in_game = true
		child.abFunc = vessel
		child._selected.connect(trigger_ability)
		injectHUD.add_child(child)
		#endregion
		
		#region Function
		vessel.name = str(int(item))
		vessel.abDisplay = child
		vessel.player = self
		addons.add_child(vessel)
		#endregion

func trigger_ability(id):
	var target = addons.find_child(str(id), false, false)
	if !target._check_cooldown():
		target._ability_activate()

func _start_endlag(duration):
	lagTimer.start(duration)
	onLag = true

func _end_lag() -> void:
	onLag = false

func _input(event: InputEvent) -> void:
	if !onLag:
		if Input.is_action_just_pressed("primary"):
			trigger_ability(abilities[0])
		if Input.is_action_just_pressed("secondary"):
			trigger_ability(abilities[1])

func _physics_process(delta: float) -> void:
	var speed : float = move_speed
	if moveNode.get_sprint():
		speed = move_speed * 1.55
	
	var movement = moveNode.get_movement_input() * speed
	if moveType != 2:
		direction = moveNode.get_movement_input()
	
	# jump input
	if moveNode.get_jump() && is_on_floor():
		velocity.y = -jump_force
	if (!moveNode.get_jump() && !is_on_floor()) or velocity.y >= 0:
		velocity.y = lerp(velocity.y, gravity, 0.02)
	
	# drop input
	if moveNode.get_drop() && !is_on_floor():
		if velocity.y <= 1000:
			velocity.y = drop_force
	
	velocity.y += gravity * delta
	if velocity.y >= gravity_cap:
		velocity.y = gravity_cap
	velocity.x = movement
	move_and_slide()
