extends Control
class_name LevelUpCard

## A card displaying a weapon option in the level-up selection screen.
## Can display either a new weapon unlock or an upgrade for an existing weapon.

const WeaponDataScript = preload("res://scenes/weapons/weapon_data.gd")

signal selected(weapon_data: Resource, is_upgrade: bool)

@export var weapon_data: Resource:
	set(value):
		weapon_data = value
		_update_display()

## Whether this card represents an upgrade (true) or new unlock (false)
var is_upgrade: bool = false

## Current level of the weapon (only relevant for upgrades)
var current_level: int = 0

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


## Setup the card for a new weapon unlock
func setup(data: Resource) -> void:
	weapon_data = data
	is_upgrade = false
	current_level = 0
	_update_display()


## Setup the card for upgrading an existing weapon
func setup_upgrade(data: Resource, level: int) -> void:
	weapon_data = data
	is_upgrade = true
	current_level = level
	_update_display()


func _update_display() -> void:
	if not _is_ready or not weapon_data:
		return
	
	icon_texture.texture = weapon_data.icon
	
	if is_upgrade:
		name_label.text = weapon_data.display_name + " Lv." + str(current_level + 1)
		description_label.text = "Upgrade to level " + str(current_level + 1)
	else:
		name_label.text = weapon_data.display_name
		description_label.text = weapon_data.description


func _on_button_pressed() -> void:
	selected.emit(weapon_data, is_upgrade)


func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
