class_name Player
extends CharacterBody3D

@onready var viewport: Viewport = get_viewport()
@onready var viewport_center: Vector2 = Vector2(viewport.size / 2)

@export var character_render: CharacterRender
@export var speed: float = 5.0

const PUNCH_RANGE = 0.3

var item_data = null

var pickup_scene = preload('res://scenes/map_objects/pickup.tscn')


func _enter_tree() -> void:
	var id = name.to_int()
	set_multiplayer_authority(id)
	character_render.set_multiplayer_authority(id)
	if is_multiplayer_authority():
		$Camera3D.current = true


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		rotate_item()
		if Input.is_action_just_pressed("attack"):
			character_render.melee_attack()
		
		if Input.is_action_just_pressed("drop_item"):
			if item_data:
				drop_item()


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
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


func grab_item(item: ItemData) -> bool:
	if !item_data:
		if item is WeaponData:
			pickup_weapon(item)
		if item is MaskData:
			pickup_mask(item)
		item_data = item
		return true
	return false


func drop_item():
	character_render.unequip()
	%MeleeHitbox/AttackCollision.shape.radius = PUNCH_RANGE
	
	var new_pickup: Pickup = pickup_scene.instantiate()
	new_pickup.item_data = item_data
	
	get_tree().root.add_child(new_pickup)
	new_pickup.global_position = global_position + Vector3(0, 0, 0.5)
	item_data = null


func pickup_weapon(weapon_dat: WeaponData):
	character_render.set_weapon(weapon_dat.weapon_id)
	%MeleeHitbox/AttackCollision.shape.radius = weapon_dat.attack_range


func pickup_mask(_item: MaskData):
	character_render.set_mask(true)


func exit_fog_safety():
	print('exited safety')


func enter_fog_safety():
	print('entered safety')
