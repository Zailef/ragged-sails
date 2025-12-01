extends CanvasLayer
class_name PauseMenu

## In-game pause menu with volume settings and navigation options.

var main_menu_scene: PackedScene = load("res://scenes/menus/main_menu.tscn")

@onready var audio_sampler_debounce: Timer = %AudioSamplerDebounce
@onready var sfx_sampler: AudioStreamPlayer = %SFXSampler
@onready var master_volume_slider: Slider = %MasterVolumeSlider
@onready var music_volume_slider: Slider = %MusicVolumeSlider
@onready var sfx_volume_slider: Slider = %SFXVolumeSlider
@onready var resume_button: Button = %ResumeButton

@onready var master_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_MASTER)
@onready var music_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_MUSIC)
@onready var sfx_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_SFX)
@onready var pause_button: Button = %PauseButton
@onready var dimmer: ColorRect = $Dimmer
@onready var center_container: CenterContainer = $MarginContainer/CenterContainer

var can_sample: bool = true
var _is_paused: bool = false
var _is_initial_slider_change: bool = true

func _ready() -> void:
	# Start with menu hidden but pause button visible
	_hide_menu()
	process_mode = Node.PROCESS_MODE_ALWAYS # Process even when game is paused

	_read_settings()

	if not SettingsManager.settings_changed.is_connected(_on_settings_changed):
		SettingsManager.settings_changed.connect(_on_settings_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not OS.has_feature("web"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	if _is_paused:
		_resume()
	else:
		_pause()


func _pause() -> void:
	_is_paused = true
	get_tree().paused = true
	_read_settings() # Refresh slider values
	_show_menu()
	resume_button.grab_focus()


func _resume() -> void:
	_is_paused = false
	_hide_menu()
	get_tree().paused = false
	SignalManager.menu_closed.emit()


func _show_menu() -> void:
	dimmer.show()
	center_container.show()
	pause_button.hide()


func _hide_menu() -> void:
	dimmer.hide()
	center_container.hide()
	pause_button.show()


func _on_pause_button_pressed() -> void:
	_pause()


func _on_resume_button_pressed() -> void:
	_resume()


func _on_main_menu_button_pressed() -> void:
	_is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_master_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("master_volume", value)


func _on_music_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("music_volume", value)


func _on_sfx_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("sfx_volume", value)

	if not _is_initial_slider_change:
		_play_audio_sample(sfx_sampler)
		_is_initial_slider_change = false


func _on_audio_sampler_debounce_timeout() -> void:
	can_sample = true


func _play_audio_sample(audio_sampler: AudioStreamPlayer) -> void:
	if can_sample:
		audio_sampler.play()
		can_sample = false
		audio_sampler_debounce.start()


func _on_settings_changed() -> void:
	_read_settings()


func _read_settings() -> void:
	var master_volume: float = SettingsManager.get_setting("master_volume", SettingsManager.MASTER_VOLUME_DEFAULT)
	master_volume_slider.value = master_volume
	AudioServer.set_bus_volume_db(master_audio_bus_idx, SettingsManager.linear_to_db(master_volume))

	var music_volume: float = SettingsManager.get_setting("music_volume", SettingsManager.MUSIC_VOLUME_DEFAULT)
	music_volume_slider.value = music_volume
	AudioServer.set_bus_volume_db(music_audio_bus_idx, SettingsManager.linear_to_db(music_volume))

	var sfx_volume: float = SettingsManager.get_setting("sfx_volume", SettingsManager.SFX_VOLUME_DEFAULT)
	sfx_volume_slider.value = sfx_volume
	AudioServer.set_bus_volume_db(sfx_audio_bus_idx, SettingsManager.linear_to_db(sfx_volume))
