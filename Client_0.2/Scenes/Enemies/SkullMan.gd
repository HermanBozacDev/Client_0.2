extends CharacterBody2D

@onready var health_bar = get_node("HealthBar")
@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")


var max_hp 
var current_hp
var type
var state
var experience 

func _physics_process(_delta):
	get_node("Label").set_text(str(state))
	

func _ready():
	animation_mode.start("Idle")

func MoveEnemy(new_position):
	#print("LLEGO A ENTRAR SI")
	set_position(new_position)
	
func HealthBarUpdate():
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	health_bar.value = percentage_hp
	if percentage_hp >= 60:
		health_bar.set_tint_progress("14e114")
	elif percentage_hp <= 60 and percentage_hp >= 25:
		health_bar.set_tint_progress("e1be32")
	else:
		health_bar.set_tint_progress("e11e1e")

func Health(health):
	if health != current_hp:
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0:
			OnDeath()






func AnimationMode(animation_vector):
	if state == "Idle":
		animation_mode.travel("Idle")
		animation_tree.set("parameters/Idle/blend_position", animation_vector)
	elif state == "Wander":
		animation_mode.travel("Walk")
		animation_tree.set("parameters/Walk/blend_position", animation_vector)
	elif state == "Chase":
		animation_mode.travel("Walk")
		animation_tree.set("parameters/Walk/blend_position", animation_vector)
	elif state == "Dead":
		animation_mode.travel("Dead")
		animation_tree.set("parameters/Dead/blend_position", animation_vector)
	elif state == "Attack":

		animation_mode.travel("Attack")
		animation_tree.set("parameters/Attack/blend_position", animation_vector)



func OnDeath():
	get_node("CollisionShape2D").set_deferred("disabled",true)
	#get_node("AnimationPlayer").play("Death_S")
	health_bar.hide()
	await(get_tree().create_timer(5).timeout)
	$Sprite2D.hide()
	queue_free()


func HitEffect():
	pass


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_mode.travel("Idle")
#	var animation_vector =  get_parent().get_parent().get_parent().world_state_buffer[1]["CiudadPrincipal"][get_name()]["A"]
#	animation_tree.set("parameters/Idle/blend_position", animation_vector)
