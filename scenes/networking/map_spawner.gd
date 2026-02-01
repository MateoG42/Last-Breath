extends MultiplayerSpawner

@export var network_player: PackedScene
@export var network_item: PackedScene

var spawns: Array

func _ready() -> void:
	spawns = get_children()
	
	spawn_function = spawn_player
	
	multiplayer.peer_connected.connect(
		func(pid):
			print('peer ' + str(pid) + ' joined!')
			spawn(pid)
	)


func spawn_player(id: int):
	var location = spawns.pick_random()
	spawns.erase(location)
	
	var player = network_player.instantiate()
	player.name = str(id)
	player.global_position = location.global_position
	
	get_parent().game_started.connect(player._on_game_started)
	
	return player
