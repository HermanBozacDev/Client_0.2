extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

"""INIT"""
func _ready() -> void:
	audio_stream_player.play()

"""PLAY SOUNDTRACK"""
func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play()
