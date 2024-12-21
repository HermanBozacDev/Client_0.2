extends Control

@onready var type_text = $Background/TypeText
@onready var speed_text = $Background/SpeedText
@onready var p_attack_text = $Background/PAttackText
@onready var attack_speed_text = $Background/AttackSpeedText
@onready var p_defence_text = $Background/PDefenceText
@onready var casting_speed_text = $Background/CastingSpeedText
@onready var m_attack_text = $Background/MAttackText
@onready var critic_text = $Background/CriticText
@onready var m_defence_text = $Background/MDefenceText
@onready var m_critic_text = $Background/MCriticText
@onready var con_text = $Background/ConText
@onready var dex_text = $Background/DexText
@onready var str_text = $Background/StrText
@onready var int_text = $Background/IntText

func _ready():
	type_text.set_text(str(PlayerData.stats_dic["Type"]))
	speed_text.set_text(str(PlayerData.stats_dic["Speed"]))
	p_attack_text.set_text(str(PlayerData.stats_dic["PAtk"]))
	attack_speed_text.set_text(str(PlayerData.stats_dic["ASpeed"]))
	p_defence_text.set_text(str(PlayerData.stats_dic["PDef"]))
	casting_speed_text.set_text(str(PlayerData.stats_dic["CSpeed"]))
	m_attack_text.set_text(str(PlayerData.stats_dic["MAtk"]))
	critic_text.set_text(str(PlayerData.stats_dic["Crit"]))
	m_defence_text.set_text(str(PlayerData.stats_dic["MDef"]))
	m_critic_text.set_text(str(PlayerData.stats_dic["MCrit"]))
	con_text.set_text(str(PlayerData.stats_dic["Con"]))
	dex_text.set_text(str(PlayerData.stats_dic["Dex"]))
	str_text.set_text(str(PlayerData.stats_dic["Str"]))
	int_text.set_text(str(PlayerData.stats_dic["Int"]))
