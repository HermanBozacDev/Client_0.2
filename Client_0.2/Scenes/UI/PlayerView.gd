extends Control
@onready var level_text = $Panel/Level/LevelText

#@onready var nickname_text = $Panel/NicknameText

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



"""ACA ESTA LA INFO NOMAS QUE MOSTRAR EN EL PANEL DEL PLAYER VIEW"""
func RegularUpdate():
	if get_node("/root/SceneHandler/" + PlayerData.player_map ):
		var node = get_node("/root/SceneHandler/"  + PlayerData.player_map )
		if node.world_state_buffer.size() > 2:
			for player in node.world_state_buffer[2]:
				if str(player) == str(GameServer.multiplayer_api.get_unique_id()):
					#nickname_text.set_text(str(PlayerData.GetName()))   ACA SAQUE EL NICKNAME PORQUE LO VOY A CAMBIAR DE LUGAR PARA ARRIBA DEL PLAYER QUE LO VEAN TODOS DESPUES
					experience_bar.value = node.world_state_buffer[2][player]["Exp"]
					experience_bar.max_value = node.world_state_buffer[2][player]["ExpR"]
					health.value= node.world_state_buffer[2][player]["Health"]
					health.max_value =  node.world_state_buffer[2][player]["MHealth"]
					mana.value = node.world_state_buffer[2][player]["Mana"]
					mana.max_value = node.world_state_buffer[2][player]["MMana"]
					
					level_text.set_text(str(node.world_state_buffer[2][player]["Level"]))
					current_life.set_text(str(int(node.world_state_buffer[2][player]["Health"])))
					max_life.set_text(str(node.world_state_buffer[2][player]["MHealth"]))
					current_mana.set_text(str(int(node.world_state_buffer[2][player]["Mana"])))
					max_mana.set_text(str(node.world_state_buffer[2][player]["MMana"]))
