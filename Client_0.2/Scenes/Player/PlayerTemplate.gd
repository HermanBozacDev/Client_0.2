extends CharacterBody2D
var skill = preload("res://Scenes/Skills/SingleTargetRangedSkill.tscn")
@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")
var attack_dict = {}
var player_stats

func MovePlayer(new_position, animation_vector):
	animation_tree.set("parameters/Walk/blend_position", animation_vector)
	animation_tree.set("parameters/Idle/blend_position", animation_vector)
	if new_position == position:
		animation_mode.travel("Idle")
	else:
		set_position(new_position)
		animation_mode.travel("Walk")


func attack():
	for attack_object in attack_dict.keys():
		if attack_object <= GameServer.client_clock:
			var skill_instance = skill.instantiate()
			skill_instance.position = attack_dict[attack_object]["Position"]
			skill_instance.rotation = attack_dict[attack_object]["Rotation"]
			attack_dict.erase(attack_object)
			#await get_tree().create_timer(0.2).timeout
			get_parent().add_child(skill_instance)
			
