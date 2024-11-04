extends Node2D

const interpolation_offset = 10
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var instantiated_players = {}
var last_world_state = 0
var world_state_buffer = []
var eliminated_players 
@onready var other_players_node = get_node("MapElements/OtherPlayers")
var skullman= preload("res://Scenes/Enemies/SkullMan.tscn")

""" SPAWN OTROS JUGADORES """
func SpawnNewPlayer(player_id, spawn_position,player_stats):
	if int(player_id) == GameServer.multiplayer_api.get_unique_id():
		return # No instancias a ti mismo
	if not other_players_node.has_node(str(player_id)):
		var new_player = player_spawn.instantiate()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		new_player.player_stats = player_stats
		other_players_node.add_child(new_player)
		instantiated_players[player_id] = new_player

"""DESPAWN OTROS JUGADORES"""
func DespawnPlayer(player_id):
	var player_node = other_players_node.get_node_or_null(str(player_id))
	if player_node:
		player_node.queue_free()
		instantiated_players.erase(player_id)
		eliminated_players = player_id

"""ACA ADMINISTRO  CUANDO TENGO ESTADOS FUTUROS Y CUANDO NO"""
func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	# Mantén solo los 3 estados más recientes
	if world_state_buffer.size() > 3:
		world_state_buffer.remove_at(0)
	if world_state_buffer.size() > 1:
		if world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			WithFutureState()
		elif render_time > world_state_buffer[1].T:
			NoFotureState()

"""CON ESTADO FUTURO"""
func WithFutureState():
	for player in world_state_buffer[2].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if str(player) == "Mapa2":
			continue
		if str(player) == "CiudadCentral":
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[1].has(player):
			continue
		if other_players_node.has_node(str(player)):

			var new_position =Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var animation_vector = world_state_buffer[2][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)
		else:
			if  str(player) == str(eliminated_players):
				return
			var new_position = Vector2(world_state_buffer[2][player]["Px"], world_state_buffer[2][player]["Py"])
			var player_stats = world_state_buffer[2][player]
			SpawnNewPlayer(player, new_position,player_stats)


"""SIN ESTADO FUTURO"""
func NoFotureState():
	for player in world_state_buffer[1].keys():
		if str(player) in ["T", "CiudadPrincipal"]:
			continue
		if str(player) == "Mapa2":
			continue
		if str(player) == "CiudadCentral":
			continue
		if player == str(GameServer.multiplayer_api.get_unique_id()):
			continue
		if not world_state_buffer[0].has(player):
			continue
		if other_players_node.has_node(str(player)):
			var new_position =  Vector2(world_state_buffer[1][player]["Px"], world_state_buffer[1][player]["Py"])
			var animation_vector = world_state_buffer[1][player]["A"]
			other_players_node.get_node(str(player)).MovePlayer(new_position,animation_vector)

"""ACTUALIZO EL WORLD STATE CON EL ESTADO QUE LLEGA DEL SERVIDOR"""
func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
