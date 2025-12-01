extends Resource
class_name ScatterEntry

## Defines a single object type that can be scattered in the world.

@export_group("Object")
## The scene to instantiate (should have collision if needed)
@export var scene: PackedScene

## Spawn weight relative to other entries (higher = more common)
@export_range(0.0, 10.0) var weight: float = 1.0

@export_group("Quantity")
## Minimum number to spawn
@export var min_count: int = 3

## Maximum number to spawn
@export var max_count: int = 8

@export_group("Placement")
## Minimum distance from other scattered objects
@export var min_spacing: float = 100.0

## Whether this object can spawn near the player start
@export var allow_near_player_start: bool = false

## Minimum distance from player start position
@export var player_start_exclusion_radius: float = 200.0

@export_group("Appearance")
## Whether to apply random rotation
@export var random_rotation: bool = true

## Whether to apply random scale variation
@export var random_scale: bool = true

## Minimum scale multiplier
@export_range(0.5, 1.0) var min_scale: float = 0.8

## Maximum scale multiplier
@export_range(1.0, 2.0) var max_scale: float = 1.2

## Whether to randomly flip horizontally
@export var random_flip_h: bool = true

## Whether to randomly flip vertically
@export var random_flip_v: bool = false
