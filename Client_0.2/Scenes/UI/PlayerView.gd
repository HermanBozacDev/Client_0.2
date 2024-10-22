extends Control
@onready var level_text = $Panel/Level/LevelText
@onready var nickname_text = $Panel/NicknameText
@onready var experience_bar = $Panel/ExperienceBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_text.set_text(str(PlayerData.stats_dic["level"]))
	nickname_text.set_text(str(PlayerData.player_name))
	experience_bar.value = PlayerData.stats_dic["exp"]
	experience_bar.max_value =PlayerData.stats_dic["expRequerida"]
