extends Node

@warning_ignore_start("unused_signal")

signal enemy_defeated(is_boss: bool)
signal exp_gained(amount: int)
signal player_levelled_up(new_level: int, exp_to_next: int)
signal max_level_reached

# Weapon unlock signals
signal weapon_unlocked(weapon_data: Resource)
signal level_up_selection_made

# Map boundary signals
signal boundary_zone_changed(zone: String)

# Spawning signals
signal wave_announced(announcement_text: String)
signal boss_incoming

# Chest/Weapon upgrade signals
signal chest_collected
signal weapon_upgrade_selected(weapon: BaseWeapon)
signal weapon_acquired
signal weapon_upgraded

# Pickup signals
signal health_pickup_collected(amount: int)

# Player signals
signal player_died

# Menu signals
signal menu_closed

@warning_ignore_restore("unused_signal")
