extends Resource
class_name ScatterConfig

## Configuration for scattering environmental objects across the play area.

@export_group("Objects")
## Objects to scatter in the world
@export var entries: Array[ScatterEntry] = []

@export_group("Placement")
## Margin from the boundary edge (objects won't spawn too close to edges)
@export var boundary_margin: float = 100.0

## Maximum placement attempts per object before giving up
@export var max_placement_attempts: int = 50

## Global minimum spacing between any two scattered objects
@export var global_min_spacing: float = 80.0

@export_group("Density")
## Use density-based spawning instead of fixed counts
@export var use_density_spawning: bool = true

## Target objects per 1000x1000 pixel area (used when density spawning is enabled)
@export var objects_per_1000_sq: float = 8.0

@export_group("Clustering")
## Whether to enable clustered spawning (groups of objects near each other)
@export var enable_clustering: bool = true

## Chance (0-1) that an object spawns as part of a cluster
@export_range(0.0, 1.0) var cluster_chance: float = 0.4

## Minimum objects per cluster
@export var min_cluster_size: int = 2

## Maximum objects per cluster
@export var max_cluster_size: int = 4

## Radius around cluster center for placing clustered objects
@export var cluster_radius: float = 150.0

@export_group("Seed")
## Use a fixed seed for reproducible scattering (0 = random each time)
@export var random_seed: int = 0
