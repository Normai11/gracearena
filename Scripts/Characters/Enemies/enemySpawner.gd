extends Node2D

enum typeDisplay {
	RANDOM = -1,
	basicPatroller = 0,
	enemySpore = 1
}

var enemyRef : Dictionary[int, String] = {
	0 : "res://Scenes/Characters/Enemies/basicPatroller.tscn",
	1 : "res://Scenes/Characters/Enemies/enemySpore.tscn"
}

var randGen : RandomNumberGenerator = RandomNumberGenerator.new()

## If true, this node will not spawn anything and free itself from the scene tree immediately.
@export var disabled : bool = false
## The parent node the enemy will be added to.
@export var injectNode : Node2D
## The enemy this node will spawn when the scene is loaded.
@export var enemyType = typeDisplay.RANDOM
## The direction the enemy will face when loaded into the scene. -1 is left, 1 is right.
@export_range(-1, 1, 2) var spawnDirection : int = 1
@export_category("Custom Attributes")
## Enabling this overrides the enemy's preset attributes.
@export var overrideAttributes : bool = false
## The max amount of health the enemy will recieve.
@export var customHealth : float = 5.0
## The amount of damage the enemy will inflict on the player.
@export var customDamage : float = 5.0
## The speed that the enemy will be granted.
@export var customSpeed : float = 200.0

func _ready() -> void:
	if disabled:
		self.queue_free()
		return
	var enemyPath
	if enemyType == -1 or enemyType == 1028:
		var randEnemy = randGen.randi_range(0, enemyRef.size() - 1)
		enemyPath = load(enemyRef[randEnemy])
	else:
		enemyPath = load(enemyRef[enemyType])
	var enemyChild = enemyPath.instantiate()
	
	enemyChild.position = self.position
	enemyChild.startingDirection = spawnDirection
	if overrideAttributes:
		enemyChild.health = customHealth
		enemyChild.moveSpeed = customSpeed
		enemyChild.dmg = customDamage
	
	injectNode.add_child.call_deferred(enemyChild)
	self.queue_free()
