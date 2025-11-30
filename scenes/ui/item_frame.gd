@tool
extends NinePatchRect

signal selected(weapon_data: Resource)

@export var focused_material: ShaderMaterial
@export var focused_texture: Texture2D

var original_material: Material
var original_texture: Texture2D
var weapon_data: Resource

@onready var icon_texture: TextureRect = $VBoxContainer/IconContainer/Icon if has_node("VBoxContainer/IconContainer/Icon") else null
@onready var name_label: Label = $VBoxContainer/NameLabel if has_node("VBoxContainer/NameLabel") else null
@onready var description_label: Label = $VBoxContainer/DescriptionLabel if has_node("VBoxContainer/DescriptionLabel") else null

func _ready():
	original_material = material
	original_texture = texture
	focus_mode = Control.FOCUS_ALL

func setup(data: Resource) -> void:
	weapon_data = data
	if icon_texture and data.icon:
		icon_texture.texture = data.icon
	if name_label:
		name_label.text = data.display_name
	if description_label:
		description_label.text = data.description

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
				selected.emit(weapon_data)
