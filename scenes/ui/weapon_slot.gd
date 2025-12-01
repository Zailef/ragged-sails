extends Control
class_name WeaponSlot

## A single weapon slot showing the weapon icon and level.

@onready var icon_texture: TextureRect = $IconTexture
@onready var level_label: Label = $LevelLabel

var weapon_data: Resource = null
var level: int = 1

func setup(data: Resource, initial_level: int = 1) -> void:
	weapon_data = data
	level = initial_level
	_update_display()

func set_level(new_level: int) -> void:
	level = new_level
	_update_display()

func _update_display() -> void:
	if not is_inside_tree():
		await ready
	
	if weapon_data and weapon_data.icon:
		icon_texture.texture = weapon_data.icon
	
	level_label.text = str(level)
