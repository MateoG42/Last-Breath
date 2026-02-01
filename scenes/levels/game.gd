extends Node3D

signal game_started

@rpc("authority", "call_local")
func start_match():
	
	game_started.emit()


func _on_start_game_pressed() -> void:
	start_match.rpc()


func set_camera():
	$EndGameCamera.make_current()
