extends Node

signal settings_changed

const SAVE_PATH: String = "user://settings.cfg"
const MUTE_DB: float = -80.0
const SETTINGS_KEY: String = "Settings"
const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_MUSIC = "Music"
const AUDIO_BUS_SFX = "SFX"

const MASTER_VOLUME_DEFAULT = 1.0
const MUSIC_VOLUME_DEFAULT = 0.65
const SFX_VOLUME_DEFAULT = 1.0


var settings: Dictionary[String, Variant] = {
	"master_volume": MASTER_VOLUME_DEFAULT,
	"music_volume": MUSIC_VOLUME_DEFAULT,
	"sfx_volume": SFX_VOLUME_DEFAULT,
}

func _ready() -> void:
	load_settings()

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AUDIO_BUS_MASTER), linear_to_db(settings["master_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AUDIO_BUS_MUSIC), linear_to_db(settings["music_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(AUDIO_BUS_SFX), linear_to_db(settings["sfx_volume"]))

func set_setting(key: String, value) -> void:
	settings[key] = value
	save_settings()
	settings_changed.emit()

func get_setting(key: String, default_value = null) -> Variant:
	return settings.get(key, default_value)

func save_settings() -> void:
	var config = ConfigFile.new()
	for key in settings.keys():
		config.set_value(SETTINGS_KEY, key, settings[key])
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		for key in config.get_section_keys(SETTINGS_KEY):
			settings[key] = config.get_value(SETTINGS_KEY, key)

func linear_to_db(value: float) -> float:
	if value == 0:
		return MUTE_DB
	else:
		return 20 * log(value) / log(10)
