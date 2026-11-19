extends "res://scripts/enemies/enemy_base.gd"

const CINDER_BOLT := preload("res://scenes/projectiles/cinder_bolt.tscn")
const MOVE_SPEED := 125.0
const MIN_RANGE := 170.0
const MAX_RANGE := 220.0
const ATTACK_INTERVAL := 1.6

var _attack_remaining: float = 0.0


func _update_behavior(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(_beacon) or _beacon.is_queued_for_deletion() or not _beacon.has_method("take_damage"):
		return

	_attack_remaining = maxf(0.0, _attack_remaining - delta)
	var offset := _beacon.global_position - global_position
	var distance := offset.length()
	var aim := offset.normalized()
	var range_error := distance - clampf(distance, MIN_RANGE, MAX_RANGE)
	if absf(range_error) > 0.01:
		var move_axis := aim if distance > 0.01 else Vector2.RIGHT
		velocity = move_axis * clampf(range_error / delta, -MOVE_SPEED, MOVE_SPEED)
		move_and_slide()
		return

	if _attack_remaining <= 0.0:
		_attack_remaining = ATTACK_INTERVAL
		var bolt := CINDER_BOLT.instantiate()
		get_parent().add_child(bolt)
		bolt.launch(global_position, aim, get_rid(), _beacon)
