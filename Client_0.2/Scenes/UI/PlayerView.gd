extends Control
@onready var level_text = $Panel/Level/LevelText
@onready var nickname_text = $Panel/NicknameText
@onready var experience_bar = $Panel/ExperienceBar
@onready var mana = $Panel/Mana
@onready var health = $Panel/Health


#etiquetas en las barras 
@onready var current_life: Label = $Panel/Health/HBoxContainer/CurrentLife
@onready var max_life: Label = $Panel/Health/HBoxContainer/MaxLife
@onready var current_mana: Label = $Panel/Mana/HBoxContainer2/CurrentMana
@onready var max_mana: Label = $Panel/Mana/HBoxContainer2/MaxMana
@onready var current_exp: Label = $Panel/ExperienceBar/HBoxContainer3/CurrentExp
@onready var max_exp: Label = $Panel/ExperienceBar/HBoxContainer3/MaxExp




func RegularUpdate():
	level_text.set_text(str(PlayerData.GetLevel()))
	nickname_text.set_text(str(PlayerData.GetName()))
	if get_node("/root/SceneHandler/" + PlayerData.player_map ):
		var node = get_node("/root/SceneHandler/"  + PlayerData.player_map )
		if node.world_state_buffer.size() > 2:
			for player in node.world_state_buffer[2]:
				if str(player) == str(GameServer.multiplayer_api.get_unique_id()):
					level_text.set_text(str(node.world_state_buffer[2][player]["L"]))
					experience_bar.value = node.world_state_buffer[2][player]["EXP"]

					experience_bar.max_value = node.world_state_buffer[2][player]["EXPRQ"]
					var percentage_hp = int((float(node.world_state_buffer[2][player]["H"]) / node.world_state_buffer[2][player]["mH"]) * 100)
					health.value = percentage_hp
					
					if percentage_hp >= 60:
						health.set_tint_progress("14e114")
					elif percentage_hp <= 60 and percentage_hp >= 25:
						health.set_tint_progress("e1be32")
					else:
						health.set_tint_progress("e11e1e")
					var percentage_mp = int((float(node.world_state_buffer[2][player]["Ma"]) / node.world_state_buffer[2][player]["mMa"]) * 100)
					mana.value = percentage_mp
					current_exp.set_text(str(experience_bar.value))
					max_exp.set_text(str(experience_bar.max_value))
					current_life.set_text(str(node.world_state_buffer[2][player]["H"]))
					max_life.set_text(str(node.world_state_buffer[2][player]["mH"]))
					current_mana.set_text(str(node.world_state_buffer[2][player]["Ma"]))
					max_mana.set_text(str(node.world_state_buffer[2][player]["mMa"]))
