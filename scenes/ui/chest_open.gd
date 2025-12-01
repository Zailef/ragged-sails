extends Control
class_name ChestOpen

## Displays a chest that can be clicked to upgrade a random unlocked weapon.

signal chest_opened(weapon: BaseWeapon, new_level: int)

@onready var dimmer: ColorRect = $Dimmer
@onready var chest_sprite: AnimatedSprite2D = %ChestSprite
@onready var prompt_label: Label = %PromptLabel
@onready var result_container: VBoxContainer = %ResultContainer
@onready var weapon_icon: TextureRect = %WeaponIconOverlay
@onready var weapon_name_label: Label = %WeaponNameLabel
@onready var level_label: Label = %LevelLabel
@onready var description_label: Label = %DescriptionLabel
@onready var continue_button: Button = %ContinueButton

var _weapon_manager: WeaponManager = null
var _upgraded_weapon: BaseWeapon = null
var _new_level: int = 0
var _is_opening: bool = false
var _can_click: bool = true

func _ready() -> void:
	SignalManager.chest_collected.connect(_on_chest_collected)
	hide()
	result_container.hide()
	continue_button.hide()
	continue_button.pressed.connect(_on_continue_pressed)


func _get_weapon_manager() -> WeaponManager:
	if not _weapon_manager:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			_weapon_manager = player.weapon_manager
	return _weapon_manager


func _on_chest_collected() -> void:
	_show_chest()


func _show_chest() -> void:
	var weapon_mgr = _get_weapon_manager()
	if not weapon_mgr:
		push_error("ChestOpen: Could not find WeaponManager")
		return

	# Check if there are any unlocked weapons to upgrade
	var unlocked_ids = weapon_mgr.get_unlocked_weapons()
	if unlocked_ids.is_empty():
		# No weapons to upgrade, skip
		return

	# Reset state
	_is_opening = false
	_can_click = true
	_upgraded_weapon = null
	result_container.hide()
	continue_button.hide()
	weapon_icon.hide()
	prompt_label.text = "Click the chest to open!"
	prompt_label.show()

	# Start with idle/jiggle animation
	chest_sprite.play("jiggle")

	# Pause the game and show
	get_tree().paused = true
	show()


func _gui_input(event: InputEvent) -> void:
	if not _can_click:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not _is_opening:
				_open_chest()


func _open_chest() -> void:
	_is_opening = true
	_can_click = false
	prompt_label.hide()

	# Play opening animation
	chest_sprite.play("opening")
	await chest_sprite.animation_finished

	# Stay on open frame
	chest_sprite.play("open")

	# Upgrade a random weapon
	_upgrade_random_weapon()


func _upgrade_random_weapon() -> void:
	var weapon_mgr = _get_weapon_manager()
	if not weapon_mgr:
		_close()
		return

	var unlocked_ids = weapon_mgr.get_unlocked_weapons()
	if unlocked_ids.is_empty():
		_close()
		return

	# Pick a random unlocked weapon
	var random_id = unlocked_ids[randi() % unlocked_ids.size()]
	var weapon = weapon_mgr.get_weapon(random_id)

	if not weapon or not weapon.level_manager:
		push_error("ChestOpen: Selected weapon is invalid or has no level manager")
		_close()
		return

	# Level up the weapon through WeaponManager (so signals are emitted)
	var old_level = weapon.level_manager.current_level
	var success = weapon_mgr.upgrade_weapon(random_id)

	if success:
		_upgraded_weapon = weapon
		_new_level = weapon.level_manager.current_level
		_show_result(weapon, old_level, _new_level)
		chest_opened.emit(weapon, _new_level)
		SignalManager.weapon_upgrade_selected.emit(weapon)
	else:
		# Weapon is at max level (and overflow disabled), try another
		# For simplicity, just close - in a full implementation you'd try other weapons
		push_warning("ChestOpen: Weapon upgrade failed, possibly at max level.")
		_close()


func _show_result(weapon: BaseWeapon, old_level: int, new_level: int) -> void:
	# Get weapon data for display
	var weapon_id = weapon.name.to_lower()
	var weapon_data: WeaponData = null

	if weapon_id in WeaponConstants.WEAPON_DATA_PATHS:
		weapon_data = load(WeaponConstants.WEAPON_DATA_PATHS[weapon_id])

	if weapon_data:
		weapon_icon.texture = weapon_data.icon
		weapon_name_label.text = weapon_data.display_name
	else:
		weapon_icon.texture = null
		weapon_name_label.text = weapon.name.capitalize()

	level_label.text = "Level %d → %d" % [old_level, new_level]

	# Get level description if available
	if weapon.level_manager.progression:
		var level_data = weapon.level_manager.progression.get_level(new_level)
		if level_data and level_data.level_up_description != "":
			description_label.text = level_data.level_up_description
			description_label.show()
		else:
			description_label.text = "Weapon upgraded!"
			description_label.show()
	else:
		description_label.text = "Weapon upgraded!"
		description_label.show()

	weapon_icon.show()
	result_container.show()
	continue_button.show()
	continue_button.grab_focus()


func _on_continue_pressed() -> void:
	_close()


func _close() -> void:
	hide()
	get_tree().paused = false
