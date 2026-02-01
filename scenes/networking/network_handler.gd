extends Node

@export var spawner: MultiplayerSpawner

const IP_ADDRESS: String = 'localhost'
const PORT: int = 42069

var peer: ENetMultiplayerPeer


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	spawner.spawn_player(multiplayer.get_unique_id())


func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer


func _on_server_btn_pressed() -> void:
	start_server()


func _on_client_btn_pressed() -> void:
	start_client()
