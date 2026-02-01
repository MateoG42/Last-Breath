extends Node3D

signal game_started

var audio: AudioStreamPlayer

func _ready() -> void:
	audio = $AudioStreamPlayer
	audio.stream = preload('res://assets/audio/songs/Last breath menu_lobby.mp3')
	audio.play()

@rpc("authority", "call_local")
func start_match():
	audio.stream = load('res://assets/audio/songs/Last Breath Arena Song 1.mp3')
	audio.play()
	await get_tree().create_timer(5).timeout
	game_started.emit()


func _on_start_game_pressed() -> void:
	start_match.rpc()


func set_camera():
	$EndGameCamera.make_current()
