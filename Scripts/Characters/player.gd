extends CharacterBody2D

var abButtonRef = preload("res://Scenes/Menus/Main/abilityButton.tscn")

@export var move_speed : float = 350.0
@export var jump_force : float = 525.0

@onready var animations = $animations
@onready var moveNode = $moveAddons/movementComponent

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_abilities()

func add_abilities() -> void:
	var injectHUD = $GUI/HUDparent/Abilities
	var injectInput = $moveAddons
	
	for item in Global.playerData["Actives"]:
		var child = abButtonRef.instantiate()
		
		child.abilityID = item
		child.promptID = Global.playerData["Actives"].find(item)
		child.in_game = true
		# child._selected.connect(x)
		injectHUD.add_child(child)

func _physics_process(delta: float) -> void:
	var speed : float = move_speed
	if moveNode.get_sprint():
		speed = move_speed * 1.55
	
	var movement = moveNode.get_movement_input() * speed
	# gravity
	if moveNode.get_drop():
		velocity.y += (gravity * 1.75) * delta
	else:
		velocity.y += gravity * delta
	# jump input
	if moveNode.get_jump() && is_on_floor():
		velocity.y = -jump_force
	
	velocity.x = movement
	move_and_slide()
