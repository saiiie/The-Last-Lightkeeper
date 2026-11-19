extends "res://scripts/enemies/enemy_base.gd"

signal health_changed(current: int, maximum: int)

const BOLT := preload("res://scenes/projectiles/cinder_bolt.tscn")
const ATTACK_RANGE := 250.0
const SLAM_RADIUS := 90.0
const WARNING_SECONDS := 1.0
const SLAM_DAMAGE := 18

var _delay := 0.65
var _slam_next := false
@onready var _warning: Polygon2D = $SlamWarning


func _ready() -> void:
	var circle := PackedVector2Array()
	for index in 64:
		circle.append(Vector2.from_angle(TAU * index / 64.0) * SLAM_RADIUS)
	_warning.polygon = circle
	$SlamWarning/Rim.points = circle


func take_damage(amount: int) -> void:
	var previous := current_health
	super.take_damage(amount)
	if current_health != previous:
		health_changed.emit(current_health, max_health)


func _update_behavior(delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_instance_valid(_beacon) or _beacon.is_queued_for_deletion():
		_warning.hide()
		return
	_delay = maxf(0.0, _delay - delta)
	if _warning.visible:
		if _delay <= 0.0:
			var center := _warning.global_position
			_warning.hide()
			for target in [_beacon, _player]:
				if is_instance_valid(target) and not target.is_queued_for_deletion() and center.distance_to(target.global_position) <= SLAM_RADIUS:
					target.take_damage(SLAM_DAMAGE)
			_delay = 2.0
		return

	var offset := _beacon.global_position - global_position
	if offset.length() > ATTACK_RANGE + 0.01:
		velocity = offset.normalized() * minf(80.0, (offset.length() - ATTACK_RANGE) / delta)
		move_and_slide()
		return
	if _delay > 0.0:
		return
	if _slam_next:
		_warning.global_position = _beacon.global_position
		_warning.show()
		_delay = WARNING_SECONDS
	else:
		var aim := offset.normalized() if not offset.is_zero_approx() else Vector2.RIGHT
		for angle in [-15.0, 0.0, 15.0]:
			var bolt := BOLT.instantiate()
			bolt.top_level = true
			add_child(bolt)
			bolt.launch(global_position, aim.rotated(deg_to_rad(angle)), get_rid(), _beacon)
		_delay = 1.5
	_slam_next = not _slam_next
