class_name CharacterRender
extends Node2D

signal swipe
@onready var sprite = $PlayerSprite
var last_direction

@export var current_weapon: WeaponData.WeaponID = WeaponData.WeaponID.FIST:
	set(new_id):
		current_weapon = new_id
		%Weapon.texture = weapon_textures[current_weapon]
var weapon_textures = [null, preload("res://assets/shank.png")]


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		var dir = Input.get_vector('left', 'right', 'down', 'up')
		if dir != Vector2.ZERO:
			sprite.play("running")
		else :
			sprite.play("idle")


func set_mask(vis):
	%Mask.visible = vis


func unequip():
	if %Weapon.texture == null:
		set_mask(false)
	else:
		current_weapon = WeaponData.WeaponID.FIST


func set_weapon(weapon_sprite: WeaponData.WeaponID):
	current_weapon = weapon_sprite


func melee_attack():
	$WeaponAnimations.play("melee_attack")


func set_knife_rotation(rot):
	if (rot < PI and rot > PI/2) or (rot > -PI and rot < -PI/2):
		sprite.flip_h = true
		%ObjectPivot.scale.y = -1
	else:
		sprite.flip_h = false
		%ObjectPivot.scale.y = 1
	%ObjectPivot.rotation = rot


func weapon_swipe():
	swipe.emit()
