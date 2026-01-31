class_name CharacterRender
extends Node2D

signal swipe


func melee_attack():
	$AnimationPlayer.play("melee_attack")


func set_knife_rotation(rot):
	if (rot < PI and rot > PI/2) or (rot > -PI and rot < -PI/2):
		%ObjectPivot.scale.y = -1
	else:
		%ObjectPivot.scale.y = 1
	%ObjectPivot.rotation = rot


func weapon_swipe():
	swipe.emit()
