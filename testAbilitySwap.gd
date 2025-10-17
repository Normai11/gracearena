extends Node

@export var id : int

func _ready() -> void:
	swap_script(id)

func swap_script(id):
	set_script(load(DataStore.abilityPaths[str(id)]))
