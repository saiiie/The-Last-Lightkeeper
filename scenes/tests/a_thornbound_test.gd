extends Node2D

class MockBeacon extends Node2D:
	var health: int = 200
	var hits: int = 0

	func take_damage(amount: int) -> void:
		health = maxi(0, health - amount)
		hits += 1

	func _draw() -> void:
		draw_circle(Vector2.ZERO, 19.0, Color.WHITE)


@onready var player = $Player
@onready var thornbound = $Thornbound

var _beacon := MockBeacon.new()
var _death_positions: Array[Vector2] = []
var _failures: int = 0


func _ready() -> void:
	_beacon.position = Vector2(100.0, 0.0)
	add_child(_beacon)
	move_child(_beacon, 0)
	thornbound.set_targets(player, _beacon)
	thornbound.died.connect(_record_death)
	if "--verify-a4" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _process(_delta: float) -> void:
	var enemy_health: int = thornbound.current_health if is_instance_valid(thornbound) else 0
	$HUD/Status.text = "Beacon HP %d / 200 | Thornbound HP %d / 35" % [_beacon.health, enemy_health]


func _record_death(world_position: Vector2) -> void:
	_death_positions.append(world_position)


func _verify() -> void:
	_check(thornbound.current_health == 35, "starting enemy health")
	await _wait(115)
	_check(_beacon.health == 192 and _beacon.hits == 1, "chase and first 8-damage strike")
	var attack_position: Vector2 = thornbound.global_position
	_check(is_equal_approx(attack_position.distance_to(_beacon.global_position), 46.0), "stops in attack range")
	Input.action_press("lantern_pulse")
	await _wait(4)
	Input.action_release("lantern_pulse")
	_check(thornbound.global_position.x > attack_position.x, "pulse pushes enemy away")
	await _wait(16)
	var stunned_position: Vector2 = thornbound.global_position
	await _wait(14)
	_check(thornbound.global_position.is_equal_approx(stunned_position) and _beacon.hits == 1, "stun interrupts chase and attacks")
	await _wait(85)
	_check(_beacon.hits >= 2, "enemy resumes chase and attacks after stun")

	player._try_attacks(Vector2.RIGHT, true, false)
	_check(thornbound.current_health == 15, "real player melee damages enemy")
	player._try_attacks(Vector2.RIGHT, false, true)
	await _wait(12)
	_check(thornbound.current_health == 3, "real player projectile damages enemy")
	await _wait(24)
	var last_position: Vector2 = thornbound.global_position
	player._try_attacks(Vector2.RIGHT, true, false)
	thornbound.take_damage(20)
	_check(_death_positions.size() == 1 and _death_positions[0].is_equal_approx(last_position), "death emitted once with world position")
	var hits_at_death := _beacon.hits
	await _wait(70)
	_check(not is_instance_valid(thornbound) and _beacon.hits == hits_at_death, "dead enemy removed and cannot attack")
	if _failures == 0:
		print("A4 Thornbound checks passed")
	get_tree().quit(0 if _failures == 0 else 1)


func _wait(frames: int) -> void:
	for frame in frames:
		await get_tree().physics_frame


func _check(passed: bool, description: String) -> void:
	if not passed:
		_failures += 1
		push_error("A4 check failed: " + description)
