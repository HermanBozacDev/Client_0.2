extends CharacterBody2D

var speed = 40.0
var player_state
var angle_to_mouse_position
var direction

var animation_vector = Vector2()
var destination = Vector2()

var windows  = false
var attacking = false
var moving = false

var darkelf_texture = load("res://Resources/Players/DarkElf/DarkElf.png")
var elf_texture = load("res://Resources/Players/Elf/Elf.png")
var human_texture = load("res://Resources/Players/Human/Human.png")
var orc_texture = load("res://Resources/Players/Orc/Orc.png")
var dwarven_texture = load("res://Resources/Players/Dwarf/Dwarf.png")

@onready var animation_tree = get_node("AnimationTree")
@onready var animation_mode = animation_tree.get("parameters/playback")
@onready var sprite = get_node("Sprite")








"""INIT"""
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

"""ACA DEFINO MI ESTADO PARA MANDAR AL SERVIDOR"""
"""SOLAMENTE DEFINO ACA LA POSICION TIEMPO DEL CLIENTE Y EL VECTOR DE ANIMACION"""
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

"""SETEAR ANGLE TO MOUSE Y DIRECCION"""
func set_variables():
	angle_to_mouse_position = get_angle_to(get_global_mouse_position())
	direction = get_node("TurnAxis/Position2D").get_global_position().direction_to(get_global_mouse_position().normalized())

"""ACA PROCESO LAS ACCIONES Y BOTONES Y ENVIO EL ESTADO"""
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Esc"):
		for node in get_tree().get_nodes_in_group("Panel"):
			node.queue_free()
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

"""FUNCION DE MOVE"""
func Move():
	print("mmoveee")
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

"""FUNCION DE APLICAR BUFFDEBUFF EN UN PLAYER TODAVIA NO ESTA APLICADA. IGUAL ESO VA EN EL LADO DEL SERVIDOR"""
func TargetBuff():
	pass
	
