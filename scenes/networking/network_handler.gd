extends Node

@export var spawner: MultiplayerSpawner

var ip_address: String = 'localhost'
var port: int = 42069

var peer: ENetMultiplayerPeer


func start_server() -> void:
	get_ip_and_port()
	
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	
	spawner.spawn(multiplayer.get_unique_id())
	%StartGame.visible = true
	%MenuContainer.visible = false


func start_client() -> void:
	get_ip_and_port()
	
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer
	
	%MenuContainer.visible = false


func get_ip_and_port():
	var ip_txt: String = %IP.text
	if ip_txt != '':
		ip_address = ip_txt
	var port_txt: String = %Port.text
	if port_txt != '':
		port = port_txt.to_int()


func _on_server_btn_pressed() -> void:
	start_server()


func _on_client_btn_pressed() -> void:
	start_client()
