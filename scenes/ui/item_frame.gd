@tool
extends NinePatchRect

signal selected(weapon_data: Resource, is_upgrade: bool)

@export var focused_material: ShaderMaterial
@export var focused_texture: Texture2D

var original_material: Material
var original_texture: Texture2D
var weapon_data: Resource
var is_upgrade: bool = false
var current_level: int = 0

@onready var icon_texture: TextureRect = $VBoxContainer/IconContainer/Icon if has_node("VBoxContainer/IconContainer/Icon") else null
@onready var name_label: Label = $VBoxContainer/NameLabel if has_node("VBoxContainer/NameLabel") else null
@onready var description_label: Label = $VBoxContainer/DescriptionLabel if has_node("VBoxContainer/DescriptionLabel") else null

func _ready():
	original_material = material
	original_texture = texture
	focus_mode = Control.FOCUS_ALL


## Setup the card for a new weapon unlock
func setup(data: Resource) -> void:
	weapon_data = data
	is_upgrade = false
	current_level = 0
	if icon_texture and data.icon:
		icon_texture.texture = data.icon
	if name_label:
		name_label.text = data.display_name
	if description_label:
		description_label.text = data.description


## Setup the card for upgrading an existing weapon
func setup_upgrade(data: Resource, level: int) -> void:
	weapon_data = data
	is_upgrade = true
	current_level = level
	if icon_texture and data.icon:
		icon_texture.texture = data.icon
	if name_label:
		name_label.text = data.display_name + " Lv." + str(level + 1)
	if description_label:
		description_label.text = "Upgrade to level " + str(level + 1)


func _on_mouse_entered() -> void:
	if focused_material:
		material = focused_material
	if focused_texture:
		texture = focused_texture


func _on_mouse_exited() -> void:
	material = original_material
	texture = original_texture


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if weapon_data:
				selected.emit(weapon_data, is_upgrade)
