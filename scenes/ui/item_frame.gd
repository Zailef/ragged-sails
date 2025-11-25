@tool
extends NinePatchRect

@export var focused_material : ShaderMaterial
@export var focused_texture : Texture2D
var original_material : Material
var original_texture : Texture2D

func _ready():
	original_material = material
	original_texture = texture

	focus_mode = Control.FOCUS_ALL

func _on_mouse_entered() -> void:
	if focused_material:
		material = focused_material
	if focused_texture:
		texture = focused_texture

func _on_mouse_exited() -> void:
	material = original_material
	texture = original_texture
