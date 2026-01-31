class_name Player
extends CharacterBody3D

@onready var viewport: Viewport = get_viewport()
@onready var viewport_center: Vector2 = Vector2(viewport.size / 2)

@export var character_render: CharacterRender
@export var speed: float = 5.0


func _process(_delta: float) -> void:
	rotate_item()
	if Input.is_action_just_pressed("attack"):
		character_render.melee_attack()


func _physics_process(_delta: float) -> void:
	handle_movement()


func handle_movement():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func check_attack_collision():
	var bodies: Array = %MeleeHitbox.get_overlapping_bodies()
	bodies.erase(self)
	print(bodies)
	for body in bodies:
		if body.has_method('attack_hit'):
			body.attack_hit()


func rotate_item():
	var relative_mouse_pos = viewport.get_mouse_position() - viewport_center
	var mouse_dir = relative_mouse_pos.normalized()
	var rel = Vector2.RIGHT
	var dot = rel.dot(mouse_dir)
	var det = rel.x * mouse_dir.y - mouse_dir.x * rel.y
	var rot = atan2(det, dot)
	character_render.set_knife_rotation(rot)
	%MeleeHitbox.rotation.y = -rot


func _on_character_render_swipe() -> void:
	check_attack_collision()
