@tool
extends FogVolume

@export var starting_size: float = 15
@export var shrink_amount: float = 1
@export var wait_time: float = 1


func _ready():
	update_size(starting_size)
	$Timer.wait_time = wait_time


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_size(starting_size)


func start():
	$Timer.start()


func update_size(radius):
	$SafeFog.size.x = radius*2
	$SafeFog.size.z = radius*2
	$%SafeShape.shape.radius = radius


func shrink():
	var shrink_tween = get_tree().create_tween()
	shrink_tween.parallel().tween_property($SafeFog, 'size:x', max($SafeFog.size.x - shrink_amount * 2, 0), 3)
	shrink_tween.parallel().tween_property($SafeFog, 'size:z', max($SafeFog.size.z - shrink_amount * 2, 0), 3)
	shrink_tween.parallel().tween_property(%SafeShape, 'shape:radius', max(%SafeShape.shape.radius - shrink_amount, 0), 3)


func _on_exit_fog_safety(body: Node3D):
	if body.has_method('exit_fog_safety'):
		body.exit_fog_safety()


func _on_enter_fog_safety(body: Node3D):
	if body.has_method('enter_fog_safety'):
		body.enter_fog_safety()


func _on_timer_timeout() -> void:
	shrink()
