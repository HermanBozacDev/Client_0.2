extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play()




func _on_audio_stream_player_finished() -> void:
	audio_stream_player.play()
