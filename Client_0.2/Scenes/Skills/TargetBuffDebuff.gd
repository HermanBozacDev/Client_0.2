extends Node2D

var processing_body = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("position",get_global_position())
	await (get_tree().create_timer(0.1).timeout)
	queue_free()
