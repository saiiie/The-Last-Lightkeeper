extends "res://scripts/enemies/enemy_base.gd"

@export var move_speed: float = 105.0
@export var attack_range: float = 46.0
@export var attack_interval: float = 1.0
@export var attack_damage: int = 8

var _attack_remaining: float = 0.0


func _update_behavior(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(_beacon) or _beacon.is_queued_for_deletion() or not _beacon.has_method("take_damage"):
		return

	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	var offset := _beacon.global_position - global_position
	var distance := offset.length()
	if distance > attack_range + 0.01:
		velocity = offset.normalized() * minf(move_speed, (distance - attack_range) / delta)
		move_and_slide()
	elif _attack_remaining <= 0.0:
		_attack_remaining = attack_interval
		_beacon.take_damage(attack_damage)
