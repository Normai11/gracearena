extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://player.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://simple.tscn")

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Main/MainMenu.tscn")
