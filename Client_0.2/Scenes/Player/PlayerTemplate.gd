extends CharacterBody2D
var skill = preload("res://Scenes/Skills/SingleTargetRangedSkill.tscn")
@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")
var attack_dict = {}
var player_stats
var darkelf_texture = load("res://Resources/Players/DarkElf/DarkElf.png")
var elf_texture = load("res://Resources/Players/Elf/Elf.png")
var human_texture = load("res://Resources/Players/Human/Human.png")
var orc_texture = load("res://Resources/Players/Orc/Orc.png")
var dwarven_texture = load("res://Resources/Players/Dwarf/Dwarf.png")

"""ACA MUEVO A LOS OTROS JUGADORES"""
func MovePlayer(new_position, animation_vector):
	animation_tree.set("parameters/Walk/blend_position", animation_vector)
	animation_tree.set("parameters/Idle/blend_position", animation_vector)
	if new_position == position:
		animation_mode.travel("Idle")
	else:
		set_position(new_position)
		animation_mode.travel("Walk")

"""ACA HAGO QUE ATAQUEN LOS OTROS JUGADORES"""
func attack():
	for attack_object in attack_dict.keys():
		if attack_object <= GameServer.client_clock:
			var skill_instance = skill.instantiate()
			skill_instance.position = attack_dict[attack_object]["Position"]
			skill_instance.rotation = attack_dict[attack_object]["Rotation"]
			attack_dict.erase(attack_object)
			#await get_tree().create_timer(0.2).timeout
			get_parent().add_child(skill_instance)


@onready var sprite = get_node("Sprite")

"""INIT"""
func _ready() -> void:
	match player_stats["Class"]:
		"darkelf":
			sprite.set_texture(darkelf_texture)
		"elf":
			sprite.set_texture(elf_texture)
		"human":
			sprite.set_texture(human_texture)
		"orc":
			sprite.set_texture(orc_texture)
		"dwarven":
			sprite.set_texture(dwarven_texture)
