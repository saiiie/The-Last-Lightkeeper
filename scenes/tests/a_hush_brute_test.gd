extends Node2D

const MockBeacon := preload("res://scenes/tests/a_thornbound_test.gd").MockBeacon
const THORNBOUND := preload("res://scenes/enemies/thornbound.tscn")

@onready var player = $Player
@onready var brute = $HushBrute

var _beacon := MockBeacon.new()
var _death_positions: Array[Vector2] = []
var _failures: int = 0


func _ready() -> void:
	add_child(_beacon)
	move_child(_beacon, 0)
	brute.set_targets(player, _beacon)
	brute.died.connect(_record_death)
	if "--verify-a6" in OS.get_cmdline_user_args():
		_verify.call_deferred()


func _process(_delta: float) -> void:
	var brute_health: int = brute.current_health if is_instance_valid(brute) else 0
	$HUD/Status.text = "Beacon HP %d / 200 | Hush Brute HP %d / 100" % [_beacon.health, brute_health]


func _record_death(world_position: Vector2) -> void:
	_death_positions.append(world_position)


func _verify() -> void:
	var thornbound = THORNBOUND.instantiate()
	thornbound.rotation = PI
	thornbound.position = Vector2(-180, 0)
	add_child(thornbound)
	thornbound.set_targets(player, _beacon)
	_check(brute.current_health == 100 and brute.attack_damage > thornbound.attack_damage, "higher health and strike damage")
	await _wait(60)
	_check(brute.position.x > 120.0 and absf(thornbound.position.x) < 80.0, "brute approaches more slowly")
	_check(is_zero_approx(brute.position.y) and _beacon.hits == 0, "direct approach without early damage")
	thornbound.queue_free()

	await _wait(75)
	_check(is_equal_approx(brute.position.x, 58.0) and _beacon.health == 180 and _beacon.hits == 1, "stops and deals one 20-damage strike")
	player._try_attacks(Vector2.RIGHT, true, true)
	_check(brute.current_health == 80, "player melee hits brute")
	await _wait(8)
	_check(brute.current_health == 68, "player projectile hits brute")
	await _wait(21)
	player._try_attacks(Vector2.RIGHT, true, false)
	await _wait(24)
	player._try_attacks(Vector2.RIGHT, true, false)
	await _wait(24)
	player._try_attacks(Vector2.RIGHT, true, false)
	await _wait(24)
	var last_position: Vector2 = brute.global_position
	player._try_attacks(Vector2.RIGHT, true, false)
	brute.take_damage(20)
	_check(_death_positions.size() == 1 and _death_positions[0].is_equal_approx(last_position), "death emitted once with world position")
	var hits_at_death := _beacon.hits
	await _wait(110)
	_check(not is_instance_valid(brute) and _beacon.hits == hits_at_death, "dead brute removed and cannot attack")
	if _failures == 0:
		print("A6 Hush Brute checks passed")
	get_tree().quit(0 if _failures == 0 else 1)


func _wait(frames: int) -> void:
	for frame in frames:
		await get_tree().physics_frame


func _check(passed: bool, description: String) -> void:
	if not passed:
		_failures += 1
		push_error("A6 check failed: " + description)
