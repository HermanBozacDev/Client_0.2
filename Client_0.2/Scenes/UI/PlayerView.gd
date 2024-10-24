extends Control
@onready var level_text = $Panel/Level/LevelText
@onready var nickname_text = $Panel/NicknameText
@onready var experience_bar = $Panel/ExperienceBar
@onready var mana = $Panel/Mana
@onready var health = $Panel/Health


# Called when the node enters the scene tree for the first time.
func _physics_process(_delta: float) -> void:
	#print("player id rpc",GameServer.multiplayer_api.get_unique_id())
	var _key = GameServer.multiplayer_api.get_unique_id()
	if get_node("/root/SceneHandler/CiudadPrincipal"):
		var node = get_node("/root/SceneHandler/CiudadPrincipal")
		if node.world_state_buffer.size() > 2:
			for player in node.world_state_buffer[2]:
				#print("player",player)
				if str(player) == str(GameServer.multiplayer_api.get_unique_id()):
					level_text.set_text(str(node.world_state_buffer[2][player]["L"]))
					nickname_text.set_text(str(PlayerData.player_name))
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
