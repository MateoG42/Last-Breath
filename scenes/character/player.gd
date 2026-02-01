class_name Player
extends CharacterBody3D

@onready var viewport: Viewport = get_viewport()
@onready var viewport_center: Vector2 = Vector2(viewport.size / 2)

@export var character_render: CharacterRender
@export var speed: float = 5.0

const PUNCH_RANGE = 0.3

var item_data = null
@export var held_item_id: WeaponData.WeaponID

var item_pickups = [null, preload('res://scenes/map_objects/knife.tscn'), preload("res://scenes/map_objects/mask.tscn"), preload('res://scenes/map_objects/bat.tscn')]

var game_started = false

var in_fog = false


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
			attack.rpc()
		
		if Input.is_action_just_pressed("drop_item"):
			if item_data:
				drop_item()
				
		if in_fog and item_data is not MaskData:
			if $DeathTimer.is_stopped():
				$DeathTimer.start()
		else:
			$DeathTimer.stop()


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority() and game_started:
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

@rpc("call_local")
func attack():
	character_render.melee_attack()


func check_attack_collision():
	if is_multiplayer_authority():
		var bodies: Array = %MeleeHitbox.get_overlapping_bodies()
		bodies.erase(self)
		for body in bodies:
			if body.has_method('attack_hit'):
				body.attack_hit.rpc_id(body.get_multiplayer_authority())

@rpc('any_peer')
func attack_hit():
	if item_data:
		drop_item()


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
	if is_multiplayer_authority():
		print(item_data)
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
	
	spawn_item.rpc(multiplayer.get_unique_id(), held_item_id)
	
	item_data = null

@rpc('call_local')
func spawn_item(pid, item_id):
	print('item_id ', item_id)
	var item: Pickup = item_pickups[item_id].instantiate()

	get_parent().add_child(item)
	item.set_multiplayer_authority(pid)
	
	item.global_position = global_position + Vector3(0, 0, 1)


func pickup_weapon(weapon_dat: WeaponData):
	held_item_id = weapon_dat.item_id
	character_render.set_weapon(weapon_dat.item_id)
	
	%MeleeHitbox/AttackCollision.shape.radius = weapon_dat.attack_range


func pickup_mask(_item: MaskData):
	held_item_id = ItemData.WeaponID.MASK
	character_render.set_mask(true)


func exit_fog_safety():
	print('exited safety')
	in_fog = true
	

func enter_fog_safety():
	print('entered safety')
	in_fog = false


@rpc('call_local')
func die():
	if is_multiplayer_authority():
		get_parent().set_camera()
	queue_free()


func _on_game_started():
	game_started = true


func _on_death_timer_timeout() -> void:
	die.rpc()
