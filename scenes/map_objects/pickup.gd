@tool
class_name Pickup
extends Area3D

@export var item_data: ItemData:
	set(new_item):
		item_data = new_item
		$Sprite3D.texture = item_data.sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _enter_tree() -> void:
	$Sprite3D.texture = item_data.sprite


func _on_body_entered(body: Node3D) -> void:
	var item_grabbed = false
	if body.has_method('grab_item'):
		item_grabbed = body.grab_item(item_data)
	
	if item_grabbed:
		self.queue_free()
		
