extends Control
class_name LevelUpCard

## A card displaying a weapon option in the level-up selection screen.

const WeaponDataScript = preload("res://scenes/weapons/weapon_data.gd")

signal selected(weapon_data: Resource)

@export var weapon_data: Resource:
	set(value):
		weapon_data = value
		_update_display()

@onready var icon_texture: TextureRect = $VBoxContainer/IconContainer/Icon
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var description_label: Label = $VBoxContainer/DescriptionLabel
@onready var button: Button = $Button
@onready var panel: Panel = $Panel

var _is_ready: bool = false

func _ready() -> void:
	_is_ready = true
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	_update_display()

func _update_display() -> void:
	if not _is_ready or not weapon_data:
		return
	
	icon_texture.texture = weapon_data.icon
	name_label.text = weapon_data.display_name
	description_label.text = weapon_data.description

func _on_button_pressed() -> void:
	selected.emit(weapon_data)

func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
