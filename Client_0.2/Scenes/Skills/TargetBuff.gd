extends Node2D

var processing_body = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await (get_tree().create_timer(0.1).timeout)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_target_area_body_entered(body: Node2D) -> void:
	print("emcontre un cuerpo",body)
	if processing_body == false:
		processing_body = true
		if body.TargetBuff():
			body.TargetBuff()
			
		get_node("TargetArea/CollisionShape2D").set_deferred("disabled", true)
		self.hide()
		
	else:
		get_node("TargetArea/CollisionShape2D").set_deferred("disabled", true)
		self.hide()
