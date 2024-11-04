extends Control
@onready var active_skills_grid = $Background/ActiveSkills/Grid
@onready var pasive_skills_grid = $Background/PasiveSkills/Grid
@onready var pasive_skills = $Background/PasiveSkills
@onready var active_skills = $Background/ActiveSkills

"""INIT"""
func _ready() -> void:
	var count = 1
	for skill in PlayerData.learn_skill_dic.values():
		var slot_new = load("res://Scenes/UI/MultiSlot.tscn").instantiate()
		slot_new.set_name(str(count))
		slot_new.type = "skills"
		slot_new.group = "skills"
		slot_new.id = skill[0]
		slot_new.skill_type = skill[1]
		if skill[1] == "a":
			active_skills_grid.add_child(slot_new)
		else:
			pasive_skills_grid.add_child(slot_new)
		count += 1
	pasive_skills.hide()
	active_skills.show()

"""ACTIVOS"""
func _on_active_skills_button_pressed() -> void:
	pasive_skills.hide()
	active_skills.show()

"""PASIVOS"""
func _on_pasive_skills_button_pressed() -> void:
	pasive_skills.show()
	active_skills.hide()

"""ACCION MOVE"""
func _on_move_pressed() -> void:
	PlayerData.move_skill = true

"""ACCION INFO"""
func _on_info_pressed() -> void:
	pass
