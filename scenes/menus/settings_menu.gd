extends Control

@onready var audio_sampler_debounce: Timer = $AudioSamplerDebounce
@onready var sfx_sampler: AudioStreamPlayer = $SFXSampler
@onready var master_volume_slider: Slider = %MasterVolumeSlider
@onready var music_volume_slider: Slider = %MusicVolumeSlider
@onready var sfx_volume_slider: Slider = %SFXVolumeSlider

@onready var master_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_MASTER)
@onready var music_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_MUSIC)
@onready var sfx_audio_bus_idx: int = AudioServer.get_bus_index(SettingsManager.AUDIO_BUS_SFX)

var main_menu_scene: PackedScene = load("res://scenes/menus/main_menu.tscn")
var can_sample: bool = true

func _ready() -> void:
	_read_settings()
	
	if not SettingsManager.settings_changed.is_connected(_on_settings_changed):
		SettingsManager.settings_changed.connect(_on_settings_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()

func _on_back_button_pressed() -> void:
	_back()

func _back() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_master_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("master_volume", value)

func _on_music_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("music_volume", value)

func _on_sfx_vol_slider_value_changed(value: float) -> void:
	SettingsManager.set_setting("sfx_volume", value)
	_play_audio_sample(sfx_sampler)

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
