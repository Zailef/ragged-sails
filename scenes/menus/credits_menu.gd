extends Control

var main_menu_scene: PackedScene = load("res://scenes/menus/main_menu.tscn")

func _on_back_button_button_down() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)
