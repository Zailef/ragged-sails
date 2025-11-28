extends Resource
class_name WeaponStats

enum WeaponType {
	AUTO_LOOP,
	DURATION_LOOP
}

@export var weapon_type: WeaponType = WeaponType.AUTO_LOOP
@export var damage: int = 10
@export var cooldown: float = 0.0
@export var duration: float = 0.0
@export var speed: float = 1.0
@export var max_range: float = -1.0 # -1 means unlimited range
