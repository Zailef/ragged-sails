extends Node

@warning_ignore_start("unused_signal")

signal enemy_defeated
signal exp_gained(amount: int)
signal player_levelled_up(new_level: int, exp_to_next: int)
signal max_level_reached

# Weapon unlock signals
signal weapon_unlocked(weapon_data: Resource)
signal level_up_selection_made

# Map boundary signals
signal boundary_zone_changed(zone: String)

@warning_ignore_restore("unused_signal")
