class_name WeaponData
extends ItemData

enum WeaponID {FIST, KNIFE}

@export_range(0.4, 0.7) var attack_range: float = 0.5
@export var is_melee: bool
@export var weapon_id: WeaponID
