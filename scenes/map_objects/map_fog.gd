extends FogVolume


func shrink():
	var shrink_tween = get_tree().create_tween()
	shrink_tween.parallel().tween_property($SafeFog, 'size:x', max($SafeFog.size.x - 1, 0), 1)
	shrink_tween.parallel().tween_property($SafeFog, 'size:z', max($SafeFog.size.z - 1, 0), 1)
	shrink_tween.parallel().tween_property(%SafeShape, 'shape:radius', max(%SafeShape.shape.radius - 0.5, 0), 1)


func _on_exit_fog_safety(body: Node3D):
	if body.has_method('exit_fog_safety'):
		body.exit_fog_safety()


func _on_enter_fog_safety(body: Node3D):
	if body.has_method('enter_fog_safety'):
		body.enter_fog_safety()
