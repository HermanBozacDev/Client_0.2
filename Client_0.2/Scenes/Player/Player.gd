extends CharacterBody2D
var speed = 40.0
var animation_vector = Vector2()
var player_state
var moving = false#variable para saber si la accion Move esta siendo ejecutada
var destination = Vector2()
var angle_to_mouse_position
var direction
var windows  = false

var attacking = false

var inventory = preload("res://Scenes/UI/MultiPanel.tscn")
var darkelf_texture = load("res://Resources/Players/DarkElf/DarkElf.png")
var elf_texture = load("res://Resources/Players/Elf/Elf.png")
var human_texture = load("res://Resources/Players/Human/Human.png")
var orc_texture = load("res://Resources/Players/Orc/Orc.png")
var dwarven_texture = load("res://Resources/Players/Dwarf/Dwarf.png")

@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")

@onready var canvas_node =  get_node("/root/SceneHandler/CanvasLayer")

@onready var sprite = $Sprite









func _ready() -> void:
	match PlayerData.player_class:
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



func DefinePlayerState():
	var my_position = get_global_position()
	player_state = {
		"T": GameServer.client_clock, 
		"Px": int(my_position.x),
		"Py": int(my_position.y),
		"A": animation_vector,
		}
	var key = "PlayerState"
	GameServer.ClientSendDataToServer(key,player_state)

func ClearOldMenus():
	for menu in get_tree().get_nodes_in_group("Menu"):
		var node_name = menu.name
		canvas_node.get_node(str(node_name)).queue_free()
func ClearOldMultiPanel():
	for multi_panel in get_tree().get_nodes_in_group("Windows"):
		var node_name = multi_panel.name
		canvas_node.get_node(str(node_name)).queue_free()

func set_variables():
	angle_to_mouse_position = get_angle_to(get_global_mouse_position())
	direction = get_node("TurnAxis/Position2D").get_global_position().direction_to(get_global_mouse_position().normalized())

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("i"):
		ClearOldMenus()
		ClearOldMultiPanel()
		if windows == false:
			var inventory_instance = inventory.instantiate()
			canvas_node.add_child(inventory_instance)
			windows = true
		else:
			windows = false

	if Input.is_action_pressed("s"):
		moving = false
	if Input.is_action_pressed("SpaceBar"):
		if attacking == false:
			moving = false
			attacking = true
			var skill = preload("res://Scenes/Skills/FisicAttack.tscn")
			var skill_instance = skill.instantiate()
			set_variables()
			destination = position
			
			var a_rotation = angle_to_mouse_position
			get_node("TurnAxis").rotation = a_rotation
			skill_instance.rotation = a_rotation
			
			var a_position =  (get_node("TurnAxis/Position2D").get_global_position()-get_global_position())
			skill_instance.position = a_position
			
			add_child(skill_instance)
			animation_vector = position.direction_to(get_global_mouse_position()).normalized()   
			var value = ["FisicAttack","BasicAttack",a_rotation,a_position, animation_vector, GameServer.client_clock,PlayerData.player_map,get_node("TurnAxis/Position2D").get_global_position()]
			var key = "PlayerAttack"
			GameServer.ClientSendDataToServer(key, value)
			await (get_tree().create_timer(1).timeout)
			attacking = false
		else:
			return 

		#Attack(angle_to_mouse_position,get_node("TurnAxis/Position2D").get_global_position(),"FisicAttack",skill_instance,"Melee")

	if Input.is_action_pressed("Move"):
		moving = true
		destination = get_global_mouse_position()
		
	if moving:
		Move()
	#	speed = 0
	#else:
		#
	DefinePlayerState()


func Move():
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





func TargetBuff():
	print("llego aca")
	
