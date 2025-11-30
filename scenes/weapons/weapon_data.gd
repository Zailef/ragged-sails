extends Resource
class_name WeaponData

## Metadata for a weapon used in the unlock/selection system.

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var weapon_scene: PackedScene

## Whether this weapon is available from the start
@export var starts_unlocked: bool = false
