extends CharacterBody2D

var speed = 40.0
var animation_vector = Vector2()
var map = "CiudadPrincipal"
var clase = "elf"
var player_state
var moving = false#variable para saber si la accion Move esta siendo ejecutada
var destination = Vector2()
var angle_to_mouse_position
var direction
var windows  = false
#var inventory = preload("res://Scenes/UI/MultiPanel.tscn")
#var hotbar = preload("res://Scenes/UI/Hotbar.tscn")
var player_view = preload("res://Scenes/UI/PlayerView.tscn")
@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")

func _ready() -> void:
	#var hotbar_instance = hotbar.instantiate()
	#get_node("/root/SceneHandler/CanvasLayer").add_child(hotbar_instance)
	var player_view_instance = player_view.instantiate()
	get_node("/root/SceneHandler/CanvasLayer").add_child(player_view_instance)
	set_physics_process(false)

func DefinePlayerState():
	var my_position = get_global_position()
	var health = PlayerData.stats_dic["health"]
	var maxHealth = PlayerData.stats_dic["maxhealth"]
	var mana = PlayerData.stats_dic["mana"]
	var maxMana = PlayerData.stats_dic["maxmana"] 
	player_state = {
		"T": GameServer.client_clock, 
		"M":map , 
		"C": clase,
		"Px": int(my_position.x),
		"Py": int(my_position.y),
		"A": animation_vector,
		"H": health,
		"mH": maxHealth,
		"Ma": mana,
		"mMa": maxMana
		}
	var key = "PlayerState"
	GameServer.ClientSendDataToServer(key,player_state)

	
	
	
func set_variables():
	#fire_direction = (get_angle_to(get_global_mouse_position()) / 3.14) * 100
	angle_to_mouse_position = get_angle_to(get_global_mouse_position())
	direction = get_node("TurnAxis/Position2D").get_global_position().direction_to(get_global_mouse_position().normalized())

func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("I"):
	#	if windows == false:
	#		var inventory_instance = inventory.instantiate()
	#		windows = true
	#		get_parent().get_parent().get_parent().get_node("CanvasLayer").add_child(inventory_instance)
	#		var inventory_position = Vector2(124,70)
	#		get_parent().get_parent().get_parent().get_node("CanvasLayer/MultiPanel").set_position(inventory_position)
	#	else:
	#		var actual_window = get_tree().get_nodes_in_group("Windows")
	#		for window in actual_window:
	#			get_parent().get_parent().get_parent().get_node("CanvasLayer/MultiPanel").queue_free()
	#		windows = false
	#if Input.is_action_pressed("SpaceBar"):
	#	PlayerData.PrepareTestAtaack()
	#if Input.is_action_pressed("S"):
#		moving = false
	if Input.is_action_pressed("Move"):
		moving = true
		destination = get_global_mouse_position()
	if moving == false:
		speed = 0
	else:
		Move()
	DefinePlayerState()

func Move():
	
	#NUEVA IMP
	var movement = position.direction_to(destination) * speed
	if position.distance_to(destination) > 4:
		speed = 200
		velocity = movement
		move_and_slide() 
		animation_vector = movement.normalized()
		animation_tree.set("parameters/Walk/blend_position", animation_vector)
		animation_tree.set("parameters/Idle/blend_position", animation_vector)
		animation_mode.travel("Walk")
	else:
		moving = false
		animation_mode.travel("Idle")

func Attack(a_rotation,a_position,attack_name,skill_instance,attack_type):
	
	moving = false
	var a_direction = direction
	animation_vector = position.direction_to(get_global_mouse_position()).normalized()   
	GameServer.Attack(position, animation_vector, a_rotation, a_position, a_direction,map,attack_name,attack_type)
	get_parent().add_child(skill_instance)
		
