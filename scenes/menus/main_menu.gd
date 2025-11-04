extends Control

const MAIN_LEVEL_SCENE: PackedScene = preload("res://scenes/levels/sandbox.tscn")
const SETTINGS_MENU_SCENE: PackedScene = preload("res://scenes/menus/settings_menu.tscn")
const CREDITS_MENU_SCENE: PackedScene = preload("res://scenes/menus/credits_menu.tscn")

@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	if OS.has_feature("web"):
		quit_button.visible = false

func _on_play_button_button_down() -> void:
	get_tree().change_scene_to_packed(MAIN_LEVEL_SCENE)

func _on_settings_button_button_down() -> void:
	get_tree().change_scene_to_packed(SETTINGS_MENU_SCENE)

func _on_credits_button_button_down() -> void:
	get_tree().change_scene_to_packed(CREDITS_MENU_SCENE)

func _on_quit_button_button_down() -> void:
	get_tree().quit()
