extends Node

@onready var audio_stream_player: AudioStreamPlayer = $MusicPlayer
@onready var music_transition_timer: Timer = $MusicTransitionTimer

@export var min_seconds_between_music: float = 5
@export var max_seconds_between_music: float = 15

var music_map: Dictionary = {
	"theme_1": preload("res://audio/music/modern-pirate-adventure-435821.mp3"),
	"theme_2": preload("res://audio/music/pirate-adventure-361663.mp3"),
	"theme_3": preload("res://audio/music/pirate-ship-354089.mp3"),
}

var music_keys: Array = []
var current_track_index: int = 0

func _ready() -> void:
	audio_stream_player.finished.connect(_on_audio_finished)
	music_transition_timer.timeout.connect(_on_music_transition_timeout)

	music_keys = music_map.keys()
	music_keys.sort()

	current_track_index = randi() % music_keys.size()
	_play_track_by_index(current_track_index)

func _on_audio_finished() -> void:
	music_transition_timer.wait_time = randf_range(min_seconds_between_music, max_seconds_between_music)
	music_transition_timer.start()

func _on_music_transition_timeout() -> void:
	current_track_index = (current_track_index + 1) % music_keys.size()
	_play_track_by_index(current_track_index)
	music_transition_timer.stop()

func _play_track_by_index(index: int) -> void:
	var key = music_keys[index]
	audio_stream_player.stream = music_map[key]
	audio_stream_player.play()
