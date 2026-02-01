@tool
class_name Pickup
extends Area3D

@export var item_data: ItemData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite3D.texture = item_data.sprite


func _on_body_entered(body: Node3D) -> void:
	var item_grabbed = false
	if body.has_method('grab_item'):
		item_grabbed = body.grab_item(item_data)
	
	if item_grabbed:
		remove_item.rpc()

@rpc('any_peer','call_local')
func remove_item():
	visible = false
	set_deferred('monitoring', false)
	set_deferred('monitorable', false)
	$AudioStreamPlayer3D.play()
	await $AudioStreamPlayer3D.finished
	self.queue_free()
